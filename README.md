# Gitpod for WordPress

[Gitpod](https://www.gitpod.io) is a ready-to-code dev environment with a single click. It will allows you to develop your plugin or theme directly from your browser.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/luizbills/gitpod-wordpress)

## Features

- LAMP (Apache, MySQL, PHP)
- [Composer](https://getcomposer.org/)
- [Adminer](https://www.adminer.org/)
- [NVM](https://github.com/nvm-sh/nvm)
- [Node.js](https://nodejs.org/) (LTS)
- [Xdebug](https://xdebug.org)
- [WP-CLI](https://wp-cli.org/)
- Git
- SVN

## Install

Just copy the [`.gitpod.yml`](/.gitpod.yml) and [`.gitpod.dockerfile`](/.gitpod.dockerfile) to your project root directory and push to your remote repository.

- If your project is a theme, change the `wp-setup-plugin` to `wp-setup-theme` in your `.gitpod.yml`.
- By default, the webserver will use PHP `v7.3`. If you need a different version, change it on `ENV PHP_VERSION` in your `.gitpod.dockerfile` (line 4).

Also, the `wp-setup-plugin` (or `wp-setup-theme`) will search for a `.init.sh` file in your project root directory and execute it (if exists). Then, you can use the `wp-cli` to install plugins, install themes, and [more](https://developer.wordpress.org/cli/commands/). Or create your own tasks. 

```sh
# file: init.sh
wp plugin install woocommerce --activate # install WooCommerce
wp plugin activate ${REPO_NAME} # activate your plugin
```

Project dependencies (in `composer.json` or `package.json`) are automatically installed.

## Usage

Now you access `https://gitpod.io/#<url-of-your-github-project>`.

> Example: [https://gitpod.io/#https://github.com/luizbills/wp-tweaks/](https://gitpod.io/#https://github.com/luizbills/wp-tweaks/)

Your admin credentials:

```
username: admin
password: password
```

### Utilities

- You can use the following commands in terminal:
  - `browse-url <endpoint>`: open an endpoint of your WordPress installation.
  - `browse-home`: alias for `browse-url /` (your Homepage)
  - `browse-wpadmin`: alias for `browse-url /wp-admin` (WordPress Admin Painel)
  - `browse-dbadmin`: alias for `browse-url /database` (to manage your database with Adminer)
  - `browse-phpinfo`: alias for `browse-url /phpinfo` (a page with `<?php phpinfo(); ?>`)
  
- You can setup your PHP on `.htaccess` file (eg: `php_value max_execution_time 600`)

## Contributing

To contribute, follow these steps:

1. Fork this repository.
1. Create a branch: git checkout -b <branch_name>.
1. Make your changes and commit them: git commit -m '<commit_message>'
1. Push to the original branch: git push origin <project_name>/<location>
1. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

Just found a bug? Report it on GitHub [Issues](https://github.com/luizbills/gitpod-wordpress/issues).

## LICENSE

MIT &copy; 2019 Luiz Paulo "Bills"

---

Made with ❤ in Brazil
