FROM occitech/magento:php5.5-apache

ENV MAGENTO_VERSION 1.7.0.2

RUN cd /tmp && curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && tar xvf $MAGENTO_VERSION.tar.gz && mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess /var/www/htdocs

RUN chown -R www-data:www-data /var/www/htdocs

RUN apt-get update && apt-get install -y mysql-client-5.5 libxml2-dev patch
RUN docker-php-ext-install soap
RUN pecl install xdebug-stable
RUN docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=1"  >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_host=$IDE_HOST" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ./bin/install-magento /usr/local/bin/install-magento

RUN chmod +x /usr/local/bin/install-magento

COPY ./sampledata/magento-sample-data-1.6.1.0.tar.gz /opt/
COPY ./bin/install-sampledata-1.6_1.8 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

# Apply patches
COPY ./patches/*.sh /var/www/htdocs/
RUN cd /var/www/htdocs && /bin/bash PATCH_SUPEE-2629_EE_1.12.0.0_v1-2015-02-12-04-30-34.sh

# Apply Mysql 5.6 support
COPY ./patches/Mysql4.php /opt/
RUN chown www-data:www-data /opt/Mysql4.php
COPY ./bin/enable-mysql-5.6-support /usr/local/bin/enable-mysql-5.6-support
RUN chmod +x /usr/local/bin/enable-mysql-5.6-support

VOLUME /var/www/htdocs
