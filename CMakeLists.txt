cmake_minimum_required(VERSION 3.7)

project(fmt_vendor)

find_package(ament_cmake REQUIRED)

option(FORCE_BUILD_VENDOR_PKG
  "Build fmt from source, even if system-installed package is available"
  OFF)

if(NOT FORCE_BUILD_VENDOR_PKG)
  # Attempt to find an existing fmt installation
  find_package(fmt QUIET)
endif()

macro(build_fmt)
  set(extra_cmake_args)
  if(DEFINED CMAKE_BUILD_TYPE)
    list(APPEND extra_cmake_args -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
  endif()
  if(DEFINED BUILD_SHARED_LIBS)
    list(APPEND extra_cmake_args -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS})
  else()
    list(APPEND extra_cmake_args -DBUILD_SHARED_LIBS=ON)
  endif()
  if(DEFINED CMAKE_TOOLCHAIN_FILE)
    list(APPEND extra_cmake_args "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  endif()
  list(APPEND extra_cmake_args "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")

  if(BUILD_TESTING)
    list(APPEND extra_cmake_args "-DFMT_TEST=ON")
  else()
    list(APPEND extra_cmake_args "-DFMT_TEST=OFF")
  endif()

  include(ExternalProject)

  # Build fmt
  externalproject_add(fmt_external
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG 11.0.2
    GIT_CONFIG advice.detachedHead=false
    UPDATE_COMMAND ""
    TIMEOUT 600
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install
      ${extra_cmake_args}
  )

  # Install the built fmt to the package install location
  install(
    DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_install/
    DESTINATION
      ${CMAKE_INSTALL_PREFIX}
    USE_SOURCE_PERMISSIONS
  )
endmacro()

if(NOT fmt_FOUND)
  message(STATUS "Did not find fmt installation, building from source")
  build_fmt()
endif()

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()

