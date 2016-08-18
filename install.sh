#!/bin/bash

set -e

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    infix="Linux"
elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
    infix="MacOSX"
else
    infix="unknown"
fi

if [[ "$TRAVIS_PYTHON_VERSION" == "2.7" ]]; then
    url="https://repo.continuum.io/miniconda/Miniconda2-latest-$infix-x86_64.sh"
else
    url="https://repo.continuum.io/miniconda/Miniconda3-latest-$infix-x86_64.sh"
fi

pushd .
cd
mkdir -p download
cd download
echo "Cached in $HOME/download :"
ls -l
echo
if [[ ! -f miniconda-$infix.sh ]]
then
    wget $url -O "miniconda-$infix.sh"
fi
chmod +x miniconda-$infix.sh && ./miniconda-$infix.sh -b -p $HOME/miniconda
cd ..
export PATH="$HOME/miniconda/bin:$PATH"
popd

hash -r

conda config --set always_yes yes --set changeps1 no
conda update -q conda
conda info -a
conda create -q -n travisci python=$TRAVIS_PYTHON_VERSION nomkl numba numpy \
                            scipy pip sphinx sphinx_rtd_theme pygments \
                            pytest psutil
source activate travisci
conda install --yes -q -c numba llvmdev=3.7.1

if [ $TRAVIS_PYTHON_VERSION \< "3.4" ];
then
    conda install --yes -q enum34;
fi
