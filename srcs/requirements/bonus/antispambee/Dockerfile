FROM php:7.4-alpine

WORKDIR /var/www

# Install other required packages
RUN apk --no-cache add wget && \
    wget https://downloads.wordpress.org/plugin/antispam-bee.latest-stable.zip && \
    unzip antispam-bee.latest-stable.zip && \
    rm antispam-bee.latest-stable.zip && \
    chown -R root:root /var/www/

EXPOSE 8081

CMD ["php", "-S", "[::]:8082", "-t", "/var/www"]

