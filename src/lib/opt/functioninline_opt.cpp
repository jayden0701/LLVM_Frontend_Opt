#include "opt_passes.h"
#include "llvm/IR/Verifier.h"

using namespace llvm;

bool usesTooManyRegisters(Function &F, int MaxRegisters) {
  // Heuristic: Use a combination of the number of instructions and basic blocks
  int InstructionCount = 0;
  int BasicBlockCount = 0;

  for (auto &BB : F) {
    BasicBlockCount++;
    for (auto &I : BB) {
      InstructionCount++;
    }
  }

  // Estimate register usage based on the instruction count and basic block
  // count
  int EstimatedRegisterUsage = InstructionCount / BasicBlockCount;

  return EstimatedRegisterUsage > MaxRegisters;
}

PreservedAnalyses FunctionInlinePass::run(Module &M,
                                          ModuleAnalysisManager &MAM) {
  bool Changed = false;
  const int MaxRegisters = 20; // Maximum allowed registers for inlining

  FunctionAnalysisManager &FAM =
      MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();

  // Create an inliner pass with a default threshold
  std::function<AssumptionCache &(Function &)> GetAssumptionCache =
      [&](Function &F) -> AssumptionCache & {
    return FAM.getResult<AssumptionAnalysis>(F);
  };

  InlineFunctionInfo IFI;

  std::vector<std::pair<CallBase *, BasicBlock &>> CallsToInline;

  std::map<Function *, bool> FunctionHasInline;

  for (auto &F : M) {
    if (!F.isDeclaration()) {
      for (auto &BB : F) {
        for (auto &I : BB) {
          if (auto *Call = dyn_cast<CallBase>(&I)) {
            if (Function *Callee = Call->getCalledFunction()) {
              if (!Callee->isDeclaration() &&
                  !Callee->hasFnAttribute(Attribute::NoInline)) {

                // Check register usage
                if (usesTooManyRegisters(*Callee, MaxRegisters)) {
                  // Skip inlining this function
                  outs() << "Skipping inlining of " << Callee->getName()
                         << " due to register usage\n";
                  continue;
                }

                // do not inline recursive calls
                if (Callee == &F) {
                  continue;
                }

                if (verifyFunction(*Callee, &outs())) {
                  outs() << "Function " << Callee->getName()
                         << " is not valid\n";
                  continue;
                }

                // Add the call to the list of calls to inline
                CallsToInline.push_back({Call, BB});
              }
            }
          }
        }
      }
    }
  }

  // Inline the calls
  for (auto &CallPair : CallsToInline) {
    CallBase *Call = CallPair.first;
    BasicBlock &BB = CallPair.second;

    Function *Callee = Call->getCalledFunction();
    Function *Caller = BB.getParent();

    outs() << "Inlining " << Callee->getName() << " into "
           << BB.getParent()->getName() << "\n";

    if (verifyFunction(*Callee, &outs())) {
      outs() << "Function " << Callee->getName() << " is not valid\n";
      continue;
    }

    if (FunctionHasInline[Caller]) {
      continue;
    }


    if (InlineFunction(*Call, IFI).isSuccess()) {
      FunctionHasInline[Caller] = true;
    }

    // InlineFunction(Callee, IFI);

    Changed = true;
  }

  // for (auto &Call : CallsToInline) {
  //   Function *Callee = Call.first;
  //   BasicBlock &BB = Call.second;

  //   InlineFunction(Callee, IFI, nullptr, false);
  //   Changed = true;
  // }

  return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "FunctionInlinePass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "functioninline_opt") {
                    MPM.addPass(FunctionInlinePass());
                    return true;
                  }
                  return false;
                });
          }};
}
