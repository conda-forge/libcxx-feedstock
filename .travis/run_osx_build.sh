#!/usr/bin/env bash

set -x



echo "Installing a fresh version of Miniconda." && echo -en 'travis_fold:start:install_miniconda\\r'
MINICONDA_URL="https://repo.continuum.io/miniconda"
MINICONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh"
curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
bash $MINICONDA_FILE -b
echo -en 'travis_fold:end:install_miniconda\\r'

echo "Configuring conda." && echo -en 'travis_fold:start:configure_conda\\r'
source ~/miniconda3/bin/activate root

conda install -n root -c conda-forge --quiet --yes conda-forge-ci-setup=2 conda-build

echo "Mangling homebrew in the CI to avoid conflicts." && echo -en 'travis_fold:start:mangle_homebrew\\r'
/usr/bin/sudo mangle_homebrew
/usr/bin/sudo -k
echo -en 'travis_fold:end:mangle_homebrew\\r'

mangle_compiler ./ ./recipe .ci_support/${CONFIG}.yaml
setup_conda_rc ./ ./recipe ./.ci_support/${CONFIG}.yaml


source run_conda_forge_build_setup
echo -en 'travis_fold:end:configure_conda\\r'

set -e

make_build_number ./ ./recipe ./.ci_support/${CONFIG}.yaml

conda build ./recipe -m ./.ci_support/${CONFIG}.yaml --clobber-file ./.ci_support/clobber_${CONFIG}.yaml

upload_package ./ ./recipe ./.ci_support/${CONFIG}.yaml