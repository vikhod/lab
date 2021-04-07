
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y curl
RUN apt-get update && apt-get install -y nginx
# RUN apt-get update && apt-get install -y python
RUN apt-get update && apt-get install -y libpython2.7
# RUN apt-get update && apt-get install -y libatlas3-base

WORKDIR /var/www/html/
ADD index.html ./
ADD uwsgi ./
ADD foobar.py ./

#WORKDIR /var/www/html/
#RUN ./uwsgi --http :9090 --wsgi-file foobar.py

RUN nginx

EXPOSE 80
EXPOSE 9090

#CMD ["nginx", "-g", "daemon off;"]
WORKDIR /var/www/html/
CMD ["./uwsgi", "--http", ":9090", "--wsgi-file", "foobar.py"]
