cd ../../
set shortPath=%cd:\=/%
start /wait docker image build -t felix .
start /wait docker run --name felix -t -d -p 4520:4520 -p 14440:14440 -p 14450:14450 -p 4530:3000 -v "%shortPath%"/db:/usr/db -v "%shortPath%"/sources:/usr/sources -v /dev/shm:/dev/shm felix
echo[
docker container ls -a
echo[
echo [DONE] Docker successfully built Felix Image and started Felix container.
echo Go to localhost:4520 and create system to continue..
echo[
timeout /t 5