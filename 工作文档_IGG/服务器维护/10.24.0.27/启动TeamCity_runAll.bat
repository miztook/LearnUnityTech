@echo off

setlocal

SET TEAMCITY_RUNALL_CURRENT_DIR=%CD%
cd /d %~dp0

IF ""%1"" == ""start"" goto start
IF ""%1"" == ""stop"" goto stop
goto usage

:start
call:check_java %1
if %errorlevel% NEQ 0 goto :done
echo Starting TeamCity server and agent...
goto run

:stop
call:check_java %1
if %errorlevel% NEQ 0 goto :done
echo Stopping TeamCity server and agent...
goto run

:run
call teamcity-server.bat %1
cd ..\buildAgent\bin
call agent.bat %1 %2
cd ..\..\bin

goto done

:usage
echo "Usage: runAll.bat (start|stop[ force])"
goto done

:check_java
  ECHO Looking for installed Java...
  if exist ..\jre SET JRE_HOME=%cd%\..\jre
  set FJ_MIN_UNSUPPORTED_JAVA_VERSION=12
  CALL "%cd%\findJava.bat" "1.8" "%cd%\..\jre"
  IF ERRORLEVEL 0 exit /b 0
  ECHO Neither the JDK nor JRE is found. Cannot %1 the TeamCity Server and Agent.
  exit /b 1
goto:eof

:done

cd /d %TEAMCITY_RUNALL_CURRENT_DIR%
