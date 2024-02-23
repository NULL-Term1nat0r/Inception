FROM alpine:3.19.0

RUN apk add mariadb mariadb-client
COPY requirements/mariadb/conf/create_db.sh /usr/local/bin

ENTRYPOINT ["create_db.sh"]