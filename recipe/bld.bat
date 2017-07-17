:: Prep build
xcopy "%LIBRARY_LIB%\cmake\llvm" "%LIBRARY_LIB%\cmake\modules\" /s /h /e /k /f /c
if errorlevel 1 exit 1

:: Build libcxx to start (needed for bootstrapping)
mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

set BUILD_CONFIG=Release
if errorlevel 1 exit 1

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

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

cd ..\..
if errorlevel 1 exit 1

:: Build libcxxabi
curl -L -O "http://llvm.org/releases/%PKG_VERSION%/libcxxabi-%PKG_VERSION%.src.tar.xz"
if errorlevel 1 exit 1

tar -xvf "libcxxabi-%PKG_VERSION%.src.tar.xz" --no-same-owner
if errorlevel 1 exit 1

cd "libcxxabi-%PKG_VERSION%.src"
if errorlevel 1 exit 1

:: Patch to avoid unistd.h include, which causes issues on Windows.
patch "src\config.h" "%RECIPE_DIR%\config_drop_unistd.diff"
if errorlevel 1 exit 1

mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

cmake ^
  -G "NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE="%BUILD_CONFIG%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH="%LIBRARY_BIN%" ^
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH="%LIBRARY_LIB%" ^
  -DCMAKE_MODULE_PATH:PATH="%LIBRARY_LIB%\cmake" ^
  -DLLVM_CONFIG_PATH:PATH="%LIBRARY_BIN%\llvm-config.exe" ^
  -DLLVM_PATH:PATH="%LIBRARY_LIB%" ^
  -DLLVM_INCLUDE_DIR:PATH="%LIBRARY_INC%" ^
  -DLLVM_EXTERNAL_LIBCXX_SOURCE_DIR:PATH="..\..\libcxx-%PKG_VERSION%.src" ^
  -DLIBCXXABI_LIBCXX_PATH:PATH="..\..\libcxx-%PKG_VERSION%.src" ^
  -DLIBCXXABI_LIBCXX_INCLUDES:PATH="..\..\libcxx-%PKG_VERSION%.src\include" ^
  -DLIBCXXABI_ENABLE_SHARED:BOOL=ON ^
  -DLIBCXXABI_ENABLE_STATIC:BOOL=ON ^
  -DCMAKE_C_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
  -DCMAKE_CXX_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
  ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

cd ..\..
if errorlevel 1 exit 1

cd "libcxx-%PKG_VERSION%.src"
if errorlevel 1 exit 1

:: Build libcxx with libcxxabi
mkdir build2
if errorlevel 1 exit 1

cd build2
if errorlevel 1 exit 1

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
  -DLIBCXX_CXX_ABI=libcxxabi ^
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS:PATH="..\libcxxabi-${PKG_VERSION}.src\include" ^
  ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

pushd "%LIBRARY_LIB%"
if errorlevel 1 exit 1
for /f "eol=: delims=" %%F in ('findstr /r "c++.*"') do del "%%F"
if errorlevel 1 exit 1
popd
if errorlevel 1 exit 1
pushd "%LIBRARY_BIN%"
if errorlevel 1 exit 1
for /f "eol=: delims=" %%F in ('findstr /r "c++.*"') do del "%%F"
if errorlevel 1 exit 1
popd
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

:: Clean up after build
rmdir "%LIBRARY_LIB%\cmake\modules" /s /q
if errorlevel 1 exit 1
