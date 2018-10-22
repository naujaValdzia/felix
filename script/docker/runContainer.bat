@echo off
cd ../../
set shortPath=%cd:\=/%

docker run --name felix -t -d -p 4520:4520 -p 14440:14440 -p 14450:14450 -p 4530:3000 -v "%shortPath%"/db:/usr/db -v "%shortPath%"/sources:/usr/sources -v /dev/shm:/dev/shm -v "%shortPath%"/tmp:/tmp felix
echo[
docker container ls -a
echo[
echo [DONE] Docker container is now running
echo Go to localhost:4530 to continue..
echo[
timeout /t 5