find_package(fmt REQUIRED)

if(NOT TARGET fmt::fmt)
  find_library(fmt_LIBRARY fmt REQUIRED)
  add_library(fmt::fmt SHARED IMPORTED)
  set_target_properties(fmt::fmt PROPERTIES
    IMPORTED_LOCATION "${fmt_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${fmt_INCLUDE_DIRS}")
endif()

