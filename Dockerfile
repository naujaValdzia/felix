FROM centos

#download required files and create directories for progress.cfg file
RUN \
  yum install -y net-tools && \
  yum install -y rng-tools && \
  yum install -y nano && \
  yum install -y git && \
  yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
  yum install -y nodejs npm --enablerepo=epel && \
  mkdir /install && \
  mkdir /install/openedge

# the install file has to be in "progress" directory
ADD progress/PROGRESS_OE_11.7.3_LNX_64_UPDATE.tar.gz /install/openedge

# you need a response.ini from a previous install
COPY progress/oe-11.7.3-lnx-x64-dev.response.ini /install/openedge/response.ini

# next three lines adds license codes from 11.7-Linux64-*.txt file to response.ini file
COPY progress/11.7-Linux64-*.txt /install/openedge/11.7-Linux64.txt
COPY script/progress/writeLicense.sh /install/openedge/writeLicense.sh
RUN (cd /install/openedge; ./writeLicense.sh)

ENV TERM xterm

RUN /install/openedge/proinst -b /install/openedge/response.ini -l /install/install_oe.log -n && \
	rm -rf /install/openedge

ENV DLC=/usr/dlc
ENV WRKDIR=/usr/wrk
ENV PATH=$DLC:$DLC/bin:$PATH

RUN git clone https://github.com/progress/Spark-Toolkit.git /$DLC/servers/pasoe/Spark

RUN $DLC/servers/pasoe/bin/tcman.sh create -f -p 4520 -P 4521 -s 4522 $DLC/servers/pasoe/felix
RUN mkdir /$DLC/servers/pasoe/felix/dev 

ENV CATALINA_BASE=$DLC/servers/pasoe/felix
ENV JAVA_HOME=/usr/dlc/jdk
ENV PATH=$JAVA_HOME/bin:$PATH

COPY server/core/src /$DLC/servers/pasoe/felix/dev/felix_core/src
COPY server/api /$DLC/servers/pasoe/felix/dev/felix_API/
COPY server/shared /$DLC/servers/pasoe/felix/dev/felix_shared/
COPY client /$DLC/servers/pasoe/felix/dev/felix_front/
COPY script/felix /$DLC/servers/pasoe/felix/dev/felix_core/src/scripts

RUN npm install --prefix /usr/dlc/servers/pasoe/felix/dev/felix_front/felix

RUN cp -R /$DLC/servers/pasoe/Spark/dist/Ccs.pl /usr/dlc/servers/pasoe/felix/openedge && \
	cp -R /$DLC/servers/pasoe/Spark/dist/Spark.pl /usr/dlc/servers/pasoe/felix/openedge && \
	cp -R /$DLC/servers/pasoe/felix/dev/felix_shared/config/startup.pf /usr/dlc/servers/pasoe/felix/openedge

RUN (cd /$DLC/servers/pasoe/felix/dev/felix_shared/config/; proant)
	
RUN $DLC/servers/pasoe/bin/oeprop.sh -f /$DLC/servers/pasoe/felix/dev/felix_shared/config/AppServer.txt
RUN $DLC/servers/pasoe/felix/bin/tcman.sh deploy -a felix /$DLC/servers/pasoe/felix/dev/felix_shared/config/felix.war

RUN chmod a+rwx $DLC/servers/pasoe/felix/dev/felix_core/src/scripts/startup.sh && \ 
	chmod a+rwx $DLC/servers/pasoe/felix/dev/felix_core/src/scripts/createDB.sh && \
	chmod -R a+rwx /usr/dlc/servers/pasoe/felix/dev/felix_front/felix/node_modules/.bin/ && \
	chmod -R a+x /usr/dlc/servers/pasoe/felix/dev/felix_core

CMD /$DLC/servers/pasoe/felix/dev/felix_core/src/scripts/startup.sh