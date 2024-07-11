#include <algorithm>

#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/LoopAnalysisManager.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Transforms/Scalar/IndVarSimplify.h"
#include "llvm/Transforms/Scalar/SROA.h"
#include "llvm/Transforms/Scalar/SimplifyCFG.h"
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Transforms/Utils/Mem2Reg.h"
#include "llvm/Transforms/Utils/UnrollLoop.h"

#include "opt_passes.h"

using namespace llvm;

const char *loopUnrollResultToString(llvm::LoopUnrollResult result) {
  switch (result) {
  case llvm::LoopUnrollResult::Unmodified:
    return "Unmodified";
  case llvm::LoopUnrollResult::PartiallyUnrolled:
    return "Partially Unrolled";
  case llvm::LoopUnrollResult::FullyUnrolled:
    return "Fully Unrolled";
  default:
    return "Unknown Result";
  }
}

void printLoopState(Loop *L, DominatorTree &DT, ScalarEvolution &SE) {
  errs() << "Is simplifyed loop?\t" << L->isLoopSimplifyForm() << "\n";
  outs() << "is LCSSA form? " << L->isLCSSAForm(DT) << "\n";
  outs() << "getSmallConstantMaxTripCount: "
         << SE.getSmallConstantMaxTripCount(L) << "\n";
  outs() << "getSmallConstantTripMultiple: "
         << SE.getSmallConstantTripMultiple(L) << "\n";
  outs() << "getBackedgeTakenCount: " << *SE.getBackedgeTakenCount(L) << "\n";
  outs() << "getConstantMaxBackedgeTakenCount: "
         << *SE.getConstantMaxBackedgeTakenCount(L) << "\n";
  outs() << "metadata:: " << "\n";
  L->getLoopID()->dumpTree();
  L->dump();
}

PreservedAnalyses LoopUnrollFullOptPass::run(Function &F,
                                             FunctionAnalysisManager &FAM) {
  // customizing existing loop unrolling pass
  // LoopUnrollResult UnrollLoop(Loop *L, UnrollLoopOptions ULO, LoopInfo *LI,
  //                             ScalarEvolution *SE, DominatorTree *DT,
  //                             AssumptionCache *AC,
  //                             const llvm::TargetTransformInfo *TTI,
  //                             OptimizationRemarkEmitter *ORE, bool
  //                             PreserveLCSSA, Loop **RemainderLoop = nullptr);
  LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
  ScalarEvolution &SE = FAM.getResult<ScalarEvolutionAnalysis>(F);
  DominatorTree &DT = FAM.getResult<DominatorTreeAnalysis>(F);
  AssumptionCache &AC = FAM.getResult<AssumptionAnalysis>(F);
  TargetTransformInfo &TTI = FAM.getResult<TargetIRAnalysis>(F);
  TargetLibraryInfo &TLI = FAM.getResult<TargetLibraryAnalysis>(F);
  OptimizationRemarkEmitter &ORE =
      FAM.getResult<OptimizationRemarkEmitterAnalysis>(F);

  bool modified = false;

  std::function<void(Loop *)> unrollLoopRecursively = [&](Loop *L) {
    // Process from the innermost loop
    for (Loop *SubLoop : L->getSubLoops()) {
      unrollLoopRecursively(SubLoop);
    }

    UnrollLoopOptions ULO;
    // trip count = iteration count
    // unrolling 할때 한 loop에 반복을 몇 번하는지
    unsigned TripCount = SE.getSmallConstantTripCount(L);
    //outs() << "TripCount: " << TripCount << "\n";

    unsigned LoopSize = 0;
    for (BasicBlock *BB : L->blocks()) {
      LoopSize += BB->size();
    }
    if (LoopSize > 100) {
      // hard code to fit benchmark
      // interpreter panic when assembly bytes > 50000 (e.g. matmul3, 4)
      return;
    }
    // printLoopState(L, DT, SE);

    ULO.Count = TripCount != 0 ? std::min(TripCount, unsigned(32)) : 4;
    ULO.Force = true;
    ULO.Runtime = true;
    ULO.AllowExpensiveTripCount = true;
    ULO.UnrollRemainder = true;
    ULO.ForgetAllSCEV = true;

    LoopUnrollResult result =
        UnrollLoop(L, ULO, &LI, &SE, &DT, &AC, &TTI, &ORE, false);
    if (result != llvm::LoopUnrollResult::FullyUnrolled) {
      simplifyLoopAfterUnroll(L, true, &LI, &SE, &DT, &AC, &TTI);
    }
    modified = true;
  };

  // Unroll all loops recursively from the innermost
  for (Loop *L : LI) {
    unrollLoopRecursively(L);
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "LoopUnrollFullOptPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "loop_unroll_full_opt") {
                    // loop에서 incr할때 변수를 load로 불러오면 tripCount를
                    // 읽을 수 없다. mem에 들어간 정보는 미리 읽을 수 없음.
                    // mem2reg로 다 reg에서 바로 읽을 수 있게
                    FPM.addPass(PromotePass());
                    FPM.addPass(SROAPass(SROAOptions::PreserveCFG));
                    FPM.addPass(LoopSimplifyPass());
                    FPM.addPass(LCSSAPass());
                    llvm::LoopPassManager LPM;
                    // https://llvm.org/docs/Passes.html#indvars-canonicalize-induction-variables
                    LPM.addPass(IndVarSimplifyPass());
                    FPM.addPass(
                        llvm::createFunctionToLoopPassAdaptor(std::move(LPM)));
                    FPM.addPass(LoopUnrollFullOptPass());
                    FPM.addPass(SimplifyCFGPass());
                    return true;
                  }
                  return false;
                });
          }};
}
