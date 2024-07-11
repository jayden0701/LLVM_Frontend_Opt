#include "opt_passes.h"

using namespace llvm;

 // Helper method to determine if an instruction is a call to malloc
  bool isMallocCall(const CallInst *CI)  {
    if (const Function *Callee = CI->getCalledFunction())
      return Callee->getName() == "malloc";
    return false;
  }

  // Helper method to determine if an instruction is a call to free
  bool isFreeCall(const CallInst *CI)  {
    if (const Function *Callee = CI->getCalledFunction())
      return Callee->getName() == "free";
    return false;

  }


  bool isInSameLoop(const Instruction *I1, const Instruction *I2, const LoopInfo &LI) {
    const Loop *Loop1 = LI.getLoopFor(I1->getParent());
    const Loop *Loop2 = LI.getLoopFor(I2->getParent());
    return Loop1 && (Loop1 == Loop2);
}


// 현재 문제점 : malloc - free가 loop body안에서 사용될 경우, 마지막 Loop을 제외하고는 free되어야 하는데, free가 제거가 됨.
// loop만 따로 처리하는 logic구현 예정

PreservedAnalyses FreeOptPass::run(Function &F,
                                              FunctionAnalysisManager &FAM) {
 DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
  PostDominatorTree &PDT = FAM.getResult<PostDominatorTreeAnalysis>(F);

  LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);


  bool modified = false;

  Instruction *lastMalloc = nullptr;
  std::vector<Instruction*> freesToDelete;


  // thinking : maybe we don't need to check domination
  // we can just check if the free is after the last malloc
  // because matching correct free is upto the programmer, not the compiler

  for (auto &B : F) {
    for (auto &I : B) {
      if (auto *callInst = dyn_cast<CallInst>(&I)) {
        if (isMallocCall(callInst)) {
          lastMalloc = &I;
          freesToDelete.clear(); // Reset freesToDelete when we find a new malloc
        } else if (isFreeCall(callInst)) {
          if (lastMalloc && DT.dominates(lastMalloc, callInst) && PDT.dominates(callInst, lastMalloc)) {
            if(!isInSameLoop(lastMalloc, callInst, LI))
            {
                freesToDelete.push_back(&I);
            }
          }
        }
      }
    }
  }

  // Remove all identified free calls
  for (auto *freeInst : freesToDelete) {
    freeInst->eraseFromParent();
    modified = true;
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "FreeOptPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "free_opt") {
                    FPM.addPass(FreeOptPass());
                    return true;
                  }
                  return false;
                });
          }};
}
