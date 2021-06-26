#!/bin/sh
composer dump-autoload
php artisan optimize
php-fpm
