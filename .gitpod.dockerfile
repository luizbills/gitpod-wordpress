FROM buildpack-deps:disco

### settings ###
ENV PHP_VERSION="7.3"
ENV APACHE_DOCROOT="public_html"

### base ###
RUN yes | unminimize \
    && apt-get install -yq \
        asciidoctor \
        bash-completion \
        build-essential \
        htop \
        jq \
        less \
        locales \
        man-db \
        nano \
        software-properties-common \
        sudo \
        vim \
        multitail \
        lsof \
    && locale-gen en_US.UTF-8 \
    && mkdir /var/lib/apt/dazzle-marks \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

ENV LANG=en_US.UTF-8

### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

ENV HOME=/home/gitpod
WORKDIR $HOME

# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success"
# create .bashrc.d folder and source it in the bashrc
RUN mkdir /home/gitpod/.bashrc.d && \
    (echo; echo "for i in \$(ls \$HOME/.bashrc.d/*); do source \$i; done"; echo) >> /home/gitpod/.bashrc

RUN git clone https://github.com/luizbills/gitpod-wordpress /tmp/gitpod-wordpress
    && mv /tmp/gitpod-wordpress/conf /workspace/
    && rm -rf /tmp/*

### Apache webserver ###
USER root
RUN apt-get update \
    && apt-get -y install apache2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*
    && mkdir /workspace/${APACHE_DOCROOT}

# give write permission to the gitpod-user to apache directories
# let Apache use apache.conf and apache.env.sh from our /workspace/<myproject> folder
RUN chown -R gitpod:gitpod /var/run/apache2 /var/lock/apache2 /var/log/apache2 \
    && echo "include /workspace/conf/apache.conf" > /etc/apache2/apache2.conf \
    && echo ". \${GITPOD_REPO_ROOT}/apache.env.sh" > /etc/apache2/envvars

# create SSL keys
# USER root
# RUN openssl req -batch -new -x509 -newkey rsa:2048 -nodes -sha256 \
#     -subj /CN=*.{{ vccw.hostname }}/O=oreore -days 3650 \
#     -keyout /etc/apache2/ssl/wordpress.key \
#     -out /etc/apache2/ssl/wordpress.crt

### PHP ###
USER root
RUN add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install php${PHP_VERSION} \
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
    && sudo a2enmod php${PHP_VERSION} \
    && sudo service apache2 restart

### MySQL ###
USER root
RUN apt-get update \
    && apt-get install -y mysql-server \
    && apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* \
    && mkdir /var/run/mysqld \
    && chown -R gitpod:gitpod /etc/mysql /var/run/mysqld /var/log/mysql /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade

# Install our own MySQL config
RUN mv /workspace/conf/mysql.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
# Install default-login for MySQL clients
RUN mv /workspace/conf/client.cnf /etc/mysql/mysql.conf.d/client.cnf
RUN mv /workspace/conf/mysql-bashrc-launch.sh /etc/mysql/mysql-bashrc-launch.sh

USER gitpod
RUN echo "/etc/mysql/mysql-bashrc-launch.sh" >> ~/.bashrc
