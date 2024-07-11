
#include "opt_passes.h"

using namespace llvm;

bool checkDependencies(std::vector<Instruction *> scalarOps) {
  // data dependencies
  // 한 vector안에서 같은 메모리에 read, write을 동시에 할 수 없음.
  // read after write, write after read, write after write 다 거름
  for (size_t i = 0; i < scalarOps.size(); i++) {
    for (size_t j = i + 1; j < scalarOps.size(); j++) {
      Instruction *I = scalarOps[i];
      Instruction *J = scalarOps[j];
      // Check for write-after-write
      if (I->mayWriteToMemory() && J->mayWriteToMemory()) {
        if (I->getOperand(0) == J->getOperand(0)) {
          return false;
        }
      }
      // Check for read-after-write
      if (I->mayWriteToMemory() && J->mayReadFromMemory()) {
        if (I->getOperand(0) == J->getOperand(0)) {
          return false;
        }
      }
      // Check for write-after-read
      if (I->mayReadFromMemory() && J->mayWriteToMemory()) {
        if (I->getOperand(0) == J->getOperand(0)) {
          return false;
        }
      }
    }
  }
  return true;
}

bool checkVectorizable(std::vector<Instruction *> scalarOps) {
  return checkDependencies(scalarOps);
}

bool isVectorizablePattern(std::vector<Instruction *> &pattern,
                           const char *instName = "") {
  // 여러 패턴을 벡터화할 수 있겠지만 현실적인 이유로 가장 흔히 나오는 패턴만
  // 벡터화 시킴 스펙의 scalar operation은 다 대응되는 벡터연산이 있음
  // -> binary만 했습니다..
  //  c[i] = a[i] + b[i]
  //   %arrayidx = getelementptr inbounds [4 x i64], ptr %a, i64 0, i64 0
  //   %0 = load i64, ptr %arrayidx, align 16
  //   %arrayidx2 = getelementptr inbounds [4 x i64], ptr %b, i64 0, i64 0
  //   %1 = load i64, ptr %arrayidx2, align 16
  //   %add = add i64 %0, %1
  //   %arrayidx3 = getelementptr inbounds [4 x i64], ptr %c, i64 0, i64 0
  //   store i64 %add, ptr %arrayidx3, align 16
  static const std::unordered_set<std::string> validInstructions = {
      "add", "sub",  "mul",  "sdiv", "udiv", "srem", "urem",
      "shl", "ashr", "lshr", "and",  "or",   "xor",  ""};

  if (pattern.size() != 7)
    return false;

  if (validInstructions.find(instName) == validInstructions.end()) {
    return false;
  }

  if (strcmp(instName, "") != 0) {
    return isa<GetElementPtrInst>(pattern[0]) && isa<LoadInst>(pattern[1]) &&
           isa<GetElementPtrInst>(pattern[2]) && isa<LoadInst>(pattern[3]) &&
           (pattern[4]->getOpcodeName() == instName) &&
           isa<GetElementPtrInst>(pattern[5]) && isa<StoreInst>(pattern[6]);
  }
  return isa<GetElementPtrInst>(pattern[0]) && isa<LoadInst>(pattern[1]) &&
         isa<GetElementPtrInst>(pattern[2]) && isa<LoadInst>(pattern[3]) &&
         isa<BinaryOperator>(pattern[4]) &&
         isa<GetElementPtrInst>(pattern[5]) && isa<StoreInst>(pattern[6]);
}

