function _setup_wp () {
  target_dir=$1
  
  cd ${GITPOD_REPO_ROOT}
  
  if [ -f composer.json ]; then
    composer install
  fi
  
  if [ -f package.json ]; then
    npm install
  fi
  
  mv ${GITPOD_REPO_ROOT} /workspace/${APACHE_APACHE_DOCROOT}/wp-content/${target_dir}/
}

function setup_wp_theme () {
  _setup_wp themes
}

function setup_wp_plugin () {
  _setup_wp plugins
}
