# docker-php-fpm-nginx 

A docker image running Nginx and PHP-fpm

To be as close as possible to the Production environment.

PS: It was not meant to be a production Image, it includes XDebug.

## How to use
Nginx will serve everything under `/var/www/html`  
Just mount a volume under that folder  
and, remap the PORTS as you wish:

```shell
docker run --rm -it -p 8080:80 --volume ./local/path:/var/www/http carlosalgms/docker-php-fpm-nginx:7-fpm
```

## Change the root path

Frameworks like `Laravel` use a different public path for security reasons.

Set the `ROOT_PATH` environment variable to set Nginx `root` direct. 

```shell
docker run --rm -it -p 8080:80 -e ROOT_PATH=/var/www/public --volume ./local/laravel-project:/var/www/http carlosalgms/docker-php-fpm-nginx:7-fpm
```

## What is Included? 

* PHP 7 or 5.6
* Nginx
* PHP - Plugins
  * xdebug ✨
  * mcrypt
  * gd
  * mysql (only for php5.6)
  * mysqli
  * pdo_mysql
  * opcache
  * pspell
  * xml
  * All others pre-included by default
