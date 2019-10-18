set -e

test -f $PREFIX/include/c++/v1/iterator

LINK_FLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib -lc++abi"

FILES=test_sources/*.c
for f in $FILES
do
    $PREFIX/bin/clang -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/*.cpp
for f in $FILES
do
    $PREFIX/bin/clang++ -stdlib=libc++ -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/cpp11/*.cpp
for f in $FILES
do
    $PREFIX/bin/clang++ -stdlib=libc++ -std=c++11 -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/cpp14/*.cpp
for f in $FILES
do
    $PREFIX/bin/clang++ -stdlib=libc++ -std=c++14 -O2 -g $f $LINK_FLAGS
    ./a.out
done
