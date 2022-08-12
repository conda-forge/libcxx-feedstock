set -ex

LLVM_PREFIX=$PREFIX

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"
fi

export CFLAGS="$CFLAGS -I$LLVM_PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$LLVM_PREFIX/lib -Wl,-rpath,$LLVM_PREFIX/lib -L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"
export PATH="$LLVM_PREFIX/bin:$PATH"

if [[ "$target_platform" != osx-* ]]; then
    # build libcxx first
    mkdir build
    cd build

    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
      -DLIBCXX_INCLUDE_DOCS=OFF \
      -DLIBCXX_INCLUDE_TESTS=OFF \
      -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
      ../libcxx

    make -j${CPU_COUNT} VERBOSE=1
    make install
    cd ..

    # now build libcxxabi
    cd libcxxabi
    mkdir build && cd build

    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR/libcxx \
      -DLIBCXXABI_LIBCXX_INCLUDES=$PREFIX/include/c++/v1 \
      -DLLVM_INCLUDE_TESTS=OFF \
      ..

    make -j${CPU_COUNT} VERBOSE=1
    make install
    cd ../..

    # now rebuild libcxx with libcxxabi
    mkdir build2
    cd build2

    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DLIBCXX_INSTALL_HEADERS=ON \
      -DLIBCXX_CXX_ABI=libcxxabi \
      -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRC_DIR/libcxxabi/include \
      -DLIBCXX_CXX_ABI_LIBRARY_PATH=$PREFIX/lib \
      -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
      -DLIBCXX_INCLUDE_DOCS=OFF \
      -DLIBCXX_INCLUDE_TESTS=OFF \
      -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
      ../libcxx

    make -j${CPU_COUNT} VERBOSE=1
    make install

    cd ..
else
    mkdir build
    cd build

    # on osx we point libc++ to the system libc++abi
    cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_OSX_SYSROOT=$CONDA_BUILD_SYSROOT \
      -DLIBCXX_CXX_ABI=libcxxabi \
      -DLIBCXX_CXX_ABI_INCLUDE_PATHS=${CONDA_BUILD_SYSROOT}/usr/include \
      -DLIBCXX_CXX_ABI_LIBRARY_PATH=${CONDA_BUILD_SYSROOT}/usr/lib \
      -DLIBCXX_ENABLE_NEW_DELETE_DEFINITIONS=ON \
      -DLIBCXX_ENABLE_VENDOR_AVAILABILITY_ANNOTATIONS=ON \
      -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
      -DLIBCXX_INCLUDE_DOCS=OFF \
      -DLIBCXX_INCLUDE_TESTS=OFF \
      ../libcxx

    make -j${CPU_COUNT} VERBOSE=1
    make install

    # on osx we point libc++ to the system libc++abi
    $INSTALL_NAME_TOOL -change "@rpath/libc++abi.1.dylib" "/usr/lib/libc++abi.dylib" $PREFIX/lib/libc++.1.0.dylib

    cd ..
fi
