# Gitpod docker image for WordPress | https://github.com/luizbills/.gitpod-conf
# License: MIT (c) 2020 Luiz Paulo "Bills"
# Version: 0.9

FROM gitpod/workspace-base:latest

## General Settings ##
ENV PHP_VERSION="7.4"
ENV APACHE_DOCROOT="public_html"

## Get the settings files
USER gitpod
ADD "https://api.wordpress.org/secret-key/1.1/salt?time=1654516901" skipcache
RUN git clone --branch next https://github.com/luizbills/gitpod-wordpress/ /home/gitpod/.gitpod-conf

## Install nvm and NodeJS (version: LTS)
# RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
#     bash -c ". .nvm/nvm.sh && nvm install --lts"

# ## Install Go
# ENV GO_VERSION="1.17.11"
# ENV GOPATH=$HOME/go-packages
# ENV GOROOT=$HOME/go
# ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
# RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar xzs

# ### Install Mailhog
# RUN go install github.com/mailhog/MailHog@latest && \
#     go install github.com/mailhog/mhsendmail@latest && \
#     sudo cp $GOPATH/bin/MailHog /usr/local/bin/mailhog && \
#     sudo cp $GOPATH/bin/mhsendmail /usr/local/bin/mhsendmail && \
#     sudo ln $GOPATH/bin/mhsendmail /usr/sbin/sendmail && \
#     sudo ln $GOPATH/bin/mhsendmail /usr/bin/mail &&\
#     sudo rm -rf $GOPATH/src $GOPATH/pkg /home/gitpod/.cache/go /home/gitpod/.cache/go-build

## Install WebServer
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN add-apt-repository -y ppa:ondrej/php \
    && install-packages \
        # Install MariaDB
        mariadb-server \
        # Install Apache
        apache2 \
        # Install PHP and modules
        php${PHP_VERSION} \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-ctype \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip

### Setup WebServer
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    chown -R gitpod:gitpod /etc/apache2 /var/run/apache2 /var/lock/apache2 /var/log/apache2 && \
    echo "include /home/gitpod/.gitpod-conf/conf/apache.conf" > /etc/apache2/apache2.conf && \
    echo ". /home/gitpod/.gitpod-conf/conf/apache.env.sh" > /etc/apache2/envvars && \
    mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R gitpod:gitpod /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql && \
    cat home/gitpod/.gitpod-conf/conf/mysql.cnf > /etc/mysql/mariadb.conf.d/100-mysql-gitpod.cnf && \
    cat /home/gitpod/.gitpod-conf/conf/php.ini >> /etc/php/${PHP_VERSION}/apache2/php.ini

## Install WP-CLI
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /home/gitpod/wp-cli.phar && \
    chmod +x /home/gitpod/wp-cli.phar && \
    mv /home/gitpod/wp-cli.phar /usr/local/bin/wp && \
    chown gitpod:gitpod /usr/local/bin/wp

## Setup .bashrc
RUN cat /home/gitpod/.gitpod-conf/conf/.bashrc.sh >> /home/gitpod/.bashrc && \
    # cat /home/gitpod/.gitpod-conf/conf/mysql-bashrc-launch.sh >> /home/gitpod/.bashrc && \
    echo  >> /home/gitpod/.bashrc && \
    . /home/gitpod/.bashrc

USER gitpod
RUN cat /etc/mysql/mariadb.conf.d/100-mysql-gitpod.cnf && sleep 10
RUN mysqld --daemonize && sleep 10
