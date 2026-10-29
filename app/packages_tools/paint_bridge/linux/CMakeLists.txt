# The Flutter tooling requires CMake 3.10 or later.
cmake_minimum_required(VERSION 3.10)
cmake_policy(SET CMP0079 NEW)

set(PROJECT_NAME "paint_bridge")
project(${PROJECT_NAME} LANGUAGES CXX)

include("../cargokit/cmake/cargokit.cmake")
# Linux follows the symlink Flutter puts in the app's ephemeral folder, so
# ".." leads out of the plugin's real folder.
apply_cargokit(${PROJECT_NAME} ../rust paintbox_bridge "")
target_link_libraries(${BINARY_NAME} PRIVATE "${${PROJECT_NAME}_cargokit_lib}")

# Absolute paths of the libraries bundled with the plugin.
set(paint_bridge_bundled_libraries
  "${${PROJECT_NAME}_cargokit_lib}"
  PARENT_SCOPE
)
