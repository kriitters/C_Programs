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
ENTRYPOINT ["bash"]
