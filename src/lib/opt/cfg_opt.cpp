#include "opt_passes.h"

using namespace llvm;
using namespace std;

uint64_t getInstCost(Instruction *I) {
  // terminator는 미포함
  auto instType = I->getType(); // br, ret, Store, Call에선 Null이라 쓰면 안 됨
  switch (I->getOpcode()) {
  case Instruction::Add:
  case Instruction::Sub:
    return instType->isVectorTy() ? 10 : 5;

  case Instruction::Shl:
  case Instruction::LShr:
  case Instruction::AShr:
  case Instruction::And:
  case Instruction::Or:
  case Instruction::Xor:
  case Instruction::ExtractElement: // vextct
  case Instruction::InsertElement:
    return instType->isVectorTy() ? 8 : 4; // vupdate

  case Instruction::UDiv:
  case Instruction::SDiv:
  case Instruction::URem:
  case Instruction::SRem:
  case Instruction::Mul:
  case Instruction::ICmp:
  case Instruction::Select:
    return instType->isVectorTy() ? 2 : 1;

  case Instruction::Load:
  case Instruction::Store: {
    Type *accessType = I->getAccessType(); // load가 가져온 값 or store가 저장한
                                           // 값의 Type을 가져옴
    Instruction *allocInst;

    if (auto loadInst = dyn_cast<LoadInst>(I))
      allocInst = dyn_cast<Instruction>(loadInst->getPointerOperand());
    else if (auto storeInst = dyn_cast<StoreInst>(I))
      allocInst = dyn_cast<Instruction>(storeInst->getPointerOperand());

    if (allocInst->getOpcode() == Instruction::Alloca)
      return accessType->isVectorTy() ? 60 : 30;
    else // Alloca가 아니면 Heap
      return accessType->isVectorTy() ? 100 : 50;
  } // case Load, Store end

  case Instruction::Call: { // assertion은 0이니 안넣음
    auto callInst = dyn_cast<CallInst>(I);
    if (auto calledFunction =
            callInst->getCalledFunction()) { // Indirect calls, Inline
                                             // Assembly면 nullptr
      auto name = calledFunction->getName();

      // Arithmetic incr, decr, const
      if (name.starts_with("incr_i") || name.starts_with("decr_i") ||
          name.starts_with("const_i64")) {
        return 1;
      }
      // Parallel vector
      else if (name.starts_with("vpicmp_") || name.starts_with("vpselect_") ||
                name.starts_with("vpmul_") || name.starts_with("vpudiv_") ||
                name.starts_with("vpsdiv_") || name.starts_with("vpurem_") ||
                name.starts_with("vpurem_") || name.starts_with("vpsrem_")) {
        return 2;
      } else if (name.starts_with("vpand_") || name.starts_with("vpor_") ||
                  name.starts_with("vpxor_")) {
        return 8;
      } else if (name.starts_with("vpadd_") || name.starts_with("vpsub_")) {
        return 10;
      }
      // Element-wise vector
      else if (name.starts_with("vincr_i") || name.starts_with("vdecr_i")) {
        return 2;
      }
      // Broadcast vector
      else if (name.starts_with("vbcast_i")) {
        return 4;
      } else if (name == "malloc" || name == "free")
        return 150;
      
      // 위의 함수에 포함되지 않는 일반적인 call
      if (callInst->isTailCall()) { // rcall
        return 10;
      } else { // function call인 경우.
        return 30;
      }
    }
  
  } // case Call end
  default:
    return 0; // zext 같이 cost가 명시되지 않은 경우
  } // Switch end
}

