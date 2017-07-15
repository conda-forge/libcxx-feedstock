mkdir build
cd build

set BUILD_CONFIG=Release

cmake -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%LIBRARY_BIN%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIBRARY_LIB%" ^
    -DCMAKE_C_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DCMAKE_CXX_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DLLVM_CONFIG_PATH:PATH="%LIBRARY_BIN%\llvm-config.exe" ^
    -DLLVM_PATH="%LIBRARY_LIB%" ^
    -DLLVM_INCLUDE_DIR="%LIBRARY_INC%" ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    "%SRC_DIR%"
if errorlevel 1 exit 1

REM Build step
cmake --build . --config "%BUILD_CONFIG%"
if errorlevel 1 exit 1

REM Install step
cmake --build . --config "%BUILD_CONFIG%" --target install
if errorlevel 1 exit 1
