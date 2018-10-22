@echo off
echo List of available containers:
echo[
docker container ls -a
echo[
echo Initializing...
echo[
docker stop felix
echo [STOPPED] Container Felix is no longer active
echo[
docker rm felix
echo [DELETED] Container Felix is no longer available
timeout /t 5