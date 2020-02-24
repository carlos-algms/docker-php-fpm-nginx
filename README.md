# docker-php-fpm-nginx 

A docker image running Nginx and PHP-fpm

To be as close as possible to the Production environment.

PS: It was not meant to be a production Image, it includes XDebug.

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

## How to se
Nginx will serve everything under `/var/www/html`  
Just mound a volume under that folder  
and, remap the PORTS as you wish:

```shell
docker run --rm -it -p 8080:80 --volume ./local/path:/var/www/http carlosalgms/docker-php-fpm-nginx:7-fpm
```
