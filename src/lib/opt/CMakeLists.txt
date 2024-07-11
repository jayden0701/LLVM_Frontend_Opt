cmake_minimum_required(VERSION 3.28.0)

add_library(OptPasses INTERFACE)

llvm_map_components_to_libnames(pass_llvm_libs passes analysis core support)
function(add_opt_pass pass_name file_name)
    add_library(${pass_name} ${CMAKE_CURRENT_SOURCE_DIR}/${file_name})
    target_include_directories(${pass_name} PRIVATE ${LLVM_INCLUDE_DIRS})
    target_link_libraries(${pass_name} PRIVATE ${pass_llvm_libs})
    target_link_libraries(OptPasses INTERFACE ${pass_name})
endfunction()

# /================= ADD OPT PASSES BELOW ================/

# OJS : makesure to name the 1)pass_name in Cmakelist, 2) passname in the passname.cpp 
# 3) passname in testcase : passname@(num).ll !!!all same!!!


add_opt_pass(hello_world hello_world.cpp)
add_opt_pass(arith_opt arith_opt.cpp)
add_opt_pass(GVoptPass GVoptPass.cpp)
add_opt_pass(branch_opt branch_opt.cpp)
add_opt_pass(rcall_opt rcall_opt.cpp)
add_opt_pass(cfg_opt cfg_opt.cpp)
add_opt_pass(StackAllocPass StackAllocPass.cpp)
add_opt_pass(loop_unroll_full_opt loop_unroll_full_opt.cpp)
add_opt_pass(vectorization_opt vectorization_opt.cpp)
add_opt_pass(icmp_propagation icmp_propagation.cpp)
add_opt_pass(make_same_operand make_same_operand.cpp)

add_opt_pass(reassociation_pass reassociation_pass.cpp)
add_opt_pass(instruction_combine instruction_combine.cpp)
add_opt_pass(Alloca2RegOpt Alloca2RegOpt.cpp)


add_opt_pass(functioninline_opt functioninline_opt.cpp)

add_opt_pass(free_opt free_opt.cpp)

