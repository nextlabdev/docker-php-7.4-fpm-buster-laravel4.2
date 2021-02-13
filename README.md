Contains:
- php: 7.4-fpm
- zsh
- supervisor
- Composer



Sample Usage:

```
From nextlabdev/php-7.4-fpm-buster-laravel4.2:latest

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
```