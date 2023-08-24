#!/bin/bash
set -ex

echo "NOMKL: $NOMKL"

if [ `uname` == Darwin ]; then
    if [ $NOMKL == 0 ]; then
        export ATLAS=1
        export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
    fi

    COMPILER_ARGS="config_cc --compiler=intelem config_fc --fcompiler=intelem"
    export CC=icc
    export CXX=icpc

    WHEELS_BUILD_ARGS=""

    #export SDKROOT=/opt/MacOSX10.10.sdk
    #export MACOSX_DEPLOYMENT_TARGET=10.10
else
    COMPILER_ARGS="config_cc --compiler=intelem config_fc --fcompiler=intelem"
    export CC=icc

    WHEELS_BUILD_ARGS="-p manylinux2014_x86_64"

    # Set RPATH for wheels
    export CFLAGS="-Wl,-rpath,\$ORIGIN/../../../..,-rpath,\$ORIGIN/../../../../..,-rpath,\$ORIGIN/../../../../../.. $CFLAGS"
    export LDFLAGS="-Wl,-rpath,\$ORIGIN/../../../..,-rpath,\$ORIGIN/../../../../..,-rpath,\$ORIGIN/../../../../../.. $LDFLAGS"
fi

export SCIPY_USE_PYTHRAN=0 # Disable building with pythran for now
$PYTHON setup.py ${COMPILER_ARGS} build --force install --old-and-unmanageable

# Build wheel package
if [ -n "${WHEELS_OUTPUT_FOLDER}" ]; then
    $PYTHON setup.py ${COMPILER_ARGS} bdist_wheel ${WHEELS_BUILD_ARGS}
    cp dist/scipy*.whl ${WHEELS_OUTPUT_FOLDER}
fi
