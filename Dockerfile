FROM debian:jessie
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates
RUN wget https://dl.bintray.com/emccode/rexray/stable/0.6.4/rexray-Linux-x86_64-0.6.4.tar.gz -O rexray.tar.gz && tar -xvzf rexray.tar.gz -C /usr/bin && rm rexray.tar.gz
RUN mkdir -p /run/docker/plugins /var/lib/libstorage/volumes
ENTRYPOINT ["rexray"]
CMD ["--help"]
