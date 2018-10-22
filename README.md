# Felix 
Xref analyser for Progress 4GL running in Docker container

## Getting Started
These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites
You need [Docker](https://store.docker.com/editions/community/docker-ce-desktop-windows) to use Felix. You can get latest version [here](https://store.docker.com/editions/community/docker-ce-desktop-windows).

After instalation you need to allow host system to share files with Docker container. 
Go to ```Docker settings -> Shared Drives -> Select Drive where you cloned this repository -> Click Apply```


![Docker Settings option](http://www.part.lt/img/9dc8069e06747189197d8d53e30318d1373.png)
![Shared Drives](http://www.part.lt/img/89af75684eabbad66f2eece2dd41bade640.png)

Navigate to ```dirWhereYouClonedThisRepo```.
To get your app up and running you need to add..

**into /progress directory:**

- *11.7-Linux64-XXXX-XX-XX.txt* file, required to install Progress. 

- *PROGRESS_OE_11.7.3_LNX_64_UPDATE.tar.gz* make sure, that you add this exact version of Progress. Felix works only with 11.7 and newer versions

**into /sources directory:**

- *Your source files for analysis*

Then navigate to ```dirWhereYouClonedThisRepo/scripts/Docker```.

*Auto setup*
- Run **autoSetup.bat** - this will automatically build Docker Image and run container. This may take a while, because 
it`s installing Progress into Docker image.

*Manual setup*

- Run **buildImage.bat** - this will build an image from *DockerFile*. This may take a while.

- Run **runContainer.bat** to run container from the image.

After this step, you can start Xref analysis:

- Open your browser, go to ***localhost:4530*** and add new system for analysis. If you experiencing problems, - follow user guide. 

- Run **xrefAnalysis.bat** to start analysing your system source files