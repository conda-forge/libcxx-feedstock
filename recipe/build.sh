set -ex

LLVM_PREFIX=$PREFIX

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT -framework CoreFoundation"

    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_OSX_SYSROOT=$CONDA_BUILD_SYSROOT"
    export CMAKE_ARGS="$CMAKE_ARGS -DLIBCXX_ENABLE_VENDOR_AVAILABILITY_ANNOTATIONS=ON"
    # we want to build against the system libcxxabi, not ship our own
    export CMAKE_ARGS="$CMAKE_ARGS -DLIBCXX_CXX_ABI=system-libcxxabi"
    export CMAKE_ARGS="$CMAKE_ARGS -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$CONDA_BUILD_SYSROOT/usr/include/c++/v1"
fi

export CFLAGS="$CFLAGS -I$LLVM_PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$LLVM_PREFIX/lib -Wl,-rpath,$LLVM_PREFIX/lib -L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"
export PATH="$LLVM_PREFIX/bin:$PATH"

mkdir build

cmake -G Ninja \
    -B build \
    -S runtimes \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIBCXX_ENABLE_TIME_ZONE_DATABASE=ON \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INCLUDE_DOCS=OFF \
    -DLIBCXX_INCLUDE_TESTS=OFF \
    -DLIBCXX_HARDENING_MODE="${hardening}" \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    $CMAKE_ARGS

# Build
ninja -C build cxx cxxabi unwind

# Install
ninja -C build install-cxx install-cxxabi install-unwind
