:: Prep build
xcopy "%LIBRARY_LIB%\cmake\llvm" "%LIBRARY_LIB%\cmake\modules" /s /h /e /k /f /c
if errorlevel 1 exit 1

mkdir build
cd build

set BUILD_CONFIG=Release

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH="%LIBRARY_BIN%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH="%LIBRARY_LIB%" ^
    -DCMAKE_MODULE_PATH:PATH="%LIBRARY_LIB%\cmake" ^
    -DCMAKE_C_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DCMAKE_CXX_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DLLVM_CONFIG_PATH:PATH="%LIBRARY_BIN%\llvm-config.exe" ^
    -DLLVM_PATH:PATH="%LIBRARY_LIB%" ^
    -DLLVM_INCLUDE_DIR:PATH="%LIBRARY_INC%" ^
    -DLLVM_INCLUDE_TESTS:BOOL=OFF ^
    -DLLVM_INCLUDE_DOCS:BOOL=OFF ^
    -DLIBCXX_ENABLE_SHARED:BOOL=ON ^
    -DLIBCXX_ENABLE_STATIC:BOOL=ON ^
    -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY:BOOL=OFF ^
    ..
if errorlevel 1 exit 1

REM Build step
cmake --build . --config "%BUILD_CONFIG%"
if errorlevel 1 exit 1

REM Install step
cmake --build . --config "%BUILD_CONFIG%" --target install
if errorlevel 1 exit 1

:: Clean up after build
rmdir "%LIBRARY_LIB%\cmake\modules" /s /q
if errorlevel 1 exit 1
