#include "opt_passes.h"
#include "llvm/Transforms/Scalar/Reassociate.h"

using namespace llvm;

PreservedAnalyses ReassociationPass::run(Function &F,
                                      FunctionAnalysisManager &FAM) {
  return PreservedAnalyses::none();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ReassociationPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "reassociation_pass") {
                    FPM.addPass(ReassociatePass());
                    return true;
                  }
                  return false;
                });
          }};
}
