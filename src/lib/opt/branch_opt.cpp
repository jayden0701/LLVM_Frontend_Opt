#include "llvm/Analysis/BranchProbabilityInfo.h"

#include "opt_passes.h"

using namespace llvm;

bool shouldInvertBranch(BranchInst *BI, FunctionAnalysisManager &FAM) {
  // using llvm analysis which provides branch probability information
  // https://llvm.org/doxygen/classllvm_1_1BranchProbabilityInfo.html
  auto &BPI = FAM.getResult<BranchProbabilityAnalysis>(*BI->getFunction());

  // get probability of true branch
  BranchProbability Prob =
      BPI.getEdgeProbability(BI->getParent(), BI->getSuccessor(0));
  BranchProbability threshold(1, 4); // 25%
  return Prob > threshold;           // return true if (true branch > 25%)
}

PreservedAnalyses BranchOptimizationPass::run(Function &F,
                                              FunctionAnalysisManager &FAM) {
  LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
  bool modified = false;

  for (auto &L : LI) {
    BasicBlock *Header = L->getHeader();
    BranchInst *BI = dyn_cast<BranchInst>(Header->getTerminator());

    if (BI && BI->isConditional()) {
      ICmpInst *CI = dyn_cast<ICmpInst>(BI->getCondition());
      if (CI && shouldInvertBranch(BI, FAM)) {
        // Invert the condition
        ICmpInst::Predicate NewPred =
            ICmpInst::getInversePredicate(CI->getPredicate());
        CI->setPredicate(NewPred);

        // Swap branch
        BI->swapSuccessors();

        modified = true;
      }
    }
  }
  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "BranchOptimizationPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "branch_opt") {
                    FPM.addPass(BranchOptimizationPass());
                    return true;
                  }
                  return false;
                });
          }};
}
