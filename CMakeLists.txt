cmake_minimum_required(VERSION 2.8.12)

message("Cmake version: ${CMAKE_VERSION}")

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(dict-pack LANGUAGES C CXX)

find_package(PythonInterp REQUIRED)

# Do we need all of these - none seem to be used
#set(mydefines " -DBIG_ENDIAN_PLATFORM  -DHAVE_STRCASECMP -DINCL_TEMPLATE_SRC -DHAVE_PLACEMENT_NEW  ")


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

# List of dictionaries we are building
set(EXTDICTS  mmcif_ddl mmcif_pdbx_v5_next mmcif_pdbx_v50 mmcif_ihm mmcif_pdbx_vrpt)

set(_SDB_LIST)
set(_ODB_LIST)
set(_XML_LIST)
foreach(DICT ${EXTDICTS})
  GET_DICTIONARY(${DICT})
  BUILD_SDB(${DICT} ${EXTDICTS})
  BUILD_ODB(${DICT})
  BUILD_XML(${DICT})  
  list(APPEND _SDB_LIST ${DICT}_sdb)
  list(APPEND _ODB_LIST ${DICT}_odb)
  list(APPEND _XML_LIST ${DICT}_xml)    
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
	DEPENDS sdb odb xml_v50
	)
#
#
# Distribution CPack configuration
#
set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "2")
set(CPACK_PACKAGE_VERSION_PATCH "3")
set(CPACK_SOURCE_GENERATOR "TBZ2")
set(CPACK_SOURCE_PACKAGE_FILE_NAME
  "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
set(CPACK_SOURCE_IGNORE_FILES
  "/build/;/.bzr/;.git/;/.gitmodules;/.github/;/.gitignore;~$;/.*/.git;/.*/.svn;${CPACK_SOURCE_IGNORE_FILES}")
include(CPack)
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)
