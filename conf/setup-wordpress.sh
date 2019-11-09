
# WordPress Setup Script
function _wp_setup () {
  FLAG=".wordpress-installed"

  # search the flag file
  if [ -f $FLAG ]; then
    echo 'WordPress already installed'
    return 1
  fi
  
  REPO_NAME=$(basename $GITPOD_REPO_ROOT)
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
  mv ${GITPOD_REPO_ROOT} $HOME/workspace

  # create webserver root and install WordPress there
  mkdir -p ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  cp -R $HOME/wordpress/* ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/

  # put the project files in the correct place
  mkdir $DESTINATION
  mv $HOME/workspace/.[!.]* $DESTINATION
  
  # create a wp-config.php
  cp $HOME/gitpod-wordpress/conf/wp-config.php ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-config.php

  cd $DESTINATION
}

function wp_setup_theme () {
  _wp_setup "themes"
}

function wp_setup_plugin () {
  _wp_setup "plugins"
}

export -f wp_setup_theme
export -f wp_setup_plugin
