mkdir build
cd build

export CFLAGS="$CFLAGS -I$PREFIX/include -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -L$BUILD_PREFIX/lib -Wl,-rpath,$BUILD_PREFIX/lib"

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install
cd ..

# Build libcxxabi
cd libcxxabi
mkdir build && cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR \
  -DLIBCXXABI_LIBCXX_INCLUDES=$SRC_DIR/include \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
make install
cd ../..

# Build libcxx with libcxxabi
mkdir build2
cd build2

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRC_DIR/libcxxabi/include \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH=$PREFIX/lib \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  ..

make -j${CPU_COUNT}
rm ${PREFIX}/lib/libc++.*
make install
