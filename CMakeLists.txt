

cmake_minimum_required(VERSION 3.28.0)
project(swpp-compiler VERSION 2024.1.13)



# check if Doxygen is installed
find_package(Doxygen)
if (DOXYGEN_FOUND)
    # set input and output files
    set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
    set(DOXYGEN_OUT ${CMAKE_CURRENT_SOURCE_DIR}/docs/Doxyfile)

    # request to configure the file
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    message("Doxygen build started")

    add_custom_target(docs ALL
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM )
else (DOXYGEN_FOUND)
  message("Doxygen should be installed to generate the doxygen documentation")
endif (DOXYGEN_FOUND)

enable_testing()

# Add tests, subdirectories, etc below

add_subdirectory(src)
add_subdirectory(test)

message("CMAKE_SOURCE_DIR : ${CMAKE_SOURCE_DIR}")


# Define a test for each .ll file
file(GLOB_RECURSE TEST_FILES "${CMAKE_SOURCE_DIR}/test/*.ll")
foreach(file ${TEST_FILES})
    get_filename_component(filename ${file} NAME_WE)
    string(REGEX REPLACE "@.*" "" front_part ${filename})

    add_test(NAME ${file}
             COMMAND ${CMAKE_SOURCE_DIR}/FileTestForPass.sh ${file} ${front_part} ${CMAKE_SOURCE_DIR} ${LLVM_ROOT}
             WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endforeach()