// Function &F에서 Condition을 만족하는 BB의 vector(stack)을 반환하는 DFS
// 현재는 BB 하나만을 받아서 bool을 반환하는 함수만 사용가능
vector<BasicBlock *> DFSWithCondition(Function &F,
                                      function<bool(BasicBlock *)> Condition) {
  stack<BasicBlock *> Stack;
  set<BasicBlock *> Visited;
  vector<BasicBlock *> ConditionBlocks;

  Stack.push(&F.getEntryBlock());
  while (!Stack.empty()) {
    BasicBlock *Curr = Stack.top();
    Stack.pop();

    if (Visited.find(Curr) ==
        Visited.end()) { // Visited하지 않은 BasicBlock인 경우에만 아래 수행
      Visited.insert(Curr);
      if (Condition(Curr)) // Condition 만족하면 추가
        ConditionBlocks.push_back(Curr);
      // 현재 BasicBlock의 Successor 중 Visited에 없는 것만 추가
      for (auto SI = succ_begin(Curr), E = succ_end(Curr); SI != E; ++SI) {
        if (Visited.find(*SI) == Visited.end())
          Stack.push(*SI);
      }
    }
  }
  return ConditionBlocks; // 아무것도 포함 안 될 경우 그냥 빈 vector를 반환하니,
                          // .empty()로 체크하면 됨
}

/* 현재는 사용하지 않음
bool isBlockInLoop(const BasicBlock *BB, LoopInfo & LI){
  return LI.getLoopFor(BB) != nullptr;
}*/

// conditional branch의 두 label이 같으면 unconditional로 변경하는 메서드
void replaceSameConditionalBranchesWithUnconditional(Function &F) {
  for (BasicBlock &BB : F) {
    if (auto branchInst = dyn_cast<BranchInst>(BB.getTerminator())) {
      if (branchInst->isConditional()) {
        auto trueTarget = branchInst->getSuccessor(0);
        if (trueTarget == branchInst->getSuccessor(1)) {
          IRBuilder<> Builder(branchInst);
          Builder.CreateBr(trueTarget);
          branchInst->eraseFromParent();
          /*dbgs() << "MyDebug: Replacing a conditional branch with an "
                    "unconditional branch in BasicBlock '"
                 << BB.getName() << "'\n";*/
        }
      }
    }
  }
}

// Used in 1. case
bool isUniqueSuccAndHasUniquePred(BasicBlock *BB) {
  if (auto pred = BB->getUniquePredecessor())
    if (pred->getUniqueSuccessor())
      return true;
  return false;
}

// Used in 2. case
bool willMergeWithPredHadConditionalBranch(BasicBlock *BB) {
  bool isOnlyOnePred =
      BB->hasNPredecessors(1); // BB가 하나의 Predecessor를 가지는지
  bool isOnlyOneSucc =
      (BB->getUniqueSuccessor() != nullptr); // BB가 하나의 Successor을 가지는지
  bool isPredHasTwoSucc = false; // Predecessor가 오직 두 개의 Successor를
                                 // Conditional Branch로 분기하고 있는지
  bool isNiceToMerge = false; // BB의 Instruction의 cost 합이 Merge하기 충분히 작은지
                              // 또한 Store나 recursive call이 있으면 합치지 않는다

  if (isOnlyOnePred) {
    auto pred = BB->getUniquePredecessor();
    if (auto predBranchInst = dyn_cast<BranchInst>(pred->getTerminator()))
      isPredHasTwoSucc = predBranchInst->isConditional();
  }

  uint64_t cost = 0;
  for (Instruction &I : *BB) {
    if (isa<PHINode>(I))
      continue; // PHINode면 pass
    if (I.isTerminator())
      continue;
    if (isa<StoreInst>(I))
      return false; // store가 하나라도 있으면 건드리지 않음
    auto opC = I.getOpcode();
    if (opC == Instruction::URem || opC == Instruction::SRem || opC == Instruction::UDiv || opC == Instruction::SDiv)
      return false; // 디버깅 결과 0으로 나누는 해당 연산들이 합쳐지는 경우 0이 아닌 케이스에서만 나누어지던 것이
    // 0으로 나누어지는 케이스가 존재하게 되어버림. 따라서 제거하였음
    if (isa<CallInst>(I)){ // Callee에 따라 UB가 어디서 나올지 모르므로 섣불리 합칠 수 없음
      return false;
    } 
    // *malloc이나 free같은 것은 합칠 때 문제가 확실히 있을지 불확실하여 
    // 따로 쓰지 않았음. 그러나 둘은 getInstCost에서 이미 30을 넘겨서,
    // 현재도 병합 제외 대상임
    cost += getInstCost(&I);
  }
  if (cost <= 30)
    isNiceToMerge = true; // * cost를 바꾸려면 여기서 변경. 굳이 바꾼다면 <= 60?

  return isOnlyOnePred && isOnlyOneSucc && isPredHasTwoSucc && isNiceToMerge;
}

