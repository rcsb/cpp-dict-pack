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

####################  SDB Generation ############################

# The trick here to break parallelism is to depend on prior SDB before continuing
function(BUILD_SDB DICTNAME DICTLIST)
  # Convert list comming in to proper list
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
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bin/CreateDictSdbFile.csh ${DICTNAME}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bin/CreateDictSdbFile.csh ${GEN_OUTPUTS}  "DictToSdb" "sdb_dir" "mmcif_ddl_dic" ${_EXTRADEP}
    COMMENT "Building SDB file for ${DICTNAME}"
    )

  add_custom_target(${DICTNAME}_sdb
    DEPENDS sdb/${DICTNAME}.sdb ${DICTNAME}_dic 
    )

endfunction()

# Command to ensure sdb directory exists
add_custom_target("sdb_dir" ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory sdb)

####################  ODB Generation ############################

# Command to ensure odb directory exists
add_custom_target("odb_dir" ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory odb)

function(BUILD_ODB DICTNAME)
  add_custom_command(
    OUTPUT odb/${DICTNAME}.odb odb/${DICTNAME}.log
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bin/CreateDictObjFile.csh ${DICTNAME}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bin/CreateDictObjFile.csh "DictObjFileCreator" odb_dir ${DICTNAME}_sdb sdb/${DICTNAME}.sdb
    COMMENT "Building ODB file for ${DICTNAME}"
    )

  add_custom_target(${DICTNAME}_odb
    DEPENDS odb/${DICTNAME}.odb sdb/${DICTNAME}.sdb
    )
endfunction(BUILD_ODB)


####################  XML Generation ############################
function(BUILD_XML DICTNAME)
  set(GEN_COMMAND
    ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/getdictversion.py
    --dict-file ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${DICTNAME}/${DICTNAME}.dic
    --print-xsdname
    )

  execute_process(
    COMMAND ${GEN_COMMAND}
    OUTPUT_VARIABLE DICT_VERS
    RESULT_VARIABLE RET
    )

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the ${DICTNAME} version " ${RET})
  endif()

  message(STATUS "Dictionary version for ${DICTNAME} is ${DICT_VERS}")

  # Conditional naming...
  

  add_custom_command(
    OUTPUT xml_v50/${DICTNAME}.log xml_v50/${DICT_VERS}
    # xsd versioned...
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/bin/Dict2XMLSchema.csh ${DICTNAME} v50
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bin/Dict2XMLSchema.csh "Dict2XMLSchema" xml_v50_dir ${DICTNAME}_odb odb/${DICTNAME}.odb
    COMMENT "Building XML_V50 file for ${DICTNAME}"
    )

  add_custom_target(${DICTNAME}_xml
    DEPENDS xml_v50/${DICTNAME}.log odb/${DICTNAME}.odb
    )
endfunction(BUILD_XML)


# Command to ensure xml_v50 directory exists
add_custom_target("xml_v50_dir" ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory xml_v50)

####################################
# Should build XML support for this dictionary
function(SHOULD_SUPPRESS_XML DICTNAME RET_VALUE)
  set(GEN_COMMAND
    ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/getdictinfo.py
    --dictname ${DICTNAME}
    --print-suppress-xml
    )

  execute_process(
    COMMAND ${GEN_COMMAND}
    OUTPUT_VARIABLE DICT_SUPP
    RESULT_VARIABLE RET
    )

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the $DICTNAME suppress XML " ${RET})
  endif()

  # message(STATUS "Suppress XML ${DICTNAME} is ${DICT_SUPP}")

  set(${RET_VALUE} ${DICT_SUPP} PARENT_SCOPE)

endfunction(SHOULD_SUPPRESS_XML)
