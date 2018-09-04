FROM ubuntu
RUN apt-get update
RUN apt-get install -y iputils-ping
RUN ping 10.177.176.213
