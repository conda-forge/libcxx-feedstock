set -ex

LLVM_PREFIX=$PREFIX

if [[ "$target_platform" == osx-* ]]; then
    export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    export LDFLAGS="$LDFLAGS -isysroot $CONDA_BUILD_SYSROOT"

    export CMAKE_EXTRA_ARGS="-DCMAKE_OSX_SYSROOT=$CONDA_BUILD_SYSROOT -DLIBCXX_ENABLE_VENDOR_AVAILABILITY_ANNOTATIONS=ON"
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
    -DLIBCXX_HARDENING_MODE="fast" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    $CMAKE_ARGS \
    $CMAKE_EXTRA_ARGS

# Build
ninja -C build cxx cxxabi unwind

# Install
ninja -C build install-cxx install-cxxabi install-unwind

if [[ "$target_platform" == linux-* ]]; then
    # point libcxxabi & libcxx (the actual libs, not the symlinks) to the
    # libunwind from https://github.com/conda-forge/libunwind-feedstock
    for f in $PREFIX/lib/libc++abi.so.1.0 $PREFIX/lib/libc++.so.1.0; do
        # first SOVER is the one from LLVM, the second is what we're replacing it with
        patchelf --replace-needed libunwind.so.1 libunwind.so.8 --output patched $f
        chmod +x patched
        mv patched $f
    done
fi
