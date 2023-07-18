cmake_minimum_required(VERSION 3.10)

include(FetchContent)


set(DPP_DIR_VERSION "")

if(NOT DPP_VERSION)
	message(FATAL_ERROR "DPP_VERSION is not set - aborting!")
else()
	string(REGEX MATCH "([0-9]+\\.[0-9]+)" DPP_DIR_VERSION ${DPP_VERSION})
endif()


# System Info
set(DPP_CMAKE_ARCH "")
set(DPP_CMAKE_OS "")
set(DPP_CMAKE_FILE_ENDING "")
set(DPP_CMAKE_WINDOWS_VS "")

# Target file (/array)
set(DPP_CMAKE_DOWNLOAD_FILE)

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
	message(FATAL_ERROR "D++ has no macOS packages available!")
	
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	if(NOT EXISTS "/usr/lib/libdpp.so")
		set(DPP_CMAKE_OS "linux")

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
			set(DPP_CMAKE_ARCH "i386")
		elseif(DPP_OUTPUT_ARCH STREQUAL "armv6" OR DPP_OUTPUT_ARCH STREQUAL "armv6l")
			set(DPP_CMAKE_OS "linux-rpi")
			set(DPP_CMAKE_ARCH "arm6")
		elseif(DPP_OUTPUT_ARCH STREQUAL "aarch64" OR DPP_OUTPUT_ARCH STREQUAL "arm64")
			set(DPP_CMAKE_OS "linux-rpi")
			set(DPP_CMAKE_ARCH "arm64")
		elseif(DPP_OUTPUT_ARCH STREQUAL "armv7l" OR DPP_OUTPUT_ARCH STREQUAL "armhf")
			set(DPP_CMAKE_OS "linux-rpi")
			set(DPP_CMAKE_ARCH "arm7hf")
		elseif(DPP_OUTPUT_ARCH STREQUAL "x86_64" OR DPP_OUTPUT_ARCH STREQUAL "amd64")
			set(DPP_CMAKE_ARCH "x64")
		else()
			message(FATAL_ERROR "D++ does not support your system: ${DPP_OUTPUT_ARCH}")
		endif()

		# Check if we are using .deb or .rpm archives, /etc/debian_version is a good indicator
		if(EXISTS "/etc/debian_version")
			set(DPP_CMAKE_FILE_ENDING "deb")
		else()
			set(DPP_CMAKE_FILE_ENDING "rpm")
		endif()
	
		set(DPP_CMAKE_DOWNLOAD_FILE "libdpp-${DPP_VERSION}-${DPP_CMAKE_OS}-${DPP_CMAKE_ARCH}.${DPP_CMAKE_FILE_ENDING}")
	endif()
	
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	set(DPP_CMAKE_OS "win")

	# Get Windows architecture
	if($ENV{PROCESSOR_ARCHITECTURE} STREQUAL "AMD64")
		set(DPP_CMAKE_ARCH "64")
	elseif($ENV{PROCESSOR_ARCHITECTURE STREQUAL "x86")
		set(DPP_CMAKE_ARCH "32")
	endif()
	
	# TODO: Add command line recognition
	# Check which Visual Studio version we are using: vs2019 or 2022
	if(CMAKE_GENERATOR_TOOLSET MATCHES "v142")
		set(DPP_CMAKE_WINDOWS_VS "vs2019")
	elseif(CMAKE_GENERATOR_TOOLSET MATCHES "v143")
		set(DPP_CMAKE_WINDOWS_VS "vs2022")
	else()
		message(FATAL_ERROR "This script does not support your generator toolset: ${CMAKE_GENERATOR_TOOLSET}!")
	endif()
	
	set(DPP_CMAKE_FILE_ENDING "zip")
	
	list(APPEND DPP_CMAKE_DOWNLOAD_FILE "libdpp-${DPP_VERSION}-${DPP_CMAKE_OS}${DPP_CMAKE_ARCH}-debug-${DPP_CMAKE_WINDOWS_VS}.${DPP_CMAKE_FILE_ENDING}")
	list(APPEND DPP_CMAKE_DOWNLOAD_FILE "libdpp-${DPP_VERSION}-${DPP_CMAKE_OS}${DPP_CMAKE_ARCH}-release-${DPP_CMAKE_WINDOWS_VS}.${DPP_CMAKE_FILE_ENDING}")
endif()


# Prepare base download link for integration
set(DPP_DOWNLOAD_BASE_URL "https://github.com/brainboxdotcc/DPP/releases/download/v${DPP_VERSION}")


# Download and install packages based on OS
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	if(NOT DPP_CMAKE_DOWNLOAD_FILE STREQUAL "")
	
		# Download file to <base_dir>/download directory
		set(DPP_DOWNLOAD_URL "${DPP_DOWNLOAD_BASE_URL}/${DPP_CMAKE_DOWNLOAD_FILE}")
		set(DPP_DOWNLOAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/download")
		
		# Set full path to package
		set(DPP_DOWNLOAD_LIB_PATH "${DPP_DOWNLOAD_DIR}/${DPP_CMAKE_DOWNLOAD_FILE}")
		
		# Create directory if it does not exist
		execute_process(COMMAND "mkdir" "-p" "${DPP_DOWNLOAD_DIR}")		
		execute_process(COMMAND "wget" "${DPP_DOWNLOAD_URL}" "-O" "${DPP_DOWNLOAD_LIB_PATH}")
		
		# Debian routine
		if(${DPP_DOWNLOAD_LIB_PATH} MATCHES ".*\\.deb$")
			#execute_process(COMMAND "sudo" "apt" "install" "libsodium23" "libopus-dev")
			execute_process(COMMAND "sudo" "dpkg" "-i" "${DPP_DOWNLOAD_LIB_PATH}")
			execute_process(COMMAND "sudo" "apt-get" "-f" "install" "-y")
		
		# Error on .rpm machines for now as tjhe integration seems very "unclean"
		elseif(${DPP_DOWNLOAD_LIB_PATH} MATCHES ".*\\.rpm$")
			message(FATAL_ERROR ".rpm file detected! Please be aware that this script does not provide any additional functionality to support these packages! The .rpm file is located at: ${DPP_DOWNLOAD_LIB_PATH}")
		
		endif()
		
		# Set include directory only as we don't need to copy dependencies and can access lib via "dpp"
		set(DPP_CONF_RELEASE_BIN "")
		set(DPP_CONF_RELEASE_INC "/usr/include")
		set(DPP_CONF_RELEASE_LIB "")
	endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	# Loop through DPP_CMAKE_DOWNLOAD_FILE as we know it has atleast the debug and release conf build
	foreach(lib ${DPP_CMAKE_DOWNLOAD_FILE})
		set(file_name ${lib})
	
		# Prepare download for each item inside array
		FetchContent_Declare(
			${file_name}
			URL "${DPP_DOWNLOAD_BASE_URL}/${file_name}"
			DOWNLOAD_EXTRACT_TIMESTAMP TRUE
		)
		
		# Fetch item information
		FetchContent_GetProperties(${file_name})
		if(NOT ${file_name}_POPULATED)
			# Download and save unpacked location
			FetchContent_Populate(${file_name})
			set(DPP_LIB_PATH ${${file_name}_SOURCE_DIR})

			string(FIND ${file_name} "debug" DEBUG_FOUND)
			
			# Check for release conf
			if(DEBUG_FOUND EQUAL -1)
				set(DPP_CONF_RELEASE_BIN "${DPP_LIB_PATH}/bin")
				set(DPP_CONF_RELEASE_INC "${DPP_LIB_PATH}/include/dpp-${DPP_DIR_VERSION}")
				set(DPP_CONF_RELEASE_LIB "${DPP_LIB_PATH}/lib/dpp-${DPP_DIR_VERSION}/dpp.lib")
			
			# Check for debug conf
			else()
				set(DPP_CONF_DEBUG_BIN "${DPP_LIB_PATH}/bin")
				set(DPP_CONF_DEBUG_INC "${DPP_LIB_PATH}/include/dpp-${DPP_DIR_VERSION}")
				set(DPP_CONF_DEBUG_LIB "${DPP_LIB_PATH}/lib/dpp-${DPP_DIR_VERSION}/dpp.lib")
			endif()
		
		endif()

	endforeach()
endif()


function(DPP_ConfigureTarget target_name)

	target_compile_definitions("${target_name}" PUBLIC
		"DPP_BUILD"
		"FD_SETSIZE=1024"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:DEBUG>>"
	)
	
	target_compile_options("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:/bigobj;/sdl;/std:c++17;/Zc:preprocessor;/MP;>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:/Od;/sdl;>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:/O2;/Oi;/Oy;/GL;/Gy;>>"
		
		"$<$<PLATFORM_ID:Linux>:-std=c++17;-Wall;-Wempty-body;-Wno-psabi;-Wunknown-pragmas;-Wignored-qualifiers;-Wimplicit-fallthrough;-Wmissing-field-initializers;-Wsign-compare;-Wtype-limits;-Wuninitialized;-Wshift-negative-value;-pthread;-fPIC;>"
		"$<$<PLATFORM_ID:Linux>:$<$<CONFIG:Debug>:-g;-Og;>>"
		"$<$<PLATFORM_ID:Linux>:$<$<CONFIG:Release>:-O3;>>"
	)

	target_include_directories("${target_name}" PRIVATE
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:${DPP_CONF_DEBUG_INC}>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:${DPP_CONF_RELEASE_INC}>>"
		
		"$<$<PLATFORM_ID:Linux>:/usr/include>"
	)
	
	target_link_options("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:/DEBUG>>"
	)
	
	target_link_libraries("${target_name}" PUBLIC
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Debug>:${DPP_CONF_DEBUG_LIB}>>"
		"$<$<PLATFORM_ID:Windows>:$<$<CONFIG:Release>:${DPP_CONF_RELEASE_LIB}>>"
		
		"$<$<PLATFORM_ID:Linux>:dpp>"
	)
	
	# Copy all debug .dll files to output folder
	FILE(GLOB DEPS "${DPP_CONF_DEBUG_BIN}/*.dll")
	foreach(cur_file ${DEPS})
		get_filename_component(file_name ${cur_file} NAME)
		
		add_custom_target(CopyDLL_Debug_${file_name} ALL
			COMMAND ${CMAKE_COMMAND} -E copy "$<$<CONFIG:Debug>:${cur_file}>" "$(OutDir)"
			QUIET TRUE
		)
		
	endforeach()
	
	# Copy all release .dll files to output folder
	FILE(GLOB DEPS "${DPP_CONF_RELEASE_BIN}/*.dll")
	foreach(cur_file ${DEPS})
		get_filename_component(file_name ${cur_file} NAME)
		
		add_custom_target(CopyDLL_Release_${file_name} ALL
			COMMAND ${CMAKE_COMMAND} -E copy "$<$<CONFIG:Release>:${cur_file}>" "$(OutDir)"
			QUIET TRUE
		)
		
	endforeach()

endfunction()