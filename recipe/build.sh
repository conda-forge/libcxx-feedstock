mkdir build
cd build

LLVM_PREFIX=$PREFIX

if [[ "$target_platform" == "osx-64" ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

export CFLAGS="$CFLAGS -I$LLVM_PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$LLVM_PREFIX/lib -Wl,-rpath,$LLVM_PREFIX/lib -L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"
export PATH="$LLVM_PREFIX/bin:$PATH"

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install
cd ..

# Build libcxx with libcxxabi
mkdir build2
cd build2

if [[ "$target_platform" != "osx-64" ]]; then
    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLIBCXX_CXX_ABI=none \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      ..

    make -j${CPU_COUNT}
    make install

else
    # on osx we point libc++ to the system libc++abi
    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLIBCXX_CXX_ABI=libcxxabi \
      -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${CONDA_BUILD_SYSROOT}/usr/include \
      -DLIBCXX_CXX_ABI_LIBRARY_PATH=${CONDA_BUILD_SYSROOT}/usr/lib \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      ..

    make -j${CPU_COUNT}
    make install

    # on osx we point libc++ to the system libc++abi
    install_name_tool -change "@rpath/libc++abi.1.dylib" "/usr/lib/libc++abi.dylib" $PREFIX/lib/libc++.1.0.dylib
fi
