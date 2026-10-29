# The Flutter tooling requires a Visual Studio with CMake 3.14 or later.
cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "paint_bridge")
project(${PROJECT_NAME} LANGUAGES CXX)

include("../cargokit/cmake/cargokit.cmake")

# Flutter reaches this file through a symlink in the app's ephemeral
# folder and Windows resolves ".." in that path textually, so the crate is
# found from the real folder, given relative to the symlinked one.
execute_process(
  COMMAND powershell -ExecutionPolicy Bypass -File "${CMAKE_CURRENT_LIST_DIR}/../cargokit/cmake/resolve_symlinks.ps1" "${CMAKE_CURRENT_SOURCE_DIR}"
  OUTPUT_VARIABLE paint_bridge_real_dir
  OUTPUT_STRIP_TRAILING_WHITESPACE)
get_filename_component(paint_bridge_crate_dir "${paint_bridge_real_dir}/../rust" ABSOLUTE)
file(RELATIVE_PATH paint_bridge_crate "${CMAKE_CURRENT_SOURCE_DIR}" "${paint_bridge_crate_dir}")
apply_cargokit(${PROJECT_NAME} ${paint_bridge_crate} paintbox_bridge "")

# Absolute paths of the libraries bundled with the plugin.
set(paint_bridge_bundled_libraries
  "${${PROJECT_NAME}_cargokit_lib}"
  PARENT_SCOPE
)
