# Gitpod docker image for WordPress | https://github.com/luizbills/gitpod-wordpress
# License: MIT (c) 2019 Luiz Paulo "Bills"
# Version: 0.2

FROM gitpod/workspace-mysql

### General Settings ###
ENV PHP_VERSION="7.3"
ENV APACHE_DOCROOT="public_html"

# - download config files
# - install WordPress setup scripts
# - install latest LTS Node.js version
# - update NPM
USER gitpod
ADD https://api.github.com/repos/luizbills/gitpod-wordpress/compare/master...HEAD /dev/null
RUN git clone https://github.com/luizbills/gitpod-wordpress $HOME/gitpod-wordpress \
    && cat $HOME/gitpod-wordpress/conf/.bashrc.sh >> $HOME/.bashrc \
    && bash -c ". .nvm/nvm.sh \
        && nvm install stable --lts \
        && npm install -g npm"

# - install Apache
# - install PHP
# - install WP-CLI
# - install Xdebug
USER root
RUN apt-get update \
    && apt-get -y install apache2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
    && chown -R gitpod:gitpod /var/run/apache2 /var/lock/apache2 /var/log/apache2 \
    && echo "include ${HOME}/gitpod-wordpress/conf/apache.conf" > /etc/apache2/apache2.conf \
    && echo ". ${HOME}/gitpod-wordpress/conf/apache.env.sh" > /etc/apache2/envvars \
    && apt-get -y remove php* \
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
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-opcache \
        php-xdebug \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* \
    && cat $HOME/gitpod-wordpress/conf/php.ini >> /etc/php/${PHP_VERSION}/apache2/php.ini \
    && a2dismod mpm_event \
    && a2enmod mpm_prefork \
    && a2dismod php* \
    && a2enmod php${PHP_VERSION} \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -O $HOME/wp-cli.phar \
    && chmod +x $HOME/wp-cli.phar \
    && mv $HOME/wp-cli.phar /usr/local/bin/wp \
    && chown gitpod:gitpod /usr/local/bin/wp

# - download WordPress from https://wordpress.org
# - download Adminer from https://www.adminer.org/
# - create a endpoint with phpinfo()
USER gitpod
RUN wget https://wordpress.org/latest.zip -O $HOME/wordpress.zip \
    && unzip -qn $HOME/wordpress.zip -d $HOME \
    && unlink $HOME/wordpress.zip \
    && cp $HOME/gitpod-wordpress/conf/.htaccess $HOME/wordpress/.htaccess \
    && mkdir $HOME/wordpress/database/ \
    && wget https://github.com/vrana/adminer/releases/download/v4.7.4/adminer-4.7.4-mysql.php \
        -O $HOME/wordpress/database/index.php \
    && mkdir $HOME/wordpress/phpinfo/ \
    && echo "<?php phpinfo(); ?>" > $HOME/wordpress/phpinfo/index.php
