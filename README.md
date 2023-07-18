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
- Raspberry Pi 4B (using 32-bit OSes)
  
### Usage
1. Add `cmake/FetchDPP.cmake` to your directory structure
2. Include the file (`include(cmake/FetchDPP.cmake)`).
2. Set the DPP release you want to use - example: `set(DPP_VERSION "10.0.24")`
2. Create an executable `add_executable("DPPBot" <source_files>)` and call `DPP_ConfigureTarget("DPPBot")` on your target. 
5. Done! Easy as that! Depending on your OS and Architecture you are ready to go. 

### Known problems
At the current stage we can't support any 64-bit Raspberry PI OSes! Please be aware that this is not caused by me or DPP.  
aarch64 and arm64 are synonyms for eachother and due to a bug the library expects aarch64 which is not possible to add to dpkg architecture list.

To resolve this issue the Raspberry Pi will build DPP by its own. This is very slow but at the current time there is no other solution.
  
### Issues / Bugs
Please open a new Github issue for every problem you encounter that is not based on failure getting DPP-CMake to run. I am happy to help.
  
### D++ Community
Feel free to join the D++ Community!
[Join now!](https://discord.com/invite/dpp)