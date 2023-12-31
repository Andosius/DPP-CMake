function(DPP_BuildFromSourceUnix)

	# Set download location
	set(DPP_BUILD_HOME "${CMAKE_CURRENT_SOURCE_DIR}/download/DPP_src")
	execute_process(COMMAND "mkdir" "-p" "${DPP_BUILD_HOME}")

	# Don't clone DPP if it already exists
	if(NOT EXISTS "${DPP_BUILD_HOME}/.git")
		# Get the repository for the predefined version
		execute_process(COMMAND "git" "clone" "-b" "v${DPP_VERSION}" "https://github.com/brainboxdotcc/DPP" "${DPP_BUILD_HOME}")
	endif()
	
	# Prepare build files
	execute_process(COMMAND "cmake" "-B" "${DPP_BUILD_HOME}/build" "-S" "${DPP_BUILD_HOME}" "-DDPP_NO_VCPKG=${DPP_NO_VCPKG}" "-DDPP_CORO=${DPP_CORO}" "-DCMAKE_BUILD_TYPE=Release")
	
	# Build all the files
	execute_process(COMMAND "cd" "${DPP_BUILD_HOME}" "&&" "cmake" "--build" "./build" "-j")
	
	# Install libdpp :)
	execute_process(COMMAND "sudo" "make" "-C" "${DPP_BUILD_HOME}/build" "install")

endfunction()
