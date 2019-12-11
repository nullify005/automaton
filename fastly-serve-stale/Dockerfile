FROM nginx:1.16.1
COPY html /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/
COPY entrypoint.sh /usr/local/bin/
COPY timeout.py /usr/local/bin/
ENV debian_frontend noninteractive
RUN \
    apt-get update && \
    apt-get -y -f install python3 && \
    apt-get clean
CMD [ "entrypoint.sh" ]
