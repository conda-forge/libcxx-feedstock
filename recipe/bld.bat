mkdir build
cd build

set BUILD_CONFIG=Release

@rem Reduce build times and package size by removing unused stuff
set CMAKE_CUSTOM=-DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF

cmake -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    %CMAKE_CUSTOM% ^
    %SRC_DIR%
if errorlevel 1 exit 1

REM Build step
cmake --build . --config "%BUILD_CONFIG%"
if errorlevel 1 exit 1

REM Install step
cmake --build . --config "%BUILD_CONFIG%" --target install
if errorlevel 1 exit 1
