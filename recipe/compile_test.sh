set -xe

FLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib -Wl,-v -v"

# target platform is empty here now
if [[ "$target_platform" == osx* ]]; then
    llvm-nm $PREFIX/lib/libc++.1.dylib
    # to be able to use libc++'s tzdb code
    FLAGS="${FLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
    FLAGS="${FLAGS} -lc++abi"
fi

FILES=test_sources/*.c
for f in $FILES
do
    clang -O2 -g $f $FLAGS
    ./a.out
done

FILES=test_sources/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -O2 -g $f $FLAGS
    ./a.out
done

FILES=test_sources/cpp11/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++11 -O2 -g $f $FLAGS
    ./a.out
done

FILES=test_sources/cpp14/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++14 -O2 -g $f $FLAGS
    ./a.out
done

if [[ "$target_platform" == linux* ]]; then
# tzdb integration (experimental as of v19)
cd test_sources/tzdb
clang++ -stdlib=libc++ -fexperimental-library -std=c++20 -O2 -g tzdb.cpp -o tzdb $FLAGS
./tzdb

# also test tzdb without any environment activation
unset PREFIX
unset CONDA_PREFIX
./tzdb
fi
