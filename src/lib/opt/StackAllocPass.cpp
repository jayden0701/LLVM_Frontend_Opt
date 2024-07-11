#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

class StackAllocPass : public PassInfoMixin<StackAllocPass> {
public:

  static const uint64_t MaxAllocaSize = 1024;

  // Function to detect recursion
  bool isRecursive(Function &F) {
    for (auto &BB : F) {
      for (auto &I : BB) {
        if (CallInst *CI = dyn_cast<CallInst>(&I)) {
          if (CI->getCalledFunction() == &F) {
            return true;
          }
        }
      }
    }
    return false;
  }

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    // Skip the pass if the function is recursive
    if (isRecursive(F)) {
      return PreservedAnalyses::all();
    }

    bool modified = false;

    // Iterate over each basic block in the function
    for (auto &BB : F) {
      for (auto it = BB.begin(), end = BB.end(); it != end; ) {
        Instruction &I = *it++;
        
        // Identify malloc calls
        if (CallInst *CI = dyn_cast<CallInst>(&I)) {
          if (Function *Callee = CI->getCalledFunction()) {
            if (Callee->getName() == "malloc") {
              // Get the allocation size
              Value *AllocSize = CI->getArgOperand(0);
              
              // Check if the allocation size is a constant and within the threshold -> if not skip
              if (auto *ConstSize = dyn_cast<ConstantInt>(AllocSize)) {
                if (ConstSize->getZExtValue() > MaxAllocaSize) {
                  continue; 
                }
              }

              // Create alloca instruction
              IRBuilder<> Builder(CI);
              AllocaInst *Alloca = Builder.CreateAlloca(Builder.getInt8Ty(), AllocSize);
              
              // Replace uses of malloc call with the alloca
              CI->replaceAllUsesWith(Alloca);
              
              // Remove the original malloc call
              CI->eraseFromParent();
              
              modified = true;
            }
          }
        }
      }
    }

    // Remove any free calls -> necessary for decreasing UB when moving to the stack
    for (auto &BB : F) {
      for (auto it = BB.begin(), end = BB.end(); it != end; ) {
        Instruction &I = *it++;
        if (CallInst *CI = dyn_cast<CallInst>(&I)) {
          if (Function *Callee = CI->getCalledFunction()) {
            if (Callee->getName() == "free") {
              CI->eraseFromParent();
              modified = true;
            }
          }
        }
      }
    }
    return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }
};

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "StackAllocPass", "v1.1",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [&PB](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "StackAllocPass") {
                    FPM.addPass(StackAllocPass());
                    return true;
                  }
                  return false;
                });
          }};
}
