# set base image (host OS)
FROM python:3.8

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY requirements.txt .

COPY prom_explorer_example.py .

RUN export  DEBIAN_FRONTEND=noninteractive && \
     export DEBIAN_RELEASE=$(awk -F'[" ]' '/VERSION=/{print $3}'  /etc/os-release | tr -cd '[[:alnum:]]._-' ) && \
     echo "remove main from /etc/apt/sources.list" && \
     sed -i '/main/d' /etc/apt/sources.list && \
     echo "remove contrib from /etc/apt/sources.list" && \
     sed -i '/contrib/d' /etc/apt/sources.list && \
     echo "remove non-free from /etc/apt/sources.list" && \
     sed -i '/non-free/d' /etc/apt/sources.list && \
     echo "deb http://httpredir.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free"  >> /etc/apt/sources.list && \
     echo "deb http://httpredir.debian.org/debian ${DEBIAN_RELEASE}-updates main contrib non-free"  >> /etc/apt/sources.list && \
     echo "deb http://security.debian.org ${DEBIAN_RELEASE}/updates main contrib non-free"  >> /etc/apt/sources.list && \
    set -x &&\
    apt-get update && \
    apt-get -y install snmp snmpd snmp-mibs-downloader libsnmp-dev && \
    rm -r /var/lib/apt/lists/* && \
    apt-get clean

# install dependencies
RUN pip install -r requirements.txt

EXPOSE 8000
# copy the content of the local src directory to the working directory
#COPY src/ .



# command to run on container start
CMD [ "python3", "./prom_explorer_example.py" ]