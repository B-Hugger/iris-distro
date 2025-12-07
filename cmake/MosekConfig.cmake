# MosekConfig.cmake
# Find Mosek optimization library
#
# This module defines:
#   Mosek_FOUND - True if Mosek was found
#   MOSEK_INCLUDE_DIRS - Mosek include directories
#   MOSEK_LIBRARIES - Mosek libraries
#   mosek - Imported target for linking

# Try to find Mosek in standard locations
# On Windows, check Program Files
# On Linux/Mac, check /opt/mosek and /usr/local

if(WIN32)
  # Windows paths for Mosek 11.x, 10.x, 9.x
  set(_mosek_search_paths
    "C:/Program Files/Mosek/11.0/tools/platform/win64x86"
    "C:/Program Files/Mosek/10.2/tools/platform/win64x86"
    "C:/Program Files/Mosek/10.1/tools/platform/win64x86"
    "C:/Program Files/Mosek/10.0/tools/platform/win64x86"
    "C:/Program Files/Mosek/9.3/tools/platform/win64x86"
    "$ENV{MOSEK_ROOT}"
  )
  set(_mosek_lib_names mosek64_11_0 mosek64_10_2 mosek64_10_1 mosek64_10_0 mosek64_9_3 mosek64)
else()
  # Linux/Mac paths
  set(_mosek_search_paths
    "/opt/mosek/11.0/tools/platform/linux64x86"
    "/opt/mosek/10.2/tools/platform/linux64x86"
    "/opt/mosek/10.0/tools/platform/linux64x86"
    "/usr/local/mosek"
    "$ENV{MOSEK_ROOT}"
    "$ENV{HOME}/mosek/11.0/tools/platform/linux64x86"
    "$ENV{HOME}/mosek/10.0/tools/platform/linux64x86"
  )
  set(_mosek_lib_names mosek64 mosek)
endif()

# Find the include directory
find_path(MOSEK_INCLUDE_DIR
  NAMES mosek.h
  PATHS ${_mosek_search_paths}
  PATH_SUFFIXES h include
)

# Find the library
find_library(MOSEK_LIBRARY
  NAMES ${_mosek_lib_names}
  PATHS ${_mosek_search_paths}
  PATH_SUFFIXES bin lib
)

# Handle REQUIRED and QUIET arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Mosek
  REQUIRED_VARS MOSEK_LIBRARY MOSEK_INCLUDE_DIR
)

if(Mosek_FOUND)
  set(MOSEK_INCLUDE_DIRS ${MOSEK_INCLUDE_DIR})
  set(MOSEK_LIBRARIES ${MOSEK_LIBRARY})

  # Create imported target if it doesn't exist
  if(NOT TARGET mosek)
    add_library(mosek SHARED IMPORTED)
    set_target_properties(mosek PROPERTIES
      IMPORTED_LOCATION "${MOSEK_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${MOSEK_INCLUDE_DIR}"
    )
    if(WIN32)
      # On Windows, we need to set IMPORTED_IMPLIB for the import library
      get_filename_component(_mosek_lib_dir "${MOSEK_LIBRARY}" DIRECTORY)
      get_filename_component(_mosek_lib_name "${MOSEK_LIBRARY}" NAME_WE)
      find_file(MOSEK_IMPLIB
        NAMES "${_mosek_lib_name}.lib"
        PATHS "${_mosek_lib_dir}/../lib" "${_mosek_lib_dir}"
      )
      if(MOSEK_IMPLIB)
        set_target_properties(mosek PROPERTIES
          IMPORTED_IMPLIB "${MOSEK_IMPLIB}"
        )
      endif()
    endif()
  endif()
endif()

mark_as_advanced(MOSEK_INCLUDE_DIR MOSEK_LIBRARY)
