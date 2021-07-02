# # Function to build a dictionary
# function(BUILD_DICT DICTNAME)
#   set(GEN_COMMAND
#     ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gendict.py
#     -s ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${DICTNAME}
#     -o ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${DICTNAME}
#     --dict-name ${DICTNAME}
#     )

#   execute_process(
#     COMMAND ${GEN_COMMAND} --print-dependencies
#     OUTPUT_VARIABLE GEN_DEPENDENCIES
#     RESULT_VARIABLE RET
#     )

#   if (NOT RET EQUAL 0)
#     message(FATAL_ERROR "Failed to get the $DICTNAME dependencies " ${RET})
#   endif()

#   #message(STATUS "Dependencies is " ${GEN_DEPENDENCIES})
  
#   execute_process(
#     COMMAND ${GEN_COMMAND} --print-outputs
#     OUTPUT_VARIABLE GEN_OUTPUTS
#     RESULT_VARIABLE RET
#     )

#   #message(STATUS "Outputs is " ${GEN_OUTPUTS})

#   if (NOT RET EQUAL 0)
#     message(FATAL_ERROR "Failed to get the GEN outputs" ${RET})
#   endif()

#   add_custom_command(
#     COMMAND ${GEN_COMMAND}
#     DEPENDS ${GEN_DEPENDENCIES} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gendict.py
#     OUTPUT ${GEN_OUTPUTS}
#     BYPRODUCTS ${GEN_OUTPUTS}
#     COMMENT "Generating the dictionary files for ${DICTNAME}."
#     )

#   add_custom_target("${DICTNAME}_dic" ALL
#     DEPENDS ${GEN_OUTPUTS}
#     )
#   # Remove explicitly directory
#   file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${DICTNAME})
# endfunction()

# The trick here to break parallelism is to depend on prior SDB before continuing
function(BUILD_SDB DICTNAME DICTLIST)
  # Convert list comming in toproper list
  set(_DICTLIST ${DICTLIST} ${ARGN})
  # Locate DICTNAME in list - so we can depend on prior
  list(FIND _DICTLIST ${DICTNAME} _DINDEX)
  # message("Dictionary index ${_DINDEX}")

  if (_DINDEX EQUAL -1)
    message(FATAL_ERROR "Failed to find dictionary in list ${DICTNAME}")
  endif()

  # Depend on custom_target to ensure proper dependency order. We use the n-1 sdb.
  # See https://cmake.org/pipermail/cmake/2008-October/024492.html
  set(_EXTRADEP)
  if (NOT _DINDEX EQUAL 0)
    MATH(EXPR _DINDEX "${_DINDEX}-1")
    list(GET _DICTLIST ${_DINDEX} _EXTRA)
    set(_EXTRADEP "${_EXTRA}_sdb")
  endif()
  # message("Extra dependency is ${_EXTRADEP}")

  
  set(GEN_COMMAND
    ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gendict.py
    -s ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${DICTNAME}
    -o ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${DICTNAME}
    --dict-name ${DICTNAME}
    )

  # Get name of dictionary to depend on
  execute_process(
    COMMAND ${GEN_COMMAND} --print-outputs
    OUTPUT_VARIABLE GEN_OUTPUTS
    RESULT_VARIABLE RET
    )

  # message(STATUS "Generated dependency is " ${GEN_OUTPUTS})

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the GEN outputs" ${RET})
  endif()

  add_custom_command(
    OUTPUT sdb/${DICTNAME}.sdb sdb/${DICTNAME}.log
    COMMAND ./bin/CreateDictSdbFile.csh ${DICTNAME}
    DEPENDS ./bin/CreateDictSdbFile.csh ${GEN_OUTPUTS}  "DictToSdb" "sdb_dir" "mmcif_ddl_dic" ${_EXTRADEP}
    COMMENT "Building SDB file for ${DICTNAME}"
    )

  add_custom_target(${DICTNAME}_sdb
    DEPENDS sdb/${DICTNAME}.sdb ${DICTNAME}_dic 
    )

endfunction()

# Command to ensure sdb directory exists
add_custom_target("sdb_dir" ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory sdb)

