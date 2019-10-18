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

if [[ "$target_platform" != "osx-64" ]]; then
    # Build libcxxabi
    # cd libcxxabi
    # mkdir build && cd build
    #
    # cmake \
    #   -DCMAKE_INSTALL_PREFIX=$PREFIX \
    #   -DCMAKE_BUILD_TYPE=Release \
    #   -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR \
    #   -DLIBCXXABI_LIBCXX_INCLUDES=$SRC_DIR/include \
    #   -DLLVM_INCLUDE_TESTS=OFF \
    #   -DLLVM_INCLUDE_DOCS=OFF \
    #   ..
    #
    # make -j${CPU_COUNT}
    # make install
    # cd ../..

    # cxxabi_inc=$SRC_DIR/libcxxabi/include
    # cxxabi_lib=$PREFIX/lib

    cxxabi_inc=$PREFIX/include
    cxxabi_lib=$PREFIX/lib
else
    # on osx we point libc++ to the system libc++abi
    cxxabi_inc=${CONDA_BUILD_SYSROOT}/usr/include
    cxxabi_lib=${CONDA_BUILD_SYSROOT}/usr/lib
fi

# Build libcxx with libcxxabi
mkdir build2
cd build2

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${cxxabi_inc} \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=${cxxabi_lib} \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install

if [[ "$target_platform" == "osx-64" ]]; then
    # on osx we point libc++ to the system libc++abi
    install_name_tool -change "@rpath/libc++abi.1.dylib" "/usr/lib/libc++abi.dylib" $PREFIX/lib/libc++.1.0.dylib
fi