// 기존에 library에 있는 MergeBlockIntoPredecessor를 custom.
// 목적: 현 project 전제하에서 필요 없는 부분 제거 & 더 많은 경우를 합칠 수 있게
// 만들고자 함. 전제: Unique한 Pred, Succ을 갖는 BB && Pred의 terminator가
// conditional branch.
bool MergeBlockIntoPredecessorCustom(BasicBlock *BB, LoopInfo *LI = nullptr) {
  BasicBlock *PredBB = BB->getUniquePredecessor();
  if (PredBB == BB)
    return false; // self-loops 제외
  BasicBlock *NewSucc = BB->getUniqueSuccessor();
  BranchInst *PredBB_BI = dyn_cast<BranchInst>(PredBB->getTerminator());
  unsigned WhatPath = PredBB_BI->getSuccessor(0) == BB 
                          ? 0
                          : 1; // 0이면 True label이, 1이면 False label이 BB
  auto PredCond = PredBB_BI->getCondition();
  auto BBName = BB->getName();
  auto PredBBName = PredBB->getName();

  if (isa<PHINode>(BB->front())) // PHI로 시작하는 경우에 single entry가
                                 // 보장되므로 모두 접어버림
    FoldSingleEntryPHINodes(BB);

  // Update PredBB's BranchInstruction to BB's Successor
  PredBB_BI->setSuccessor(WhatPath, NewSucc);

  // Move all definitions in the BB to the PredBB
  PredBB->splice(PredBB->getTerminator()->getIterator(), BB, BB->begin(),
                 BB->getTerminator()->getIterator());

  // PredBB가 가리키는 두 label이 모두 같게 된 경우 unconditional로 변환.
  // 이 경우 해당 BasicBlock(NewSucc)이 BB와 PredBB의 PHINode를 갖고
  // 있었다면 select로 변환해준다
  // -> 차후 다시 unconditional을 합칠 때 오류가 생기지 않게 하기 위함
  if (PredBB_BI->getSuccessor(0) == PredBB_BI->getSuccessor(1)) {
    IRBuilder<> Builder(PredBB_BI);
    auto NewBr = Builder.CreateBr(NewSucc);
    PredBB_BI->eraseFromParent();

    if (isa<PHINode>(NewSucc->front())) { // NewSucc에 PHI가 있는 경우
      vector<PHINode *> NeedToDelete;
      for (PHINode &PN : NewSucc->phis()) {
        bool hasBB = false;
        bool hasPredBB = false;

        for (unsigned i = 0, e = PN.getNumIncomingValues(); i != e; ++i) {
          auto nowBB = PN.getIncomingBlock(i);
          if (nowBB == BB)
            hasBB = true;
          if (nowBB == PredBB)
            hasPredBB = true;
        }

        if (hasBB && hasPredBB) { // BB와 PredBB를 모두 가진 PHINode가 아닌
                                  // 경우에만 select문 추가, PHINode 변경 수행
          auto BBVal = PN.getIncomingValueForBlock(BB);
          auto PredBBVal = PN.getIncomingValueForBlock(PredBB);
          Builder.SetInsertPoint(NewBr);
          Value *NewVal;
          if (WhatPath == 0)
            NewVal = Builder.CreateSelect(PredCond, BBVal, PredBBVal);
          else
            NewVal = Builder.CreateSelect(PredCond, PredBBVal, BBVal);
          PN.removeIncomingValue(BB); // BB로 오는 부분 제거
          PN.setIncomingValueForBlock(PredBB,
                                      NewVal); // PredBB에서 오는 값을 재설정
          
          // 만약 label이 PredBB밖에 없게 되었다면
          if (PN.getNumIncomingValues() == 1) 
            NeedToDelete.push_back(&PN);
        }
      }
      while (!NeedToDelete.empty()) {
        auto *phi = NeedToDelete.back();
        Value *ChangeVal = phi->getIncomingValue(0);//= NewVal = select Inst.
        auto phiName = phi->getName();
        phi->replaceAllUsesWith(ChangeVal);
        phi->eraseFromParent();
        ChangeVal->setName(phiName);
        NeedToDelete.pop_back();
      }
    }
  }

  // Update LoopInfo
  if (LI) LI->removeBlock(BB);

  // Delete BB
  BB->replaceAllUsesWith(PredBB); // BB를 사용하던 PHI nodes를
                                    // 모두 PredBB를 사용하게 바꿈
  BB->eraseFromParent();

  //dbgs() << "Merged " << BBName << " into " << PredBBName << "\n";
  return true;
}

