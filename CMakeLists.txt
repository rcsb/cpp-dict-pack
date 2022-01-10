cmake_minimum_required(VERSION 2.8.12)

message("Cmake version: ${CMAKE_VERSION}")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(BuildType)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(mmcif-dict-suite C CXX)

find_package(PythonInterp REQUIRED)

# Do we need all of these - none seem to be used
#set(mydefines " -DBIG_ENDIAN_PLATFORM  -DHAVE_STRCASECMP -DINCL_TEMPLATE_SRC -DHAVE_PLACEMENT_NEW  ")

# Normally we download/build a complete set of dictionaries (unless in distribution). If set, only a subset of dictionaries are uilt
option(MINIMAL_DICTS "If boolean is ON, then only compile a subset of dictionaries")
# In sourcdir/dicts present and dictionary present, it will be used.  Force download of all dictionaries
option(ALWAYS_DOWNLOAD_DICTS "If boolean is ON, then will download dictiobaries instead of using cached copy in distribution")

message(STATUS "Compiler flags " ${CMAKE_CXX_FLAGS})

#
# ---------------------------------------------------------------
#   WHERE AM I RUNNING
#
message(STATUS "---CMAKE MODULE PATH - " ${CMAKE_MODULE_PATH})
message(STATUS "---CMAKE SOURCE DIR  - " ${CMAKE_SOURCE_DIR})
message(STATUS "---CMAKE PROJECT DIR - " ${PROJECT_SOURCE_DIR})
# ---------------------------------------------------------------
#
set(BUILD_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
set(BUILD_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/include")
set(BUILD_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(BUILD_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/lib")
set(BUILD_HTML_DIR "${CMAKE_CURRENT_BINARY_DIR}/html")

file(MAKE_DIRECTORY ${BUILD_HTML_DIR})

# For extending installation of dict-obj-file programs
set(BUILD_DICT_PACK_SUPPORT 1)

include(cmake/commonparser.cmake)
# Build dict-pack tools
include(cmake/dictpack.cmake)
# Functions to build dictionaries
include(cmake/dictfunc.cmake)
# Functions to download dictionarys
include(cmake/dictdownload.cmake)

# Custom command to update git submodules
find_package(Git QUIET)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
  add_custom_target(checkout-modules ${GIT_EXECUTABLE} submodule update 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Updating submodules")
  set(MODULE_CHECKOUT_DEP checkout-modules)
endif()

# Will checkout specific dictionaries and modules
add_custom_target(checkout
  # COMMENT "CHECKOUT"
  DEPENDS ${MODULE_CHECKOUT_DEP})

#####################
# Build dictionaries

# List of dictionaries we are building.  EXTDICTS are built all the time.
# INTDICTS are not built in distribution.

set(EXTDICTS  mmcif_ddl mmcif_pdbx_v5_next mmcif_pdbx_v50)
set(INTDICTS)
if(NOT MINIMAL_DICTS)
  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/DictPackDist.txt)
    set(INTDICTS mmcif_pdbx_v40 mmcif_pdbx_v41 mmcif_pdbx_v42 mmcif_pdbx_v32 mmcif_pdbx_v31 mmcif_ihm mmcif_pdbx_vrpt mmcif_ma mmcif_biosync mmcif_ccp4 mmcif_em mmcif_img mmcif_ndb_ntc mmcif_nef mmcif_nmr-star mmcif_rcsb_nmr mmcif_rcsb_xray mmcif_sas mmcif_std mmcif_sym)
  endif()
endif()


set(_SDB_LIST)
set(_ODB_LIST)
set(_XML_LIST)
set(ALLDICTS ${EXTDICTS} ${INTDICTS})
foreach(DICT ${ALLDICTS})
  GET_DICTIONARY(${DICT})
  BUILD_SDB(${DICT} ${ALLDICTS})
  list(APPEND _SDB_LIST ${DICT}_sdb)

  # Determine if xml support needed for this dictionary
  SHOULD_SUPPRESS_XML(${DICT} RET)
  # message(STATUS "SUPPRESS ${RET}")
  if (${RET} STREQUAL "False")
    BUILD_ODB(${DICT})
    BUILD_XML(${DICT})

    list(APPEND _ODB_LIST ${DICT}_odb)
    list(APPEND _XML_LIST ${DICT}_xml)
  endif()
endforeach()

add_custom_target(sdb
  DEPENDS ${_SDB_LIST}
)

add_custom_target(odb
  DEPENDS ${_ODB_LIST}
)

add_custom_target(xml_v50
  DEPENDS ${_XML_LIST}
)



add_custom_target(everything
	DEPENDS ${DICTPACK_ALLEXE} sdb odb xml_v50
	)
#
#
# Distribution CPack configuration
#
set(CPACK_PACKAGE_VERSION_MAJOR "2")
set(CPACK_PACKAGE_VERSION_MINOR "50")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_SOURCE_GENERATOR "TBZ2;TGZ")
set(CPACK_SOURCE_PACKAGE_FILE_NAME
  "${CMAKE_PROJECT_NAME}-v${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}${CPACK_PACKAGE_VERSION_PATCH}-prod-src")
set(CPACK_SOURCE_IGNORE_FILES
  "/build/;/.bzr/;.git/;/.gitmodules;/.github/;/.gitignore;~$;/.*/.git;/.*/.svn;.idea/;${CPACK_SOURCE_IGNORE_FILES}")
# Inspired by https://jtanx.github.io/2019/08/22/cmake-dist-customisation/ package selected dictionaries
set(CPACK_INSTALL_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/CPackExtraDist.cmake")
  configure_file("${CMAKE_SOURCE_DIR}/cmake/ExtraDist.cmake.in" "CPackExtraDist.cmake" @ONLY)
include(CPack)
add_custom_target(dist
    COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target package_source
    # DEPENDS test_dependencies
    VERBATIM
    USES_TERMINAL
  )
