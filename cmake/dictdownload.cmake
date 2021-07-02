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
  if(DICTNAME STREQUAL mmcif_ddl)
    download_process_dict(https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_ddl/master/dist/mmcif_ddl.dic  mmcif_ddl)
  elseif(DICTNAME STREQUAL mmcif_pdbx_v5_next)
    download_process_dict(https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/dist/mmcif_pdbx_v5_next.dic mmcif_pdbx_v5_next)
  elseif(DICTNAME STREQUAL mmcif_pdbx_v50)
    download_process_dict(https://raw.githubusercontent.com/wwpdb-dictionaries/mmcif_pdbx/master/dist/mmcif_pdbx_v50.dic mmcif_pdbx_v50)
  else()
    message(FATAL_ERROR "Do not know how to retrieve ${DICTNAME}")
  endif()
endfunction(GET_DICTIONARY)
