set -ex

get_cpu_arch() {
    local CPU_ARCH
    if [[ "$1" == *"-64" ]]; then
        CPU_ARCH="x86_64"
    elif [[ "$1" == *"-ppc64le" ]]; then
        CPU_ARCH="powerpc64le"
    elif [[ "$1" == *"-aarch64" ]]; then
        CPU_ARCH="aarch64"
    elif [[ "$1" == *"-s390x" ]]; then
        CPU_ARCH="s390x"
    else
        echo "Unknown architecture"
        exit 1
    fi
    echo $CPU_ARCH
}

LLVM_PREFIX=$PREFIX

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"

    export CMAKE_EXTRA_ARGS="-DCMAKE_OSX_SYSROOT=$CONDA_BUILD_SYSROOT -DLIBCXX_ENABLE_VENDOR_AVAILABILITY_ANNOTATIONS=ON"
else
    # should be cross_target_platform, but we're not cross-compiling here
    SYSROOT_PREFIX="$BUILD_PREFIX/$(get_cpu_arch $target_platform)-conda-linux-gnu/sysroot/lib64"
    # need sysroot for linking libdl and libpthread
    export LDFLAGS="$LDFLAGS -L$SYSROOT_PREFIX -Wl,-rpath,$SYSROOT_PREFIX"
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
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INCLUDE_DOCS=OFF \
    -DLIBCXX_INCLUDE_TESTS=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    $CMAKE_ARGS \
    $CMAKE_EXTRA_ARGS

# Build
ninja -C build cxx cxxabi unwind

# Install
ninja -C build install-cxx install-cxxabi install-unwind

if [[ "$target_platform" == osx-* ]]; then
    # on osx we point libc++ to the system libc++abi
    $INSTALL_NAME_TOOL -change "@rpath/libc++abi.1.dylib" "/usr/lib/libc++abi.dylib" $PREFIX/lib/libc++.1.0.dylib
fi
