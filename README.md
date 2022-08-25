# docker-php-fpm-nginx 

A docker image running Nginx and PHP-fpm

#### What is Included? 
* Nginx
* PHP 8 and PHP 7.1
* XDebug v3.x ✨ or v2.5 for PHP 7.1

## How to use
Nginx will serve everything under `/app/public`

Just mount a volume under that folder and, remap the PORTS as you wish:

#### docker-compose

```yaml
version: '3.8'

services:
  site:
    container_name: site
    image: carlosalgms/docker-php-fpm-nginx:8-alpine
    ports:
      - 8080:8080
    volumes:
      - ./build/public:/app/public
      - ./config:/config
    environment:
      environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
```

## Environment Variables

- `PUID` and `PGID` will be used to control the user `www-data`, Nginx and PHP will run under this user.
- `TZ` controls the timezone, defaults to `Europe/Berlin` 


## Customize

If you mount the `/config` folder, you will have access to: 

- Nginx `default.conf`
- PHP-fpm `www.conf`
- Log files: error.log and access.log for PHP and Nginx

The folders and files under `/config` will be created on the first run, in case they aren't already there.

#### PHP modules enabled:
```
$ php-fpm -m 

[PHP Modules]
bcmath
cgi-fcgi
Core
date
dom
exif
fileinfo
filter
gd
hash
json
libxml
mbstring
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
pspell
readline
Reflection
session
SimpleXML
SPL
sqlite3
standard
xdebug
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache
```
