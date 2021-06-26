#!/bin/sh
composer dump-autoload
php artisan optimize
crond -f -l 8 -L /dev/stdout
