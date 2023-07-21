cmake_minimum_required(VERSION 3.10)


set(DPP_DIR_VERSION "")

if(NOT DPP_VERSION)
	message(FATAL_ERROR "DPP_VERSION is not set - aborting!")
else()
	string(REGEX MATCH "([0-9]+\\.[0-9]+)" DPP_DIR_VERSION ${DPP_VERSION})
endif()

# Get build functions, may be expanded in future
include(cmake/FetchDPPActions.cmake)

# DPP Configuration options
option(DPP_NO_VCPKG "Enable or disable building for VCPKG" ON)
option(DPP_CORO "Enable or disable building coroutine features (>=C++20)" OFF)

# System Info
set(DPP_SYSTEM_ARCH "")
set(DPP_SYSTEM_OS "")
set(DPP_SYSTEM_FILE_ENDING "")
set(DPP_SYSTEM_WINDOWS_VS "")

# Target file (/array for Windows)
set(DPP_TARGET_DOWNLOAD_FILE)

# Debug configuration paths
set(DPP_CONF_DEBUG_BIN "")
set(DPP_CONF_DEBUG_INC "")
set(DPP_CONF_DEBUG_LIB "")

# Release configuration paths
set(DPP_CONF_RELEASE_BIN "")
set(DPP_CONF_RELEASE_INC "")
set(DPP_CONF_RELEASE_LIB "")


