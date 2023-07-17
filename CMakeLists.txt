cmake_minimum_required(VERSION 3.20)


# Configure main project attributes
project(DPPMake)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DPP_VERSION "10.0.24")
include(cmake/FetchDPP.cmake)

# Set output directory to "bin" in root directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin" CACHE STRING "" FORCE)


# Set source files
file(GLOB SOURCE_FILES src/*.cpp)

# Set executable name
set(EXECUTABLE_NAME "DPPMake")


# Build executable
add_executable(${EXECUTABLE_NAME}
	${SOURCE_FILES}
)

DPP_ConfigureTarget(${EXECUTABLE_NAME})