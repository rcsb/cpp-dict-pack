# Definitions to build the dict pack programs
set(SOURCE_DIR_9  "modules/cpp-dict-to-html/src")
set(INCLUDE_DIR_9 "modules/cpp-dict-to-html/include")
set(BIN_DIR_9  "modules/cpp-dict-to-html/bin")
set(ICONS_DIR_9  "modules/cpp-dict-to-html/icons")
set(HTML_INCLUDES_DIR_9  "modules/cpp-dict-to-html/html-includes")
#
set(SOURCE_DIR_10  "modules/cpp-misc-dict-util/src")
set(INCLUDE_DIR_10 "modules/cpp-misc-dict-util/include")
set(BIN_DIR_10  "modules/cpp-misc-dict-util/bin")
#
set(SOURCE_DIR_11  "modules/cpp-pdbml/src")
set(INCLUDE_DIR_11 "modules/cpp-pdbml/include")
#
set(SOURCE_DIR_12  "modules/cpp-misc-xml-util/src")
set(INCLUDE_DIR_12 "modules/cpp-misc-xml-util/include")
set(BIN_DIR_12 "modules/cpp-misc-xml-util/bin")

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

set(DICTPACK_ALLEXE ${DICTPACK_ALLEXE} dict2HTML)

file(INSTALL "${BIN_DIR_9}/DictToHTML.csh" DESTINATION bin
  USE_SOURCE_PERMISSIONS
  )

file(GLOB HTML_ICONS_9 "${ICONS_DIR_9}/*.gif")
file(COPY ${HTML_ICONS_9} DESTINATION ${BUILD_HTML_DIR}/icons)
file(GLOB HTML_INCLUDES_9 "${HTML_INCLUDES_DIR_9}/*.txt")
file(COPY ${HTML_INCLUDES_9} DESTINATION ${BUILD_HTML_DIR}/html-includes)
#
# Build executables from cpp-misc-dict-util
#
file(INSTALL "${BIN_DIR_10}/CreateDictSdbFile.csh" DESTINATION bin
  USE_SOURCE_PERMISSIONS
  )

add_executable("cifexch" "${SOURCE_DIR_10}/cifexch.C")
target_link_libraries("cifexch" "mmciflib-all")
target_include_directories("cifexch" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("cifexch2" "${SOURCE_DIR_10}/cifexch2.C" "${SOURCE_DIR_10}/ConditionalContext.C")
target_link_libraries("cifexch2" "mmciflib-all")
target_include_directories("cifexch2" PUBLIC ${INCLUDE_DIR_10} ${BUILD_INCLUDE_DIR})

add_executable("mk-schema-map-dict" "${SOURCE_DIR_10}/mk-schema-map-dict.C")
target_link_libraries("mk-schema-map-dict" "schema-map" "mmciflib-all")
target_include_directories("mk-schema-map-dict" PUBLIC ${INCLUDE_DIR_8} ${BUILD_INCLUDE_DIR})

add_executable("CifCheck" "${SOURCE_DIR_10}/CifCheck.C")
target_link_libraries("CifCheck" "mmciflib-all")
target_include_directories("CifCheck" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("cif_corrector" "${SOURCE_DIR_10}/cif_corrector.C")
target_link_libraries("cif_corrector" "mmciflib-all")
target_include_directories("cif_corrector" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("sf_corrector" "${SOURCE_DIR_10}/sf_corrector.C")
target_link_libraries("sf_corrector" "mmciflib-all")
target_include_directories("sf_corrector" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("DictInfo" "${SOURCE_DIR_10}/DictInfo.C")
target_link_libraries("DictInfo" "mmciflib-all")
target_include_directories("DictInfo" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("DictToSdb" "${SOURCE_DIR_10}/DictToSdb.C")
target_link_libraries("DictToSdb" "mmciflib-all")
target_include_directories("DictToSdb" PUBLIC ${BUILD_INCLUDE_DIR})

add_executable("non_printable" "${SOURCE_DIR_10}/non_printable.C")
target_link_libraries("non_printable" "mmciflib-all")
target_include_directories("non_printable" PUBLIC ${BUILD_INCLUDE_DIR})

set(DICTPACK_ALLEXE ${DICTPACK_ALLEXE} cifexch cifexch2 mk-schema-map-dict CifCheck cif_corrector sf_corrector DictInfo DictToSdb non_printable)
#
#  Build 'pdbml' library - not integrated in main library
#
set(SOURCES_11
             "${SOURCE_DIR_11}/PdbMlSchema.C"
             "${SOURCE_DIR_11}/PdbMlWriter.C"	
             "${SOURCE_DIR_11}/XmlWriter.C"
             "${SOURCE_DIR_11}/XsdWriter.C"	
	     )
add_library("pdbml" STATIC ${SOURCES_11})
target_include_directories("pdbml" PUBLIC ${INCLUDE_DIR_11} ${BUILD_INCLUDE_DIR} ${BUILD_SOURCE_DIR})
#
#  Build 'mmcif-xml-util' library - not integrated in main library
#
set(SOURCES_12
             "${SOURCE_DIR_12}/MmcifToXml.C"
	     )
add_library("mmcif-xml-util" STATIC ${SOURCES_12})
target_include_directories("mmcif-xml-util" PUBLIC ${INCLUDE_DIR_12} ${INCLUDE_DIR_11} ${BUILD_INCLUDE_DIR})
#
add_executable("mmcif2XML" "${SOURCE_DIR_12}/mmcif2XML.C")
target_link_libraries("mmcif2XML" "mmcif-xml-util" "pdbml" "mmciflib-all")
target_include_directories("mmcif2XML" PUBLIC ${INCLUDE_DIR_12} ${INCLUDE_DIR_11} ${BUILD_INCLUDE_DIR})
#
add_executable("Dict2XMLSchema" "${SOURCE_DIR_12}/Dict2XMLSchema.C")
target_link_libraries("Dict2XMLSchema" "mmcif-xml-util" "pdbml" "mmciflib-all")
target_include_directories("Dict2XMLSchema" PUBLIC ${INCLUDE_DIR_12} ${INCLUDE_DIR_11} ${BUILD_INCLUDE_DIR})
#
file(INSTALL "${BIN_DIR_12}/Dict2XMLSchema.csh" DESTINATION bin
  USE_SOURCE_PERMISSIONS
  )

set(DICTPACK_ALLEXE ${DICTPACK_ALLEXE} Dict2XMLSchema mmcif2XML)
message(STATUS "DICTPACK ALLEXE is ${DICTPACK_ALLEXE}")

# Support scripts
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
  file(INSTALL "${CMAKE_SOURCE_DIR}/scripts/WWPDBInstallSvn.csh" DESTINATION bin
    USE_SOURCE_PERMISSIONS
    )
  file(INSTALL "${CMAKE_SOURCE_DIR}/scripts/WWWProdInstall.csh" DESTINATION bin
    USE_SOURCE_PERMISSIONS
    )
endif()
