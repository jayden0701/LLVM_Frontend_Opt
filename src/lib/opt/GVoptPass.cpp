#include "opt_passes.h"

using namespace llvm;
using namespace std;

// changed code, so that it only works on loop(loop이 아닌 경우에는 overhead가 더 큰 배보다 큰 배꼽인 경우가 다수)
// 1) if no store, than change to reg
// 2) if there is store, than change to alloca
// 3) just leave out the case when there is function call inside loop(이건 걍 overhead가 너무 커짐)

// 현재 '1)'은 구현완료. store의 경우는 cost가 상승할 수 있기에, 
// 이번에 도입한 mem2reg가 alloca로 변환한 global variable을 잘 register로 변환하는지 확인하고 
// 추가 구현 예정
PreservedAnalyses GVoptPass::run(Function &F, FunctionAnalysisManager &FAM) {
  auto &LI = FAM.getResult<LoopAnalysis>(F);
  bool modified = false;

  for (auto *L : LI) {
    if (L->getLoopPreheader()) {
      DenseMap<GlobalVariable *, LoadInst *> PreheaderLoads;
      BasicBlock *Preheader = L->getLoopPreheader();
      
      std::vector<Instruction*> toErase;

      // Check all blocks in the loop
      for (auto *BB : L->blocks()) {
        for (auto &I : *BB) {
          if (auto *LI = dyn_cast<LoadInst>(&I)) {
            if (auto *GV = dyn_cast<GlobalVariable>(LI->getOperand(0))) {

              bool isGVStoredInLoop = false;

              // Check if GV is stored in the loop
              for (auto *User : GV->users()) {
                if (isa<StoreInst>(User) &&
                    L->contains(cast<Instruction>(User)->getParent())) {
                  isGVStoredInLoop = true;
                  break;
                }
              }




              // Proceed if safe to hoist
              if (!isGVStoredInLoop) {
                LoadInst *ExistingLoad = PreheaderLoads[GV];
                if (!ExistingLoad) {
                  // Move the load to the preheader
                  LoadInst *NewLoad = dyn_cast<LoadInst>(LI->clone());
                  NewLoad->insertBefore(&Preheader->back());


                  PreheaderLoads[GV] = NewLoad;
                  LI->replaceAllUsesWith(NewLoad);
                  // LI->eraseFromParent();
                  toErase.push_back(LI);
    
                } else {

                  // Replace with existing load
                  LI->replaceAllUsesWith(ExistingLoad);
                  toErase.push_back(LI);
                  // LI->eraseFromParent();
                }
                modified = true;
              }
            }
          }
        }
      }
      for (auto *I : toErase) {
        I->eraseFromParent();
      }

      // Remove old loads
      // for (auto *BB : L->blocks()) {
      //   for (auto itr = BB->begin(), end = BB->end(); itr != end;) {
      //     if (auto *LI = dyn_cast<LoadInst>(&(*itr))) {
      //       if (LI->getOperand(0)->getType()->isPointerTy()) {
      //         itr = LI->eraseFromParent();
      //         continue;
      //       }
      //     }
      //     ++itr;
      //   }
      // }
    }
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

// need this for running opt(temporal code)
extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "GVoptPass", "v0.1", [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "GVoptPass") {
                    FPM.addPass(GVoptPass());
                    return true;
                  }
                  return false;
                });
          }};
}
