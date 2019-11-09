# WordPress Setup Script
function _wp_setup () {
  TARGET=$1
  
  cd $HOME
  
  # move the workspace temporarily
  mkdir $HOME/workspace
  mv ${GITPOD_REPO_ROOT}/.[!.]* $HOME/workspace
  
  # create webserver root and install WordPress there
  mkdir ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  mv $HOME/wordpress/.[!.]* ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  
  if [ -f composer.json ]; then
    # composer install
  fi
  
  if [ -f package.json ]; then
    # npm install
  fi
  
  mv $HOME/workspace/.[!.]* ${GITPOD_REPO_ROOT}/${APACHE_APACHE_DOCROOT}/wp-content/${TARGET}
  mv $HOME/gitpod-wordpress/conf/wp-config.php ${GITPOD_REPO_ROOT}/${APACHE_APACHE_DOCROOT}/wp-config.php
  
  cd /workspace/${APACHE_APACHE_DOCROOT}
  
  apacheclt start
}

function wp_setup_theme () {
  _wp_setup "themes"
}

function wp_setup_plugin () {
  _wp_setup "plugins"
}

export -f wp_setup_theme
export -f wp_setup_plugin
