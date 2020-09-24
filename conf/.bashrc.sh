
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
  
  DESTINATION=${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-content/$1/${REPO_NAME}

  echo 'Please, wait ...'

  # this would cause mv below to match hidden files
  shopt -s dotglob
  
  echo 'Creating MySQL user and database ...'
  wp-init-database 1> /dev/null

  # move the workspace temporarily
  mkdir $HOME/workspace
  mv ${GITPOD_REPO_ROOT}/* $HOME/workspace/

  echo 'Installing WordPress ...'
  wget -q https://wordpress.org/latest.zip -O $HOME/wordpress.zip
  unzip -qn $HOME/wordpress.zip -d $HOME
  unlink $HOME/wordpress.zip
  cp $HOME/gitpod-wordpress/conf/.htaccess $HOME/wordpress/.htaccess
  mkdir $HOME/wordpress/database/
  wget -q https://www.adminer.org/latest.php -O $HOME/wordpress/database/index.php
  mkdir $HOME/wordpress/phpinfo/
  echo "<?php phpinfo(); ?>" > $HOME/wordpress/phpinfo/index.php
  
  # create webserver root and install WordPress there
  mkdir -p ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  mv $HOME/wordpress/* ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/

  # put the project files in the correct place
  mkdir $DESTINATION
  mv $HOME/workspace/* $DESTINATION
  
  # create a wp-config.php
  cp $HOME/gitpod-wordpress/conf/wp-config.php ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-config.php
  
  # create a debugger launch.json
  mkdir ${GITPOD_REPO_ROOT}/.theia
  mv $HOME/gitpod-wordpress/conf/launch.json ${GITPOD_REPO_ROOT}/.theia/launch.json

  # Setup WordPress database
  cd ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/
  wp core install \
    --url="$(gp url 8080 | sed -e s/https:\\/\\/// | sed -e s/\\///)" \
    --title="WordPress" \
    --admin_user="admin" \
    --admin_password="password" \
    --admin_email="admin@gitpod.test"

  cd $DESTINATION
  # install project dependencies
  if [ -f composer.json ]; then
    echo 'Installing Composer packages ...'
    composer update 2> /dev/null
  fi
  if [ -f package.json ]; then
    echo 'Installing NPM packages ...'
    npm i 2> /dev/null
  fi

  if [ -f $DESTINATION/.init.sh ]; then
    echo 'Running your .init.sh ...'
    /bin/sh $DESTINATION/.init.sh
  fi
  
  # finish
  shopt -u dotglob
  touch $FLAG
  
  echo 'Done!'
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
  ENDPOINT=${1:-""}
  PORT=${2:-"8080"}
  URL=$(gp url $PORT | sed -e s/https:\\/\\/// | sed -e s/\\///)
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

function browse-emails () {
  browse-url "/" "8025"
}

export -f browse-url
export -f browse-home
export -f browse-wpadmin
export -f browse-dbadmin
export -f browse-phpinfo
export -f browse-emails

# use Node.js LTS
nvm use lts/* > /dev/null
export NODE_VERSION=$(node -v | sed 's/v//g')

# WP-CLI auto completion
. $HOME/wp-cli-completion.bash
