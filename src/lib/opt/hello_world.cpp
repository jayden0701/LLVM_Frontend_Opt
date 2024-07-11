#include "hello_world.h"

using namespace llvm;

PreservedAnalyses HelloWorldPass::run(Function &F,
                                      FunctionAnalysisManager &AM) {
  // outs() << F.getName() << "\n";
  return PreservedAnalyses::all();
}

// need this for running opt(temporal code)
extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ConstFold", "v0.1", [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "hello_world") {
                    FPM.addPass(HelloWorldPass());
                    return true;
                  }
                  return false;
                });
          }};
}