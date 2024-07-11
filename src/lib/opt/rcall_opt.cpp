#include "llvm/IR/Instructions.h"

#include "opt_passes.h"

using namespace llvm;

PreservedAnalyses RCallOptimizationPass::run(Function &F,
                                             FunctionAnalysisManager &FAM) {
  bool modified = false;

  for (auto &BB : F) {
    for (auto &I : BB) {
      // Check if the instruction is a call
      if (auto *CI = dyn_cast<CallInst>(&I)) {
        Function *Callee = CI->getCalledFunction();
        // Check if the call is recursive
        if (Callee && Callee == &F) {
          // Replace the call instruction with a recursive call instruction
          CI->setTailCall(true);
          modified = true;
        }
      }
    }
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "RCallOptimizationPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "rcall_opt") {
                    FPM.addPass(RCallOptimizationPass());
                    return true;
                  }
                  return false;
                });
          }};
}
