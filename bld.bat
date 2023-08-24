echo on

REM Align numpy intel fortran compiler flags with what is expected by scipy.
REM Regarding /fp:strict and /assume:minus0 see: https://github.com/scipy/scipy/issues/17075 
REM Regarding /fpp The pre-processor flag is not enabled on older numpy.
powershell -Command "(gc %SP_DIR%\numpy\distutils\fcompiler\intel.py) -replace '''/nologo'', ', '''/nologo'', ''/fpp'', ''/fp:strict'', ''/assume:minus0'', ' | Out-File -encoding ASCII %SP_DIR%\numpy\distutils\fcompiler\intel.py"
if errorlevel 1 exit 1

set DISTUTILS_USE_SDK=1
set MSSdk=1
set "PY_VCRUNTIME_REDIST=%LIBRARY_BIN%\vcruntime140.dll"
set "MKL=%LIBRARY_PREFIX%"
set "CFLAGS=/GX /EHsc /fpp %CFLAGS%"

rem Disable building with pythran for now
set SCIPY_USE_PYTHRAN=0

%PYTHON% setup.py config_cc --compiler=intelemw config_fc --fcompiler=intelvem build --force install --old-and-unmanageable
if errorlevel 1 exit 1

rem Build wheel package
if NOT "%WHEELS_OUTPUT_FOLDER%"=="" (
    %PYTHON% setup.py config_cc --compiler=intelemw config_fc --fcompiler=intelvem bdist_wheel
    if errorlevel 1 exit 1

    copy dist\scipy*.whl %WHEELS_OUTPUT_FOLDER%
    if errorlevel 1 exit 1
)
