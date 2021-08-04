function(download_file url filename)

  if(NOT EXISTS ${filename})
    message("Downloading  ${url} -> ${filename}")
    file(DOWNLOAD ${url} ${filename}
      TIMEOUT 60  # seconds
      )
  endif()

endfunction(download_file)

function(download_dict url base)
  download_file(${url} ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${base}/${base}.dic)
endfunction(download_dict)

function(process_dict base)
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mmcif/${base}.dic
    COMMAND ${CMAKE_COMMAND} -E copy dicts/dict-${base}/${base}.dic ${CMAKE_CURRENT_BINARY_DIR}/mmcif/${base}.dic
    )

  add_custom_target(${base}_dic
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mmcif/${base}.dic
    )
endfunction(process_dict)

# Fetch from remote site and process in one
function(download_process_dict url base)
  download_dict(${url} ${base})
  process_dict(${base})
endfunction(download_process_dict)


function(GET_DICTIONARY DICTNAME)
 # Determine download location from dictionary configuration
 set(GEN_COMMAND
    ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/scripts/getdictinfo.py
    --dictname ${DICTNAME}
    --print-url
    )

  execute_process(
    COMMAND ${GEN_COMMAND}
    OUTPUT_VARIABLE DICT_URL
    RESULT_VARIABLE RET
    )

  if (NOT RET EQUAL 0)
    message(FATAL_ERROR "Failed to get the ${DICTNAME} dictionary url " ${RET})
  endif()

  # message(STATUS "Dictionary url for ${DICTNAME} is ${DICT_URL}")

  download_process_dict(${DICT_URL} ${DICTNAME})
endfunction(GET_DICTIONARY)
