FROM debian:bullseye-slim

RUN apt -y update && apt -y upgrade \
&&  apt -y --no-install-recommends install \
        apache2 libapache2-mod-php ca-certificates \
		php-curl php-json php-zip php-xml \
		curl \
&&  apt -y autoremove && apt -y autoclean \
&&  ln -s ../mods-available/headers.load /etc/apache2/mods-enabled/ \
&&  ln -s ../mods-available/ssl.load /etc/apache2/mods-enabled/ \
&&  true

COPY server.key /etc/ssl/private/server.key
COPY server.crt /etc/ssl/certs/server.crt
COPY server.conf /etc/apache2/sites-enabled/1-server.conf

RUN cd /var/www \
&&  curl -fsSL 'https://getcomposer.org/installer' | php -- --install-dir=/usr/bin --filename=composer \
&&  composer require 'jumbojett/openid-connect-php' \
&&  true

COPY index.php /var/www/html/index.php

COPY runapache /

EXPOSE 80
EXPOSE 443

WORKDIR /var/www

CMD [ "/bin/bash", "-c", "/runapache" ]