# Start collecting system information
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	if(NOT EXISTS "${CMAKE_INSTALL_PREFIX}/lib/libdpp.dylib")
		DPP_BuildFromSourceUnix()
	endif()
	
	set(DPP_CONF_RELEASE_BIN "")
	set(DPP_CONF_RELEASE_INC "${CMAKE_INSTALL_PREFIX}/include")
	set(DPP_CONF_RELEASE_LIB "${CMAKE_INSTALL_PREFIX}/lib/libdpp.dylib")
	
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	if(NOT EXISTS "${CMAKE_INSTALL_PREFIX}/lib/libdpp.so")
		set(DPP_SYSTEM_OS "linux")

		# Get Linux Architecture first
		execute_process(
			COMMAND "uname" "-p"
			OUTPUT_VARIABLE DPP_OUTPUT_ARCH
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		
		if(${DPP_OUTPUT_ARCH} STREQUAL "unknown")
			execute_process(
				COMMAND "uname" "-m"
				OUTPUT_VARIABLE DPP_OUTPUT_ARCH
				OUTPUT_STRIP_TRAILING_WHITESPACE
			)
		endif()
		
		# Process architecture types
		if(DPP_OUTPUT_ARCH STREQUAL "i386" OR DPP_OUTPUT_ARCH STREQUAL "x86")
			set(DPP_SYSTEM_ARCH "i386")
		elseif(DPP_OUTPUT_ARCH STREQUAL "armv6" OR DPP_OUTPUT_ARCH STREQUAL "armv6l")
			set(DPP_SYSTEM_OS "linux-rpi")
			set(DPP_SYSTEM_ARCH "arm6")
		elseif(DPP_OUTPUT_ARCH STREQUAL "aarch64" OR DPP_OUTPUT_ARCH STREQUAL "arm64")
			set(DPP_SYSTEM_OS "linux-rpi")
			set(DPP_SYSTEM_ARCH "arm64")
		elseif(DPP_OUTPUT_ARCH STREQUAL "armv7l" OR DPP_OUTPUT_ARCH STREQUAL "armhf")
			set(DPP_SYSTEM_OS "linux-rpi")
			set(DPP_SYSTEM_ARCH "arm7hf")
		elseif(DPP_OUTPUT_ARCH STREQUAL "x86_64" OR DPP_OUTPUT_ARCH STREQUAL "amd64")
			set(DPP_SYSTEM_ARCH "x64")
		else()
			message(FATAL_ERROR "D++ does not support your system: ${DPP_OUTPUT_ARCH}")
		endif()

		# Check if we are using .deb or .rpm archives, /etc/debian_version is a good indicator
		if(EXISTS "/etc/debian_version")
			set(DPP_SYSTEM_FILE_ENDING "deb")
		else()
			set(DPP_SYSTEM_FILE_ENDING "rpm")
		endif()
	
		set(DPP_TARGET_DOWNLOAD_FILE "libdpp-${DPP_VERSION}-${DPP_SYSTEM_OS}-${DPP_SYSTEM_ARCH}.${DPP_SYSTEM_FILE_ENDING}")
	endif()
	
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	set(DPP_SYSTEM_OS "win")

	# Get Windows architecture
	if($ENV{PROCESSOR_ARCHITECTURE} STREQUAL "AMD64")
		set(DPP_SYSTEM_ARCH "64")
	elseif($ENV{PROCESSOR_ARCHITECTURE STREQUAL "x86")
		set(DPP_SYSTEM_ARCH "32")
	endif()
	
	# Check which Visual Studio version we are using: vs2019 or 2022
	if(CMAKE_GENERATOR_TOOLSET MATCHES "v142" OR CMAKE_GENERATOR MATCHES "Visual Studio 16 2019")
		set(DPP_SYSTEM_WINDOWS_VS "vs2019")
	elseif(CMAKE_GENERATOR_TOOLSET MATCHES "v143" OR CMAKE_GENERATOR MATCHES "Visual Studio 17 2022")
		set(DPP_SYSTEM_WINDOWS_VS "vs2022")
	else()
		message(FATAL_ERROR "This script does not support your generator toolset: ${CMAKE_GENERATOR_TOOLSET}!")
	endif()
	
	set(DPP_SYSTEM_FILE_ENDING "zip")
	
	set(DPP_TARGET_DOWNLOAD_FILE "libdpp-${DPP_VERSION}-${DPP_SYSTEM_OS}${DPP_SYSTEM_ARCH}-CONFIGURATION-${DPP_SYSTEM_WINDOWS_VS}.${DPP_SYSTEM_FILE_ENDING}")
endif()


# Prepare base download link for integration
set(DPP_DOWNLOAD_BASE_URL "https://github.com/brainboxdotcc/DPP/releases/download/v${DPP_VERSION}")


# Download and install packages based on OS
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	# Download file to <base_dir>/download directory
	set(DPP_DOWNLOAD_URL "${DPP_DOWNLOAD_BASE_URL}/${DPP_TARGET_DOWNLOAD_FILE}")
	set(DPP_DOWNLOAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/download")
	
	# Set full path to package
	set(DPP_DOWNLOAD_LIB_PATH "${DPP_DOWNLOAD_DIR}/${DPP_TARGET_DOWNLOAD_FILE}")
	
	# Try to build libdpp on .rpm machines, we shouldn't worry about it
	if(NOT ${DPP_DOWNLOAD_LIB_PATH} MATCHES ".*\\.deb$")
		if(NOT EXISTS "${CMAKE_INSTALL_PREFIX}/lib/libdpp.so")
			DPP_BuildFromSourceUnix()
		endif()
		
		set(DPP_CONF_RELEASE_BIN "")
		set(DPP_CONF_RELEASE_INC "${CMAKE_INSTALL_PREFIX}/include")
		set(DPP_CONF_RELEASE_LIB "")
	endif()
	
	# Create directory if it does not exist
	if(NOT EXISTS "${DPP_DOWNLOAD_DIR}")
		execute_process(COMMAND "mkdir" "-p" "${DPP_DOWNLOAD_DIR}")
		
	# Download libdpp if the directory does not already contain it
	elseif(EXISTS "${DPP_DOWNLOAD_DIR}" AND NOT EXISTS "${DPP_DOWNLOAD_LIB_PATH}")
		execute_process(COMMAND "curl" "${DPP_DOWNLOAD_URL}" "-o" "${DPP_DOWNLOAD_LIB_PATH}")
	endif()
	
	if(EXISTS "/etc/debian_version")
		# Check file first and try to install it and check for errors.
		execute_process(COMMAND "sudo" "dpkg-deb" "--control" "${DPP_DOWNLOAD_LIB_PATH}" RESULT_VARIABLE exit_status)
		
		# Check if we got any errors -> build by source
		# Status 1: A check or assertion command returned false.
		# Status 2: Fatal or unrecoverable error due to invalid command-line usage, or interactions with the system, such as accesses to the database, memory allocations, etc.
		if(exit_status EQUAL "1" OR exit_status EQUAL "2")
			execute_process(COMMAND "sudo" "apt" "purge" "-y" "libdpp")
			
			DPP_BuildFromSourceUnix()
		# Everything seems fine => install it
		else()
			execute_process(COMMAND "sudo" "dpkg" "-i" "${DPP_DOWNLOAD_LIB_PATH}" RESULT_VARIABLE exit_status)
		endif()
	endif()
	
	# Set include directory only as we don't need to copy dependencies and can access lib via "dpp"
	set(DPP_CONF_RELEASE_BIN "")
	set(DPP_CONF_RELEASE_INC "${CMAKE_INSTALL_PREFIX}/include")
	set(DPP_CONF_RELEASE_LIB "")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# Download files to <base_dir>/download directory
	set(DPP_DOWNLOAD_URL "${DPP_DOWNLOAD_BASE_URL}/${DPP_TARGET_DOWNLOAD_FILE}")
	set(DPP_DOWNLOAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/download")
	
	# Set download URL
	string(REPLACE "CONFIGURATION" "debug" DPP_DOWNLOAD_URL_DEBUG ${DPP_DOWNLOAD_URL})
	string(REPLACE "CONFIGURATION" "release" DPP_DOWNLOAD_URL_RELEASE ${DPP_DOWNLOAD_URL})
	
	# Set file download name
	string(REPLACE "CONFIGURATION" "debug" DPP_DOWNLOAD_FILE_DEBUG ${DPP_TARGET_DOWNLOAD_FILE})
	string(REPLACE "CONFIGURATION" "release" DPP_DOWNLOAD_FILE_RELEASE ${DPP_TARGET_DOWNLOAD_FILE})
	
	set(DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG "${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_DEBUG}")
	set(DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE "${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_RELEASE}")
	
	# Escape directory path
	string(REPLACE "/" "\\" DPP_DOWNLOAD_DIR ${DPP_DOWNLOAD_DIR})
	
	# Set the inner zip file directory
	set(DPP_CMAKE_INNER_DIR "libdpp-${DPP_VERSION}-${DPP_SYSTEM_OS}${DPP_SYSTEM_ARCH}")
	
	# Set the usable path
	set(DPP_DEBUG_PATH "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}-src\\${DPP_CMAKE_INNER_DIR}")
	set(DPP_RELEASE_PATH "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}-src\\${DPP_CMAKE_INNER_DIR}")
	
	# Set required setup information
	set(DPP_CONF_DEBUG_BIN "${DPP_DEBUG_PATH}\\bin")
	set(DPP_CONF_DEBUG_INC "${DPP_DEBUG_PATH}\\include\\dpp-${DPP_DIR_VERSION}")
	set(DPP_CONF_DEBUG_LIB "${DPP_DEBUG_PATH}\\lib\\dpp-${DPP_DIR_VERSION}\\dpp.lib")

	set(DPP_CONF_RELEASE_BIN "${DPP_RELEASE_PATH}\\bin")
	set(DPP_CONF_RELEASE_INC "${DPP_RELEASE_PATH}\\include\\dpp-${DPP_DIR_VERSION}")
	set(DPP_CONF_RELEASE_LIB "${DPP_RELEASE_PATH}\\lib\\dpp-${DPP_DIR_VERSION}\\dpp.lib")
	
	
	if(NOT EXISTS "${DPP_DOWNLOAD_DIR}")
		# Find Powershell executable
		find_program(POWERSHELL_PATH NAMES powershell)
		
		# Create directory if it does not exist
		execute_process(COMMAND "${POWERSHELL_PATH}" "New-Item" "-ItemType" "Directory" "-Path" "${DPP_DOWNLOAD_DIR}")
		
		# Set output vars to wait for the process to finish
		execute_process(COMMAND "${POWERSHELL_PATH}" "Invoke-WebRequest" "-Uri" "\"${DPP_DOWNLOAD_URL_DEBUG}\"" "-OutFile" "\"${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_DEBUG}\"")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Invoke-WebRequest" "-Uri" "\"${DPP_DOWNLOAD_URL_RELEASE}\"" "-OutFile" "\"${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_RELEASE}\"")
	
		# Extract files and delete archives
		execute_process(COMMAND "${POWERSHELL_PATH}" "Expand-Archive" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}" "-DestinationPath" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}-src")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Expand-Archive" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}" "-DestinationPath" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}-src")
		
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}")
		
		# Delete cmake directory, we won't use it anyway
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_DEBUG_PATH}\\lib\\cmake" "-Recurse")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_RELEASE_PATH}\\lib\\cmake" "-Recurse")
	endif()
	
	# Check for debug directory only
	if(EXISTS "${DPP_DOWNLOAD_DIR}" AND NOT EXISTS "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}-src")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Invoke-WebRequest" "-Uri" "\"${DPP_DOWNLOAD_URL_DEBUG}\"" "-OutFile" "\"${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_DEBUG}\"")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Expand-Archive" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}" "-DestinationPath" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}-src")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_DEBUG}")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_DEBUG_PATH}\\lib\\cmake" "-Recurse")
	endif()
	
	# Check for release directory only
	if(EXISTS "${DPP_DOWNLOAD_DIR}" AND NOT EXISTS "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}-src")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Invoke-WebRequest" "-Uri" "\"${DPP_DOWNLOAD_URL_RELEASE}\"" "-OutFile" "\"${DPP_DOWNLOAD_DIR}\\${DPP_DOWNLOAD_FILE_RELEASE}\"")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Expand-Archive" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}" "-DestinationPath" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}-src")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_CMAKE_DOWNLOAD_LOCATION_RELEASE}")
		execute_process(COMMAND "${POWERSHELL_PATH}" "Remove-Item" "-Path" "${DPP_RELEASE_PATH}\\lib\\cmake" "-Recurse")
	endif()
