#ifndef OPTIMIZATION_PASSES_H
#define OPTIMIZATION_PASSES_H

#include <algorithm>
#include <cstdint>
#include <functional>
#include <set>
#include <stack>
#include <string>
#include <unordered_set>
#include <vector>
#include <unordered_set>
#include <tuple>

#include "llvm/Analysis/LoopAnalysisManager.h"
#include "llvm/Analysis/ConstantFolding.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"

#include "llvm/Analysis/PostDominators.h"


#include "llvm/Analysis/TargetTransformInfo.h"


#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Dominators.h"


#include "llvm/IR/Function.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"

#include "llvm/Pass.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/PromoteMemToReg.h"




#include "llvm/IR/Function.h"



// #include "llvm/Transforms/IPO/Inliner.h"
// #include "llvm/Transforms/IPO/ModuleInliner.h"
#include "llvm/Transforms/Utils/Cloning.h"



namespace llvm {

class ArithOptPass : public PassInfoMixin<ArithOptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class BranchOptimizationPass : public PassInfoMixin<BranchOptimizationPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class CFGOptPass : public PassInfoMixin<CFGOptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class GVoptPass : public PassInfoMixin<GVoptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

class ICMPPropagationPass : public PassInfoMixin<ICMPPropagationPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class RCallOptimizationPass : public PassInfoMixin<RCallOptimizationPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class StackAllocPass : public PassInfoMixin<StackAllocPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class ReassociationPass : public PassInfoMixin<ReassociationPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class InstructionCombinePass : public PassInfoMixin<InstructionCombinePass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class Alloca2RegPass : public PassInfoMixin<Alloca2RegPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};

class LoopUnrollFullOptPass : public PassInfoMixin<LoopUnrollFullOptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};



class FunctionInlinePass : public PassInfoMixin<FunctionInlinePass> {
public:
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
};


class FreeOptPass : public PassInfoMixin<FreeOptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};


class VectorizationOptPass : public PassInfoMixin<VectorizationOptPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};
  
class MakeSameOperandPass : public PassInfoMixin<MakeSameOperandPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
};


} // namespace llvm

#endif // OPTIMIZATION_PASSES_H
