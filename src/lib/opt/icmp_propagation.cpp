#include "opt_passes.h"

using namespace llvm;
using namespace std;

// propagation의 (target, source)를 찾아 반환하는 함수
tuple<Value*, Value*> decideWhoWillBeChanged(ICmpInst* CondI, DominatorTree &DT, Function &F){
  tuple<Value*, Value*> nullTuple = make_tuple(nullptr, nullptr);
  auto first = CondI->getOperand(0);
  auto second = CondI->getOperand(1);
  
  if(!first->getType()->isIntegerTy() || !second->getType()->isIntegerTy())
    return nullTuple;

  // 이 아래는 first, second가 Ptr이 아닌 Integer일때만 수행
  // first, second 중 상수가 있는 경우
  bool isFirstConstInt = isa<ConstantInt>(first);
  bool isSecondConstInt = isa<ConstantInt>(second);
  if(isFirstConstInt && isSecondConstInt) 
    return nullTuple;
  else if(isFirstConstInt ^ isSecondConstInt)
    return isFirstConstInt? make_tuple(second, first) : make_tuple(first, second);
  
  // 이 아래는 first, second가 둘 다 상수가 아닌 경우만 수행
  // first, second가 Argument인가?
  uint64_t firstArgN = -1; 
  uint64_t secondArgN = -1;
  for (auto &arg : F.args()){
    if (&arg == first)  firstArgN = arg.getArgNo();
    if (&arg == second) secondArgN = arg.getArgNo();
  }

  Value *ChangeFrom;
  Value *ChangeTo;
  // 만약 둘 다 Argument가 아니거나, 같은 Argument라면 ArgN 값이 같다
  if (firstArgN == secondArgN){
    auto secondInst = dyn_cast<Instruction>(second);
    if (secondInst == nullptr) // 같은 Argument인 경우
      return nullTuple;
    //dbgs() << "Name: " << second->getName() << " Inst: NULL? " << (secondInst == NULL) <<"\n";
    // 둘 다 Instruction인 경우
    ChangeFrom = DT.dominates(first, secondInst)? second : first;
    ChangeTo   = DT.dominates(first, secondInst)? first : second;
  }
  else{ // 둘 다 Argument이며 서로 다른 경우
    ChangeFrom = firstArgN < secondArgN ? second : first ; // 바꿈 당할 변수는 더 큰 Arg N
    ChangeTo   = firstArgN < secondArgN ? first : second ; // 바꿀 변수는 더 작은 ArgN
  }
  return make_tuple(ChangeFrom, ChangeTo);
}

// Predecessor가 모두 conditional branch를 가지는지, condition이 icmp eq, ne인지 체크해
// 모두 다 해당되는 경우에만 이들을 모두 담은 정상적인 vector를 반환, 아니면 빈 벡터 반환
vector<ICmpInst*> getPredICmpInsts(BasicBlock &BB){
  vector<ICmpInst*> ICMPInsts;
  vector<ICmpInst*> emptyVector;
  for (pred_iterator PI = pred_begin(&BB), E = pred_end(&BB); PI!=E; ++PI){
    auto Pred = *PI;
    auto TI = Pred->getTerminator();
    BranchInst* BTI = dyn_cast<BranchInst>(TI);
    if (!BTI) return emptyVector; // BranchInst가 아닌 경우
    if (!BTI->isConditional()) return emptyVector; // Conditional Branch가 아닌 경우

    if(auto CondI = dyn_cast<ICmpInst>(BTI->getCondition())){
      if(CondI->getPredicate() == ICmpInst::ICMP_EQ 
      || CondI->getPredicate() == ICmpInst::ICMP_NE){
        ICMPInsts.push_back(CondI);
      }
      else return emptyVector; // ICMP inst 가 아닌 경우 다 날리기
    }
    else return emptyVector;
  }
  return ICMPInsts;
}

// 두 ICmpInst를 받아, 같은 Operand를 가지는지를 따져 반환하는 함수
// Operand가 '상수'인 경우도 고려함
bool isSameOperand(ICmpInst* ref, ICmpInst* now){
  auto compareValues = [](Value *v1, Value *v2){
    if (v1 == v2) return true;
    if (ConstantInt *C1 = dyn_cast<ConstantInt>(v1)){
      if (ConstantInt *C2 = dyn_cast<ConstantInt>(v2))
        return C1->getValue() == C2->getValue();
    }
    return false;
  };
  auto refOp1 = ref->getOperand(0);
  auto refOp2 = ref->getOperand(1);
  auto nowOp1 = now->getOperand(0);
  auto nowOp2 = now->getOperand(1);
  if((compareValues(refOp1, nowOp1) && compareValues(refOp2, nowOp2))
  || (compareValues(refOp2, nowOp1) && compareValues(refOp1, nowOp2)))
    return true;
  else
    return false;
}