// https://en.wikipedia.org/wiki/Automatic_vectorization
PreservedAnalyses VectorizationOptPass::run(Function &F,
                                            FunctionAnalysisManager &FAM) {
  bool modified = false;

  // outs() << F.getName() << "\n";
  // Collect operations that are potential candidates for vectorization
  for (auto &BB : F) {
    std::vector<Instruction *> scalarOps;

    for (auto &I : BB) {
      if (isa<BinaryOperator>(&I) || isa<LoadInst>(&I) || isa<StoreInst>(&I) ||
          isa<GetElementPtrInst>(&I)) {
        scalarOps.push_back(&I);
      }
    }

    if (scalarOps.size() >= 7) {
      for (size_t i = 0; i <= scalarOps.size() - 7; ++i) {
        std::vector<Instruction *> pattern(scalarOps.begin() + i,
                                           scalarOps.begin() + i + 7);
        if (!checkVectorizable(pattern)) {
          continue;
        }
        if (isVectorizablePattern(pattern)) {
          size_t repeatCount = 1;
          const char *instName = pattern[4]->getOpcodeName();
          while (i + 7 * repeatCount + 6 < scalarOps.size()) {
            std::vector<Instruction *> nextPattern(
                scalarOps.begin() + i + 7 * repeatCount,
                scalarOps.begin() + i + 7 * repeatCount + 7);

            if (isVectorizablePattern(nextPattern, instName)) {
              repeatCount++;
            } else {
              break;
            }
          }

          if (repeatCount > 1) {
            // pattern[0] 자리 대체
            IRBuilder<> Builder(pattern[0]);

            // a, b for load, c for store
            Value *aPtr = pattern[0]->getOperand(0);
            Value *bPtr = pattern[2]->getOperand(0);
            Value *cPtr = pattern[5]->getOperand(0);

            if (!aPtr->getType()->isPointerTy() ||
                !bPtr->getType()->isPointerTy() ||
                !cPtr->getType()->isPointerTy()) {
              errs() << "Error: Pointers are not of expected type\n";
              continue;
            }

            // repeat count 사이즈의 벡터
            Type *Int64Ty = Type::getInt64Ty(F.getContext());
            auto ElemCount = ElementCount::getFixed(repeatCount);
            VectorType *VecType = VectorType::get(Int64Ty, ElemCount);

            auto *aVecPtr =
                Builder.CreateBitCast(aPtr, VecType->getPointerTo());
            auto *bVecPtr =
                Builder.CreateBitCast(bPtr, VecType->getPointerTo());
            auto *cVecPtr =
                Builder.CreateBitCast(cPtr, VecType->getPointerTo());

            Value *vecA = Builder.CreateLoad(VecType, aVecPtr);
            Value *vecB = Builder.CreateLoad(VecType, bVecPtr);
            Value *vecC = nullptr;
            if (strcmp(instName, "add") == 0) {
              vecC = Builder.CreateAdd(vecA, vecB);
            } else if (strcmp(instName, "mul") == 0) {
              vecC = Builder.CreateMul(vecA, vecB);
            } else if (strcmp(instName, "sub") == 0) {
              vecC = Builder.CreateSub(vecA, vecB);
            } else if (strcmp(instName, "sdiv") == 0) {
              vecC = Builder.CreateSDiv(vecA, vecB);
            } else if (strcmp(instName, "udiv") == 0) {
              vecC = Builder.CreateUDiv(vecA, vecB);
            } else if (strcmp(instName, "srem") == 0) {
              vecC = Builder.CreateSRem(vecA, vecB);
            } else if (strcmp(instName, "urem") == 0) {
              vecC = Builder.CreateURem(vecA, vecB);
            } else if (strcmp(instName, "shl") == 0) {
              vecC = Builder.CreateShl(vecA, vecB);
            } else if (strcmp(instName, "ashr") == 0) {
              vecC = Builder.CreateAShr(vecA, vecB);
            } else if (strcmp(instName, "lshr") == 0) {
              vecC = Builder.CreateLShr(vecA, vecB);
            } else if (strcmp(instName, "and") == 0) {
              vecC = Builder.CreateAnd(vecA, vecB);
            } else if (strcmp(instName, "or") == 0) {
              vecC = Builder.CreateOr(vecA, vecB);
            } else if (strcmp(instName, "xor") == 0) {
              vecC = Builder.CreateXor(vecA, vecB);
            }
            Builder.CreateStore(vecC, cVecPtr);

            for (size_t k = 0; k < repeatCount; ++k) {
              // remove from back
              // 앞에서부터 제거하면 dependency 에러가 나는듯?
              for (size_t j = 7; j > 0; j--) {
                // outs() << "remove op: "
                //        << scalarOps[i + 7 * k + j - 1]->getOpcodeName() << "\n";
                scalarOps[i + 7 * k + j - 1]->eraseFromParent();
              }
            }

            // vectorize된 부분 skip
            i += 7 * (repeatCount - 1);
          }
        }
      }
    }
  }

  // Ensure that the function is still valid and all basic blocks have
  // terminators
  for (auto &BB : F) {
    if (!BB.getTerminator()) {
      IRBuilder<> Builder(&BB);
      Builder.CreateRetVoid();
    }
  }

  return modified ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "VectorizationOptPass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "vectorization_opt") {
                    FPM.addPass(VectorizationOptPass());
                    return true;
                  }
                  return false;
                });
          }};
}
