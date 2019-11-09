<?php
/*
Plugin Name: Gitpod Test Plugin
Version: 1.0.0
Description: just another WordPress plugin
Author: Luiz Bills
Author URI: https://luizpb.com
License: GPLv3
License URI: http://www.gnu.org/licenses/gpl-3.0.html
*/

if ( ! defined( 'WPINC' ) ) die();

add_action( 'admin_notices', function () {
  echo "<div class="notice notice-success is-dismissible"><p>Hello World from Gitpod Test Plugin</p></div>"
} );
