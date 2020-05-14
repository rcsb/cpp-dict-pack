cmake_minimum_required(VERSION 2.8.12)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(dict-pack LANGUAGES C CXX)


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

include(cmake/commonparser.cmake)

set(SOURCE_DIR_9  "modules/cpp-dict-to-html/src")
set(INCLUDE_DIR_9 "modules/cpp-dict-to-html/include")
set(BIN_DIR_9  "modules/cpp-dict-to-html/bin")
set(ICONS_DIR_9  "modules/cpp-dict-to-html/icons")
set(HTML_INCLUDES_DIR_9  "modules/cpp-dict-to-html/html-includes")
#

#

#
#  Build 'schema-map' library - not integrated in main library
#
set(SOURCES_8
             "${SOURCE_DIR_8}/SchemaDataInfo.C"
	     "${SOURCE_DIR_8}/SchemaMap.C"
	     "${SOURCE_DIR_8}/SchemaMapCreate.C"
	     "${SOURCE_DIR_8}/SchemaParentChild.C"
	     )
add_library("schema-map" STATIC ${SOURCES_8})
target_include_directories("schema-map" PUBLIC ${INCLUDE_DIR_8} ${BUILD_INCLUDE_DIR} ${BUILD_SOURCE_DIR})

#
#  Build 'dict2html' library - not integrated in combined
#  Build dict2HTML executable
#
set(SOURCES_9
             "${SOURCE_DIR_9}/demoGetArgs.C"
	     "${SOURCE_DIR_9}/htmlUtil.C"
	     )
add_library("dict2htmllib" STATIC ${SOURCES_9})
target_include_directories("dict2htmllib" PUBLIC ${INCLUDE_DIR_9} ${BUILD_INCLUDE_DIR})
add_executable("dict2HTML" "${SOURCE_DIR_9}/dict2HTML.C")
target_link_libraries("dict2HTML" "dict2htmllib" "mmciflib-all")
target_include_directories("dict2HTML" PUBLIC ${BUILD_INCLUDE_DIR})
file(INSTALL "${BIN_DIR_9}/DictToHTML.csh" DESTINATION bin)
file(GLOB HTML_ICONS_9 "${ICONS_DIR_9}/*.gif")
file(COPY ${HTML_ICONS_9} DESTINATION html/icons)
file(GLOB HTML_INCLUDES_9 "${HTML_INCLUDES_DIR_9}/*.txt")
file(COPY ${HTML_INCLUDES_9} DESTINATION html/html-includes)

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
  "/build/;/.bzr/;.git/;.gitmodules/;~$;${CPACK_SOURCE_IGNORE_FILES}")
include(CPack)
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)
