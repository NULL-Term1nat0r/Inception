FROM alpine:3.19.0

RUN apk add mariadb mariadb-client
COPY .env /usr/local/bin
COPY requirements/mariadb/conf/create_db.sh /usr/local/bin

ENTRYPOINT ["create_db.sh"]