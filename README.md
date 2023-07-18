<div align="center"><img src="https://github.com/brainboxdotcc/DPP/blob/master/docpages/DPP-markdown-logo.png?raw=true"/>
<h1>D++ CMake Utility</h1>
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
- arm64 Raspberry Pi 4B
  
### Usage
1. Add `cmake/FetchDPP.cmake` to your directory structure
2. Include the file (`include(cmake/FetchDPP.cmake)`).
2. Set the DPP release you want to use - example: `set(DPP_VERSION "10.0.24")`
2. Create an executable `add_executable("DPPBot" <source_files>)` and call `DPP_ConfigureTarget("DPPBot")` on your target. 
5. Done! Easy as that! Depending on your OS and Architecture you are ready to go. 
  
### Issues / Bugs
Please open a new Github issue for every problem you encounter that is not based on failure getting DPP-CMake to run. I am happy to help.
  
### D++ Community
Feel free to join the D++ Community!
[Join now!](https://discord.com/invite/dpp)