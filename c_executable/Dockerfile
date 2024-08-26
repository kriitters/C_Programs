# This follows the example from vice cli https://github.com/cyverse-vice/cli/blob/main/bash/
#   to get a bash shell / terminal running on CyVerse.
FROM ubuntu:23.10
USER root
RUN  apt-get update \
    &&  apt-get install apt-utils dialog -y \
	&&  apt-get autoremove -y \
    &&  apt-get clean all
# gettext-base is needed for command envsubst in entry.sh
RUN apt-get update && \
	apt-get install gettext-base  -y && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# getting locales error
RUN apt-get update && apt-get install locales && locale-gen en_US.UTF-8
# 
ENV TZ America/Phoenix
ENV LANG=C.UTF-8 
ENV LC_ALL "en_US.UTF-8"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
# Add sudo to user ubuntu; this is needed to run a chown on a dynamic volume mount in entry.sh
RUN apt-get update && \
    apt-get install -y sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
   apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#
# install gdal for image processing
RUN apt-get update && \
	apt-get install gdal-bin libgdal-dev libudunits2-0 libudunits2-dev -y && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#
USER ubuntu
WORKDIR /home/ubuntu
# use this to here for testing
#ENTRYPOINT ["bash"]
RUN export HOME=/home/ubuntu
# add directory for iRODS iCommands to user profile as JSON, see entry.sh
RUN mkdir /home/ubuntu/.irods 
#
# Copy C executables ( portable linux versions with static build/link )
COPY spatcon_lin64 /home/ubuntu/spatcon_lin64
RUN sudo chmod +x /home/ubuntu/spatcon_lin64
COPY grayspatcon_lin64 /home/ubuntu/grayspatcon_lin64
RUN sudo chmod +x /home/ubuntu/grayspatcon_lin64
#
WORKDIR /home/ubuntu/data-store/
COPY entry.sh /home/ubuntu/entry.sh
RUN sudo chmod +x /home/ubuntu/entry.sh
ENTRYPOINT ["bash", "/home/ubuntu/entry.sh"]