if [[ "$target_platform" == "osx-64" ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

export CFLAGS="$CFLAGS -I$PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"

if [[ "$target_platform" != "osx-64" ]]; then
    # build libcxx first
    mkdir build
    cd build

    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      ..

    make -j${CPU_COUNT}
    make install
    cd ..
fi

if [[ "$target_platform" != "osx-64" ]]; then
  LIBCXXABI_PREFIX=$PREFIX
else
  LIBCXXABI_PREFIX=$BUILD_PREFIX
fi

# now build libcxxabi
# This is needed on OSX to properly re-export the symbols for ABI version 2
cd libcxxabi
mkdir build && cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$LIBCXXABI_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR \
  -DLIBCXXABI_LIBCXX_INCLUDES=$SRC_DIR/include \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install
cd ../..

# now rebuild libcxx with libcxxabi
mkdir build2
cd build2

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRC_DIR/libcxxabi/include \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=$LIBCXXABI_PREFIX/lib \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install

cd ..

if [[ "$target_platform" == "osx-64" ]]; then
    # on osx we point libc++ to the system libc++abi
    $INSTALL_NAME_TOOL -change "@rpath/libc++abi.1.dylib" "/usr/lib/libc++abi.dylib" $PREFIX/lib/libc++.1.0.dylib
    $NM -g $PREFIX/lib/libc++.dylib  | grep __ZNSt8bad_castD1Ev
fi