endif()

function(DPP_ConfigureTarget target_name)

	target_compile_definitions("${target_name}" PUBLIC
		"DPP_BUILD"
		"FD_SETSIZE=1024"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:DEBUG>>"
	)
	
	target_compile_options("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:/bigobj;/sdl;/std:c++17;/Zc:preprocessor;/MP;>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:/Od;/sdl;/DEBUG>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:/O2;/Oi;/Oy;/GL;/Gy;>>"
		
		"$<$<PLATFORM_ID:Linux>:-std=c++17;-Wall;-Wempty-body;-Wno-psabi;-Wunknown-pragmas;-Wignored-qualifiers;-Wimplicit-fallthrough;-Wmissing-field-initializers;-Wsign-compare;-Wtype-limits;-Wuninitialized;-Wshift-negative-value;-pthread;-fPIC;>"
		"$<$<PLATFORM_ID:Linux>:$<$<CONFIG:Debug>:-g;-Og;>>"
		"$<$<PLATFORM_ID:Linux>:$<$<CONFIG:Release>:-O3;>>"
		
		"$<$<PLATFORM_ID:Darwin>:-std=c++17;-Wall;-Wempty-body;-Wno-psabi;-Wunknown-pragmas;-Wignored-qualifiers;-Wimplicit-fallthrough;-Wmissing-field-initializers;-Wsign-compare;-Wtype-limits;-Wuninitialized;-Wshift-negative-value;-pthread;-fPIC;>"
		"$<$<PLATFORM_ID:Darwin>:$<$<CONFIG:Debug>:-g;-Og;>>"
		"$<$<PLATFORM_ID:Darwin>:$<$<CONFIG:Release>:-O3;>>"
	)

	target_include_directories("${target_name}" PRIVATE
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:${DPP_CONF_DEBUG_INC}>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:${DPP_CONF_RELEASE_INC}>>"
		
		"$<$<PLATFORM_ID:Linux>:${CMAKE_INSTALL_PREFIX}/include>"
		
		"$<$<PLATFORM_ID:Darwin>:${CMAKE_INSTALL_PREFIX}/include>"
	)
	
	target_link_options("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:/DEBUG>>"
	)
	
	target_link_libraries("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:${DPP_CONF_DEBUG_LIB}>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:${DPP_CONF_RELEASE_LIB}>>"
		
		"$<$<PLATFORM_ID:Linux>:dpp>"
		
		"$<$<PLATFORM_ID:Darwin>:${DPP_CONF_RELEASE_LIB}>"
	)

	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		set(copy_target "${DPP_DOWNLOAD_DIR}\\libdpp-${DPP_VERSION}-${DPP_SYSTEM_OS}${DPP_SYSTEM_ARCH}-$(Configuration.toLower())-${DPP_SYSTEM_WINDOWS_VS}.${DPP_SYSTEM_FILE_ENDING}-src\\${DPP_CMAKE_INNER_DIR}\\bin\\*.dll")
	
		add_custom_command(TARGET ${target_name} POST_BUILD
			COMMAND xcopy /Y /Q ${copy_target} $(OutDir)
			COMMENT "Copy all D++ dependencies."
		)
		
	endif()

endfunction()
