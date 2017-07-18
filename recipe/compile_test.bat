setlocal enableextensions
setlocal enabledelayedexpansion

pushd test_sources
if errorlevel 1 exit 1
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.c$"`) do (
    clang -O2 -g %%i -o test_clang.exe
    if errorlevel 1 exit 1
    test_clang
    if errorlevel 1 exit 1
)
popd
if errorlevel 1 exit 1

pushd test_sources
if errorlevel 1 exit 1
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.cpp$"`) do (
    clang++ -nostdinc++ -nostdlib -L "%LIBRARY_LIB%" -lc++ -O2 -g %%i -o test_clang.exe
    if errorlevel 1 exit 1
    test_clang
    if errorlevel 1 exit 1
)
popd
if errorlevel 1 exit 1

pushd test_sources\cpp11
if errorlevel 1 exit 1
for /f "usebackq" %%i in (`dir /b ^| findstr /i "^.*\.cpp$"`) do (
    clang++ -nostdinc++ -nostdlib -L "%LIBRARY_LIB%" -lc++ -std=c++14 -O2 -g %%i -o test_clang.exe
    if errorlevel 1 exit 1
    test_clang
    if errorlevel 1 exit 1
)
popd
if errorlevel 1 exit 1
