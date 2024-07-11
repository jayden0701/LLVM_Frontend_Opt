#include "opt_passes.h"

using namespace llvm;
using namespace std;

// op1, op2가 Constant일 때 둘의 값이 같은지 확인하는 함수
bool isSameConstant(Value* op1, Value* op2){
  if(isa<ConstantInt>(op1) && isa<ConstantInt>(op2)){
    auto C1 = dyn_cast<ConstantInt>(op1);
    auto C2 = dyn_cast<ConstantInt>(op2);
    return C1->getValue() == C2->getValue();
  }
  return false;
}

// incr, decr 삽입 여부 판정 시 사용하는 함수
// ConstantInt의 값이 min<CI<max 인지 확인
bool isValueInRange(const ConstantInt* CI, int64_t min, int64_t max){
  auto val = CI->getValue();
  if (val.isNegative()) return val.sgt(min);
  return val.slt(max);
}

// 변환 대상인 Instruction I가 들어왔을 때, I의 앞에 적절한 I를 대체할 연산을 삽입
// 대상인 I가 아닐 때 false를 반환
bool insertInstBeforeThis(Instruction* I, Function& F){
  // 사전 체크
  if (I->isTerminator()) return false;
  if (isa<PHINode>(I) || isa<CallInst>(I)) return false;

  IRBuilder<> Builder(I);
  // 3항 연산자는 따로
  if (auto selInst = dyn_cast<SelectInst>(I)){
    auto cond = selInst->getCondition();
    // condition이 true, false인 경우의 최적화
    if (auto condVal = dyn_cast<ConstantInt>(cond)){
      auto opTrue = selInst->getTrueValue();
      auto opFalse = selInst->getFalseValue();
      if (condVal->getZExtValue() == 1)
        I->replaceAllUsesWith(opTrue);
      else 
        I->replaceAllUsesWith(opFalse);
      return true;
    }
    return false;
  }

  if(I->getNumOperands() != 2) return false;
  // 여기부터 2항 연산자들만
  Value* op1 = I->getOperand(0);
  Value* op2 = I->getOperand(1);
  auto type = op1->getType();
  auto opc = I->getOpcode();
  if(type->isPointerTy()) return false; // ptr 연산은 제외
  if(op1 == op2 || isSameConstant(op1, op2)){ // 두 operand가 같은 경우(상수 포함)
    switch(opc){
      case Instruction::Add:{
        auto newI = Builder.CreateMul(op1, ConstantInt::get(type, 2));
        I->replaceAllUsesWith(newI);
        return true;
      }

      case Instruction::Sub:
      case Instruction::URem:
      case Instruction::SRem:
      case Instruction::Xor:{
        I->replaceAllUsesWith(ConstantInt::get(type, 0));
        return true;
      }
      
      case Instruction::UDiv:
      case Instruction::SDiv:{
        I->replaceAllUsesWith(ConstantInt::get(type, 1));
        return true;
      }

      case Instruction::And:
      case Instruction::Or:{
        I->replaceAllUsesWith(op1);
        return true;
      }

      case Instruction::ICmp:{
        if(auto cmpInst = dyn_cast<ICmpInst>(I)){
          switch(cmpInst->getPredicate()){
            case ICmpInst::ICMP_EQ:
            case ICmpInst::ICMP_SGE:
            case ICmpInst::ICMP_UGE:
            case ICmpInst::ICMP_SLE:
            case ICmpInst::ICMP_ULE:{
              I->replaceAllUsesWith(ConstantInt::get(IntegerType::get(F.getContext(), 1), 1));
              return true;
            }

            case ICmpInst::ICMP_NE:
            case ICmpInst::ICMP_SGT:
            case ICmpInst::ICMP_UGT:
            case ICmpInst::ICMP_SLT:
            case ICmpInst::ICMP_ULT:{
              I->replaceAllUsesWith(ConstantInt::get(IntegerType::get(F.getContext(), 1), 0));
              return true;
            }

            default: return false;
          } // inner case end
        }
      }
      default: return false;
    } // outer case end
  }
  else{ // Operand가 서로 같지 않은 경우
    auto *intType = dyn_cast<IntegerType>(type);
    uint64_t bitWidth = intType->getBitWidth();
    auto c1 = dyn_cast<ConstantInt>(op1);
    auto c2 = dyn_cast<ConstantInt>(op2);
    if(c1 && c2) return false; // 둘 다 상수인 경우는 ConstantFolding을 해야지 이걸 하면 안됨

    if (opc == Instruction::Add){
      auto c = c1 ? c1: c2;      // 둘 다 변수인 경우도 고려됨
      auto op = (c == c1) ? op2 : op1; // 상수가 아닌 변수
      if(c && isValueInRange(c, -5, 5)){
        int64_t cVal = c->getSExtValue();
        if (cVal == 0){
          I->replaceAllUsesWith(op);
          return true;
        }
        uint64_t callCount = cVal < 0 ? -cVal : cVal; 
        vector<Type*> args;
        args.push_back(type);
        FunctionType* funcTy = FunctionType::get(type, args, false);
        FunctionCallee callee = cVal < 0 
          ? F.getParent()->getOrInsertFunction("decr_i"+std::to_string(bitWidth), funcTy)
          : F.getParent()->getOrInsertFunction("incr_i"+std::to_string(bitWidth), funcTy);
        CallInst *final = Builder.CreateCall(callee, {op});
        for (uint64_t i = 0; i < callCount-1; i++){
          final = Builder.CreateCall(callee, {final});
        }
        I->replaceAllUsesWith(final);
        return true;
      } 
      return false; 
    }
    else if (opc == Instruction::Sub){
      if (c2 && isValueInRange(c2, -5, 5)){
        int64_t c2Val = c2->getSExtValue();
        if (c2Val == 0){ // c2 == 0이면 CreateCall하면 안 됨
          I->replaceAllUsesWith(op1);
          return true;
        }
        uint64_t callCount = c2Val < 0 ? -c2Val : c2Val; 
        vector<Type*> args;
        args.push_back(type);
        FunctionType* funcTy = FunctionType::get(type, args, false);
        FunctionCallee callee = c2Val < 0 
          ? F.getParent()->getOrInsertFunction("incr_i"+std::to_string(bitWidth), funcTy)
          : F.getParent()->getOrInsertFunction("decr_i"+std::to_string(bitWidth), funcTy);
        CallInst *final = Builder.CreateCall(callee, {op1});
        for (uint64_t i = 0; i < callCount-1; i++){
          final = Builder.CreateCall(callee, {final});
        }
        I->replaceAllUsesWith(final);
        return true;
      }
      return false;
    }
    else if (opc == Instruction::Shl){
      if (c2){
        uint64_t shamt = c2->getZExtValue(); // Shift 연산에서 2nd operand는 늘 unsigned 취급
        if (shamt == 0){
          I->replaceAllUsesWith(op1);
          return true;
        }
        if (bitWidth <= shamt){ // 계산값이 늘 0이 되어버리는 경우
          I->replaceAllUsesWith(ConstantInt::get(type, 0));
          return true;
        }
        // Shl에선 overflow handling을 위해서 mul로 바로 바꾸지 않고 urem + mul로 구성한다
        // => 안 해도 된다. shift 2nd operand에 (i32면) 0~32 초과하는 게 들어오면 UB라서
        // 그런 경우는 input으로 없다고 가정해도 된다.
        uint64_t mulVal = std::pow(2, shamt);
        Value* newI = Builder.CreateMul(op1, ConstantInt::get(type, mulVal));
        I->replaceAllUsesWith(newI);
        return true;
      }
      return false;
    }
    else if (opc == Instruction::LShr){
      if (c2){
        uint64_t shamt = c2->getZExtValue(); // Shift 연산에서 2nd operand는 늘 unsigned 취급
        if (shamt == 0){
          I->replaceAllUsesWith(op1);
          return true;
        }
        if (bitWidth <= shamt){ // 계산값이 늘 0이 되어버리는 경우
          I->replaceAllUsesWith(ConstantInt::get(type, 0));
          return true;
        }
        uint64_t new2ndval = std::pow(2, shamt);
        auto newI = Builder.CreateUDiv(op1, ConstantInt::get(type, new2ndval));
        I->replaceAllUsesWith(newI);
        return true;
      }
      return false;
    }
    else if (opc == Instruction::AShr){
      if (c2){
        uint64_t shamt = c2->getZExtValue(); // Shift 연산에서 2nd operand는 늘 unsigned 취급
        if (shamt == 0){
          I->replaceAllUsesWith(op1);
          return true;
        }
        // Alive2 테스트 결과 Ashr->SDiv는 항상 예외가 존재하게 됨. optimize에서 제외
        /*
        if (bitWidth <= shamt + 1){
          return false; // overflow handling : Ashr은 부호를 유지하기에 이 경우 무엇으로 바뀔지 알 수 없음
          // 이 경우 아예 바꾸는 것을 포기함.
          // srem을 잘 이용한다면 가능할지도 모르나 아직 미상
        }
        uint64_t new2ndval = std::pow(2, shamt);
        auto newI = Builder.CreateSDiv(op1, ConstantInt::get(type, new2ndval));
        I->replaceAllUsesWith(newI);
        return true;*/
      }
      return false;
    }
    else if (opc == Instruction::And){
      if (intType && intType->getBitWidth() == 1){
        auto newI = Builder.CreateMul(op1, op2);
        I->replaceAllUsesWith(newI);
        return true;
      }
      if (c2){
        uint64_t c2Val = c2->getZExtValue();
        if (c2Val == 0){
          I->replaceAllUsesWith(ConstantInt::get(type, 0));
          return true;
        }
        if (c2Val == pow(2,bitWidth)-1){ // i64인 경우 2^64-1의 값이라면 그냥 op1이 값
          I->replaceAllUsesWith(op1);
          return true;
        }
        if (((c2Val+1)&c2Val) == 0){ // c2 값이 2^n-1인 경우
          auto newI = Builder.CreateURem(op1, ConstantInt::get(type, c2Val+1));
          I->replaceAllUsesWith(newI);
          return true;
        }
      }
      return false;
    }
    else if (opc == Instruction::Or){
      if (intType && intType->getBitWidth() == 1){
        auto newI = Builder.CreateSelect(op1, ConstantInt::get(type, 1), op2);
        I->replaceAllUsesWith(newI);
        return true;
      }
      return false;
    }
    else if (opc == Instruction::Xor){
      if (intType && intType->getBitWidth() == 1){
        auto newI = Builder.CreateICmpNE(op1, op2);
        I->replaceAllUsesWith(newI);
        return true;
      }
      return false;
    }
  }
  return false;
}

PreservedAnalyses ArithOptPass::run(Function &F, FunctionAnalysisManager &FAM) {
  bool isChanged = true;
  while(isChanged){
    // change가 하나도 일어나지 않을 때까지 하다 종료됨 
    isChanged = false;
    for (inst_iterator I = inst_begin(F), E = inst_end(F); I !=E;){
      Instruction* nowI = &*I;
      ++I; // nowI를 지워도 이제 상관없음
      if(insertInstBeforeThis(nowI, F)){
        nowI->eraseFromParent();
        isChanged = true;
      }
    }
  }
  return PreservedAnalyses::all();
}

extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "ArithOptPass", "v1.0", [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "arith_opt") {
                    FPM.addPass(ArithOptPass());
                    return true;
                  }
                  return false;
                });
          }};
}
