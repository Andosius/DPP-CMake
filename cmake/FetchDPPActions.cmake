function(DPP_BuildFromSourceUnix)

	# Set download location
	set(DPP_BUILD_HOME "${CMAKE_CURRENT_SOURCE_DIR}/download/DPP_src")
	execute_process(COMMAND "mkdir" "-p" "${DPP_BUILD_HOME}")

	# Get the repository for the predefined version
	execute_process(COMMAND "git" "clone" "-b" "${DPP_VERSION}" "https://github.com/brainboxdotcc/DPP" "${DPP_BUILD_HOME}")
	
	# Prepare build files
	execute_process(COMMAND "cmake" "-B" "${DPP_BUILD_HOME}/build" "-DDPP_NO_VCPKG=ON" "-DCMAKE_BUILD_TYPE=Release")
	
	# Build all the files
	execute_process(COMMAND "cmake" "--build" "${DPP_BUILD_HOME}/build" "-j")
	
	# Install libdpp :)
	execute_process(COMMAND "make" "-C" "${DPP_BUILD_HOME}/build" "install")

endfunction()