set -e

info=$( ld -v 2>&1 > /dev/null )
export TEST_LD_VER=`echo "${info}" | perl -wne '/.ld64-(.*?)[^0-9]/ and print "$1\n"'`

pushd test_sources/pybind11_excetion_rtti_test
make test
popd
