set -e

FILES=test_sources/*.c
for f in $FILES
do
    clang -O2 -g $f
    ./a.out
done

FILES=test_sources/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -O2 -g $f
    ./a.out
done

FILES=test_sources/cpp11/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++11 -O2 -g $f
    ./a.out
done

FILES=test_sources/cpp14/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++14 -O2 -g $f
    ./a.out
done
