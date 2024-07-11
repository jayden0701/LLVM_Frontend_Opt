#include "opt_passes.h"

using namespace llvm;

PreservedAnalyses Alloca2RegPass::run(Function &F,
                                      FunctionAnalysisManager &FAM) {
  bool modified = false;

  auto &DT = FAM.getResult<llvm::DominatorTreeAnalysis>(F);

  // Collect all alloca instructions in the function
  std::vector<llvm::AllocaInst *> Allocas;
  for (auto &BB : F) {
    for (auto &I : BB) {
      if (auto *AI = llvm::dyn_cast<llvm::AllocaInst>(&I)) {
        if (llvm::isAllocaPromotable(AI))
        {
            Allocas.push_back(AI);
        }
      }
    }
  }

  // Only attempt to promote if there are allocas to promote
  if (!Allocas.empty()) {
    // Promote allocas to registers using the dominator tree
    modified = true;
    llvm::PromoteMemToReg(Allocas, DT);
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "Alloca2RegPass", "v0.1",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "Alloca2RegOpt") {
                    FPM.addPass(Alloca2RegPass());
                    return true;
                  }
                  return false;
                });
          }};
}
