# Function to build a dictionary
function(BUILD_DICT DICTNAME)
  set(GEN_COMMAND
    ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gendict.py
    -s ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${DICTNAME}
    -o ${CMAKE_CURRENT_BINARY_DIR}/mmcif/${DICTNAME}
    --dict-name ${DICTNAME}
    )

  execute_process(
    COMMAND ${GEN_COMMAND} --print-dependencies
    OUTPUT_VARIABLE GEN_DEPENDENCIES
    RESULT_VARIABLE RET
    )

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the $DICTNAME dependencies " ${RET})
  endif()

  #message(STATUS "Dependencies is " ${GEN_DEPENDENCIES})
  
  execute_process(
    COMMAND ${GEN_COMMAND} --print-outputs
    OUTPUT_VARIABLE GEN_OUTPUTS
    RESULT_VARIABLE RET
    )

  #message(STATUS "Outputs is " ${GEN_OUTPUTS})

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the GEN outputs" ${RET})
  endif()

  add_custom_command(
    COMMAND ${GEN_COMMAND}
    DEPENDS ${GEN_DEPENDENCIES} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gendict.py
    OUTPUT ${GEN_OUTPUTS}
    BYPRODUCTS ${GEN_OUTPUTS}
    COMMENT "Generating the dictionary files for ${DICTNAME}."
    )

  add_custom_target(${DICTNAME} ALL
    DEPENDS ${GEN_OUTPUTS}
    )
  # Remove explicitly directory
  file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/mmcif/${DICTNAME})
endfunction()
