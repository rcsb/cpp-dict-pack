function(download_file url filename)

  if(NOT EXISTS ${filename})
    message(STATUS "Downloading  ${url} -> ${filename}")
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
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${base}/${base}.dic
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

# copy dictionary frmo source - if not present.  Assumes source exists
function(copy_source_dict base)
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${base}/${base}.dic)
    message(STATUS "Copying dictionary from ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${base}/${base}.dic")
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${base}/${base}.dic
      DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/dicts/dict-${base}/)
  endif()
endfunction(copy_source_dict)
  
# Fetches from source directory - copy or download (ALWAYS_DOWNLOAD_DICTS can override
function(fetch_process_dict url base)
  if(NOT ALWAYS_DOWNLOAD_DICTS AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/dicts/dict-${base}/${base}.dic)
    copy_source_dict(${base})
  else()
    download_dict(${url} ${base})
  endif()
  process_dict(${base})
endfunction(fetch_process_dict)


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

  fetch_process_dict(${DICT_URL} ${DICTNAME})
endfunction(GET_DICTIONARY)
