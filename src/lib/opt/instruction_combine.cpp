#include "llvm/Transforms/InstCombine/InstCombine.h"

#include "opt_passes.h"

using namespace llvm;

PreservedAnalyses InstructionCombinePass::run(Function &F,
                                      FunctionAnalysisManager &FAM) {
  return PreservedAnalyses::none();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "InstructionCombinePass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "instruction_combine") {
                    FPM.addPass(InstCombinePass());
                    return true;
                  }
                  return false;
                });
          }};
}
