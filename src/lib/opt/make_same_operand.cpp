#include "opt_passes.h"
#include "llvm/Transforms/Scalar/EarlyCSE.h"
#include "llvm/Transforms/Scalar/NewGVN.h"

using namespace llvm;
using namespace std;

// 현재는 사용 안하는 함수
/*void doConstantFolding(Function &F){
  vector<Instruction*> willDeleted; 
  for (inst_iterator I = inst_begin(F), E = inst_end(F); I !=E; ++I){
    auto &nowInst = *I;
    if(auto C = ConstantFoldInstruction(&nowInst, F.getParent()->getDataLayout())){
      nowInst.replaceAllUsesWith(C);
      willDeleted.push_back(&nowInst);
    }
  }
  for (auto VI = willDeleted.begin(), E = willDeleted.end(); VI !=E; ++VI)
    (*VI)->removeFromParent();
}*/

// Instruction이 실질적으로 같은 연산을 하는지 체크
bool isIdenticalOperation(Instruction* I1, Instruction* I2){
  if (I1->getOpcode() != I2->getOpcode())
    return false;
  if (I1->isCommutative()){
    unordered_set<Value *> operands1(I1->op_begin(), I1->op_end()); 
    unordered_set<Value *> operands2(I2->op_begin(), I2->op_end());
    if (operands1 != operands2) return false;
  }
  else{ // isIdenticalTo는 순서를 따지는 strict한 Instruction 비교 연산
    if(!I1->isIdenticalTo(I2)) return false;
  }
  return true;
}

bool isCannotBeEliminated(Instruction* I){
  return isa<LoadInst>(I) || isa<StoreInst>(I) || isa<CallInst>(I)
  || isa<PHINode>(I) || I->isTerminator() || isa<GetElementPtrInst>(I)
  || isa<CastInst>(I) || isa<AllocaInst>(I) ;
  // 현재 Call은 incr 같은 적절하게 위로 올릴 수 있는 연산들도 포함하지만
  // 그보다 올릴 수 없는 연산이 훨씬 많아서 일단 전면 배제
  // ArithOpt를 이 패스 전에 돌리는 것을 권장
}

PreservedAnalyses MakeSameOperandPass::run(Function &F, FunctionAnalysisManager &FAM) {
  vector<Instruction*> workList;
  
  for (inst_iterator I = inst_begin(F), E = inst_end(F); I !=E; ++I){
    auto nowI = &*I;
    if (isCannotBeEliminated(nowI)) continue;
    workList.push_back(nowI);
    //dbgs() << "push_in :" << nowI->getName() << "\n";
  }

  for (int i = 0; i < workList.size(); ++i){
    Instruction* A = workList[i];
    if (A == nullptr) continue; // 이미 삭제된 instruction
    for (int j = i+1; j<workList.size(); ++j){
      Instruction* B = workList[j]; 
      if (B == nullptr) continue; // 이미 삭제된 instruction
      if (isIdenticalOperation(A, B)){
        DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
        Instruction* commonDominator = DT.findNearestCommonDominator(A, B);
        if (commonDominator){
          A->moveBefore(commonDominator);
          B->replaceAllUsesWith(A);
          B->eraseFromParent();
          workList[j] = nullptr;
        }
      }
    }
  }

  return PreservedAnalyses::all();
}

// * 추가하려던 기능
// 0. ConstantFolding
// 1. Variable Propagation
// 2. CSE(Common Subexpression Elimination)
// 를 수행하여 가능한 same operand를 가지는 instruction을 추가로 많이 만들고자 하였으나, 찾아보니
// NewGVN(), GVN()패스가 이 구현하려던 모든 기능을 더 수준 높게 수행하여, existingPass 추가로 대체

// 돌려보니 NewGVN()은 Common Subexpression을 공통 predecessor로 올려주는 역할을 수행하지 않는다.
// 따라서 그것을 수행하는 것만 따로 구현하기로 하였다
// EarlyCSEPass()는 한 BasicBlock 내의 CSE를 수행해주기에 먼저 수행하고 올려주는 것이 좋아 추가함

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "MakeSameOperandPass", "v1.0", [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "make_same_operand") {
                    FPM.addPass(EarlyCSEPass());
                    FPM.addPass(MakeSameOperandPass());
                    FPM.addPass(NewGVNPass());
                    return true;
                  }
                  return false;
                });
          }};
}
