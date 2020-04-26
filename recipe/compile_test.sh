set -xe

LINK_FLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"

# target platform is empty here now
if [[ `uname -s` != "Darwin" ]]; then
    LINK_FLAGS="${LINK_FLAGS} -lc++abi"
else
  # https://stackoverflow.com/questions/60934005/clang-10-fails-to-link-c-application-with-cmake-on-macos-10-12
  info=$( ld -v 2>&1 > /dev/null )
  linkv=`echo "${info}" | perl -wne '/.ld64-(.*?)[^0-9]/ and print "$1\n"'`
  LINK_FLAGS="${LINK_FLAGS} -mlinker-version=${linkv}"
fi

FILES=test_sources/*.c
for f in $FILES
do
    clang -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/cpp11/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++11 -O2 -g $f $LINK_FLAGS
    ./a.out
done

FILES=test_sources/cpp14/*.cpp
for f in $FILES
do
    clang++ -stdlib=libc++ -std=c++14 -O2 -g $f $LINK_FLAGS
    ./a.out
done