PreservedAnalyses CFGOptPass::run(Function &F, FunctionAnalysisManager &FAM) {
  // 0. 먼저 conditional은 항상 서로 다른 label을 가리키고, 
  // 1개의 label을 가리키면 항상 unconditional이도록
  // conditional인데 가리키는 label이 같을 경우를 아예 제거
  replaceSameConditionalBranchesWithUnconditional(F);

  // BasicBlock을 predecessor에 붙여도 되는 케이스 모두 찾아 붙이기
  // 1. BB가 Predecessor의 unique Successor이고,
  // BB의 Predecessor도 unique한 경우
  // => BB를 Predecessor에 병합
  auto DFSResult = DFSWithCondition(F, isUniqueSuccAndHasUniquePred);
  while (!DFSResult.empty()) {
    BasicBlock *curr = DFSResult.back();
    MergeBlockIntoPredecessor(curr);
    DFSResult.pop_back();
  }

  // 2. BB가 Unique Predecessor & Successor 를 가지나,
  // 이 Predecessor가 Successor를 딱 두 개 가지는 경우(conditional br)
  // => branch의 condition을 이용, BB를 Predecessor에 합치는 것이 논리적으로 가능
  // *단 합쳐서 증가하는 cost가 br을 아껴서 얻는 것보다 더 작을 수 있으니
  // 경우를 잘 따져야 함

  // ScalarEvolution &SE = FAM.getResult<ScalarEvolutionAnalysis>(F);
  LoopInfo &LI = FAM.getResult<LoopAnalysis>(F);
  DFSResult = DFSWithCondition(F, willMergeWithPredHadConditionalBranch);
  while (!DFSResult.empty()) {
    BasicBlock *curr = DFSResult.back();
    // LoopInfo 상으로 서로 다른 loop에 속하는 BB를 합치는 것은
    // 위험하니 한 번 더 거름
    if (LI.getLoopFor(curr) == LI.getLoopFor(curr->getUniquePredecessor())) {
      MergeBlockIntoPredecessorCustom(curr, &LI);
    }
    DFSResult.pop_back();
  }

  // 3. 2로 인하여 생겼을 수 있는 추가적인 unconditional branch 합치기 가능한
  // 케이스 붙이기 (1을 다시 수행)
  DFSResult = DFSWithCondition(F, isUniqueSuccAndHasUniquePred);
  while (!DFSResult.empty()) {
    BasicBlock *curr = DFSResult.back();
    MergeBlockIntoPredecessor(curr);
    DFSResult.pop_back();
  }

  return PreservedAnalyses::none();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "CFGOptPass", "v1.0", [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "cfg_opt") {
                    FPM.addPass(CFGOptPass());
                    return true;
                  }
                  return false;
                });
          }};
}
