mkdir build
cd build

export CC=clang CXX=clang++
cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  ..

make -j${CPU_COUNT}
make install
cd ..

# Build libcxxabi
curl -L -O http://llvm.org/releases/${PKG_VERSION}/libcxxabi-${PKG_VERSION}.src.tar.xz
tar -xvf libcxxabi-${PKG_VERSION}.src.tar.xz --no-same-owner
cd libcxxabi-${PKG_VERSION}.src

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXXABI_LIBCXX_PATH=$SRC_DIR \
  -DLIBCXXABI_LIBCXX_INCLUDES=$SRC_DIR/include \
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
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS=$SRC_DIR/libcxxabi-${PKG_VERSION}.src/include \
  ..

make -j${CPU_COUNT}
rm ${PREFIX}/lib/libc++.*
make install
