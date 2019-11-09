
# WordPress Setup Script
export REPO_NAME=$(basename $GITPOD_REPO_ROOT)

function wp-init-database () {
  # user     = wordpress
  # password = wordpress
  # database = wordpress
  mysql -e "CREATE DATABASE wordpress /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  mysql -e "CREATE USER wordpress@localhost IDENTIFIED BY 'wordpress';"
  mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
  mysql -e "FLUSH PRIVILEGES;"
}

function wp-setup () {
  FLAG="$HOME/.wordpress-installed"

  # search the flag file
  if [ -f $FLAG ]; then
    echo 'WordPress already installed'
    return 1
  fi

  # this would cause mv below to match hidden files
  shopt -s dotglob

  wp-init-database

  DESTINATION=${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-content/$1/${REPO_NAME}
  
  # install project dependencies
  cd ${GITPOD_REPO_ROOT}
  if [ -f composer.json ]; then
    composer install
  fi
  if [ -f package.json ]; then
    npm install
  fi

  # move the workspace temporarily
  mkdir $HOME/workspace
  mv ${GITPOD_REPO_ROOT}/* $HOME/workspace/

  # create webserver root and install WordPress there
  mkdir -p ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  mv $HOME/wordpress/* ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/

  # put the project files in the correct place
  mkdir $DESTINATION
  mv $HOME/workspace/* $DESTINATION
  
  # create a wp-config.php
  cp $HOME/gitpod-wordpress/conf/wp-config.php ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-config.php

  # Setup WordPress database
  cd ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/
  wp core install \
    --url="$(gp url 8080 | sed -e s/https:\\/\\/// | sed -e s/\\///)" \
    --title="WordPress" \
    --admin_user="admin" \
    --admin_password="password" \
    --admin_email="admin@gitpod.test"

  cd $DESTINATION

  if [ -f $DESTINATION/init.sh ]; then
    /bin/sh $DESTINATION/init.sh
  fi
  
  shopt -u dotglob
  touch $FLAG
}

function wp-setup-theme () {
  wp-setup "themes"
}

function wp-setup-plugin () {
  wp-setup "plugins"
}

export -f wp-setup-theme
export -f wp-setup-plugin

# Helpers
function browse-url () {
  URL=$(gp url 8080 | sed -e s/https:\\/\\/// | sed -e s/\\///)
  ENDPOINT=${1:-""}
  gp preview "${URL}${ENDPOINT}"
}

function browse-home () {
  browse-url "/"
}

function browse-wpadmin () {
  browse-url "/wp-admin"
}

function browse-dbadmin () {
  browse-url "/database"
}

function browse-phpinfo () {
  browse-url "/phpinfo"
}

function browse-mails () {
  echo 'Not implemented yet.';
}

export -f open-url
export -f browse-home
export -f open-wpadmin
export -f open-dbadmin
export -f open-phpinfo
export -f open-mails
