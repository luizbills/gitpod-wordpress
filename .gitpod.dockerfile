FROM gitpod/workspace-mysql

### settings ###
ENV PHP_VERSION="7.3"
ENV APACHE_DOCROOT="public_html"

### Apache Webserver ###
USER root
RUN apt-get update \
    && apt-get -y install apache2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
    && mkdir /workspace/${APACHE_DOCROOT} \
    && chown -R gitpod:gitpod /var/run/apache2 /var/lock/apache2 /var/log/apache2 /workspace/${APACHE_DOCROOT} \
    && echo "include /workspace/conf/apache.conf" > /etc/apache2/apache2.conf \
    && echo ". workspace/conf/apache.env.sh" > /etc/apache2/envvars

# create SSL keys
# USER root
# RUN openssl req -batch -new -x509 -newkey rsa:2048 -nodes -sha256 \
#     -subj /CN=*.{{ vccw.hostname }}/O=oreore -days 3650 \
#     -keyout /etc/apache2/ssl/wordpress.key \
#     -out /etc/apache2/ssl/wordpress.crt

### PHP ###
USER root
RUN apt-get -y purge php* \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install libapache2-mod-php \
        php${PHP_VERSION} \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-opcache \
    && a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && a2enmod php${PHP_VERSION}
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
