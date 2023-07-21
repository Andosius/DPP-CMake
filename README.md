<div align="center"><img src="https://github.com/brainboxdotcc/DPP/blob/master/docpages/DPP-markdown-logo.png?raw=true"/>
<h1>D++ CMake Cross Platform Utility</h1>
    <b>
        <p>An easy to use D++ setup script</p>
    </b>

[![GitHub issues](https://img.shields.io/github/issues/Andosius/DPP-CMake)](https://github.com/Andosius/DPP-CMake/issues)
[![GitHub license](https://img.shields.io/github/license/Andosius/DPP-CMake?color=brightgreen)](https://github.com/Andosius/DPP-CMake/blob/main/LICENSE)
</div>
  
### About this project
The "DPP-CMake" project is an extension for your CMake build system that makes it easier to incorporate the [Discord C++ library D++](https://github.com/brainboxdotcc/DPP) into your project.
Currently, the script is guaranteed to work on the following devices:
- x64 Linux (Debian/Ubuntu)
- x64 Windows
- arm64 Linux (Debian/Ubuntu)
- Raspberry Pi 4B (armhf native and aarch64/arm64 via auto build)
- macOS (via Github Actions)

### Windows dependencies
To run the standard routine you need the following programs installed:
- MSVC 2019 or MSVC 2022 (recommended) (https://visualstudio.microsoft.com/free-developer-offers/)
	- Check "Desktop development with C++", this should contain everything you need (MSVC, CMake, MSBuild)

### Debian/Ubuntu dependencies
To run the standard routine you need the following packages. You can install them by running:  
`sudo apt-get -y install git make cmake gcc g++ libsodium-dev libopus-dev zlib1g-dev libssl-dev ninja-build pkg-config rpm`

### RedHat/CentOS or every other Linux distro
You can try to find the Debian packages on your system and skip to the building process. DPP-CMake will try to build and implement it into your project.

### macOS dependencies
To run the standard routine you need the following packages. You can install them by running:  
`brew install git cmake make gcc libsodium libopusenc zlib openssl ninja pkg-config`
  
It may be required to install xcode via command line: `xcode-select --install`.

### Usage
1. Add the `cmake` directory to your directory structure
2. Include the file (`include(cmake/FetchDPP.cmake)`). Don't change the path, it may include files by itself, it will break!
2. Set the DPP release you want to use - example: `set(DPP_VERSION "10.0.24")`
2. Create an executable `add_executable("DPPBot" <source_files>)` and call `DPP_ConfigureTarget("DPPBot")` on your target. 
5. Done! Easy as that! Depending on your OS and Architecture you are ready to go.  
  
You can set these CMake options by adding something like `-DVAR=VALUE`. Rememeber to set it to `OFF` or `ON`.
  
|Option|Default value|Description|
|---|---|---|
|DPP_NO_VCPKG|ON|Prevents D++ to build a VCPKG build|
|DPP_CORO|OFF|Enables coroutines on build 10.0.25+|

### Building
Go into your project directory, create a new directory called `build` and run `cmake ..` inside of it.
This should auto-handle everything else for you.

### Important notes
Check [DPPs License](https://github.com/brainboxdotcc/DPP/blob/master/LICENSE) before building your project!
This project is not guaranteed to work and is not part of brainboxdotcc or officially supported by them.

### Known issues
Some builds may fail to install. DPP-CMake handles this by building `libdpp` by source. Depending of your systems power, this may take a while or not.  
This issue is known on arm64 builds and will force DPP-CMake to build the project on its own.
This is very slow (especially on a Raspberry Pi) but at the current time there is no other solution.
  
### Issues / Bugs
Please open a new Github issue for every problem you encounter that is not based on failure getting DPP-CMake to run. I am happy to help.
  
### D++ Community
Feel free to join the D++ Community!
[Join now!](https://discord.com/invite/dpp)