void replaceUsesInBasicBlock(Value *Old, Value *New, BasicBlock *BB){
  for (auto &I: *BB){
    for (Use &U : I.operands()){
      if (U.get() == Old){
        U.set(New);
      }
    }
  }
}

PreservedAnalyses ICMPPropagationPass::run(Function &F, FunctionAnalysisManager &FAM) {
  // Part 1: icmp eq, ne에 대해 각 true edge/false edge에 의해 지배되는 쪽 propagation
  for (auto &BB: F){
    if(auto TI = BB.getTerminator()){
      if(BranchInst *BTI= dyn_cast<BranchInst>(TI)){
        if(BTI->isConditional()){
          if(auto CondI = dyn_cast<ICmpInst>(BTI->getCondition())){
            BasicBlock *BBNext;
            if(CondI->getPredicate() == ICmpInst::ICMP_EQ){
              BBNext = BTI->getSuccessor(0); // true branch          
            }
            else if(CondI->getPredicate() == ICmpInst::ICMP_NE){
              BBNext = BTI->getSuccessor(1); // false branch
            }
            else continue;

            BasicBlockEdge DominateEdge(&BB, BBNext); // Dominate edge
            DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
            auto [ChangeFrom, ChangeTo] = decideWhoWillBeChanged(CondI, DT, F);
            if (ChangeFrom == nullptr) continue;

            replaceDominatedUsesWith(ChangeFrom, ChangeTo, DT, DominateEdge);
          }
        }
      }
    }
  }

  // Part 2: Block으로 올 수 있는 branch의 조건식이 수학적으로 모두 같은 경우
  for (auto &BB: F){
    if(BB.hasNPredecessors(0) || BB.hasNPredecessors(1)) continue;
    vector<ICmpInst*> ICMPInsts = getPredICmpInsts(BB);
    if(ICMPInsts.empty()) continue; // Predecessor가 0인 경우는 앞에서 걸렀음. 따라서 여기선
                                    // 조건에 맞지 않는 Predecessor가 있는 경우만 continue
          
    // 여기부터 ICMPInsts는 ICMP eq, ne인 Insturction만 담고 있음
    // true, false가 모두 똑같은 BB를 가리키는 경우는 없으리라 가정하고, 그에 대해서 다루지 않겠음
    vector<BranchInst *> BranchInsts;
    for (BasicBlock *Pred : predecessors(&BB)) {
      BranchInsts.push_back(dyn_cast<BranchInst>(Pred->getTerminator()));
    }
    // BranchInsts와 ICMPInsts의 원소는 서로 1:1 대응하게 됨

    // 이제,
    // 1. ICMP의 Operand set이 서로 같은가?
    // 2. eq면 true, ne면 false branch가 BB를 가리키는가?
    // 이 조건을 만족하는 경우에 BB가 dominate하는 use들을 바꾸기
    auto refInst = ICMPInsts.front();
    bool needContinue = false;
    for (size_t i = 0; i < ICMPInsts.size(); ++i){
      auto nowInst = ICMPInsts[i];
      if(!isSameOperand(refInst, nowInst)) {
        needContinue = true;
        break;
      }
      auto nowBrInst = BranchInsts[i];
      if(nowInst->getPredicate() == ICmpInst::ICMP_EQ && nowBrInst->getSuccessor(0) == &BB)
        continue;
      if(nowInst->getPredicate() == ICmpInst::ICMP_NE && nowBrInst->getSuccessor(1) == &BB)
        continue;
      needContinue = true;
      break;
    }
    if (needContinue) continue; 
    
    DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
    auto [ChangeFrom, ChangeTo] = decideWhoWillBeChanged(refInst, DT, F);
    if (ChangeFrom == nullptr) continue; // first, second가 모두 상수인 경우에 해당

    replaceUsesInBasicBlock(ChangeFrom, ChangeTo, &BB);
    replaceDominatedUsesWith(ChangeFrom, ChangeTo, DT, &BB);
  }
  return PreservedAnalyses::none();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ICMPPropagationPass", "v0.1",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "icmp_propagation") {
                    FPM.addPass(ICMPPropagationPass());
                    return true;
                  }
                  return false;
                });
          }};
}
