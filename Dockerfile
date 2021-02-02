FROM php:7.4-fpm-buster


#################
# Add source list
#################
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list


#################
# Install common libs:
#################
RUN apt-get update -y
RUN apt-get install -y cron apt-utils build-essential net-tools iputils-ping \
	libfreetype6-dev libjpeg62-turbo-dev libpng-dev vim git zip unzip wget 


#################
# Fix GnuTLS error:
#################
RUN apt-get install apt-transport-https ca-certificates
RUN /usr/sbin/update-ca-certificates --fresh
RUN apt-get build-dep wget -y


#################
# Fix mouse error in Vim:
#################
RUN touch ~/.vimrc && echo "set mouse-=a" > ~/.vimrc && . ~/.vimrc


#################
# Install Zsh:
#################
RUN apt-get install zsh -y
RUN sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"


#################
# Install PHP extensions:
#################
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions zip exif tidy pdo_pgsql pdo_mysql bz2 gd \
    mongodb mailparse gmp soap opcache mcrypt xmlrpc bcmath memcached redis pcntl intl



#################
# Initialize php.ini:
#################
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN curl -o /etc/php-cacert.pem https://curl.haxx.se/ca/cacert.pem
RUN sed -i '/;curl.cainfo =/c\curl.cainfo = /etc/php-cacert.pem' $(php -i | grep /.+/php.ini -oE) && \
	sed -i '/;openssl.cafile=/c\openssl.cafile = /etc/php-cacert.pem' $(php -i | grep /.+/php.ini -oE) && \
	sed -i '/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0' $(php -i | grep /.+/php.ini -oE) && \
	sed -i '/expose_php = On/c\expose_php = Off' $(php -i | grep /.+/php.ini -oE) && \
	sed -i '/zlib.output_compression = Off/c\zlib.output_compression = On' $(php -i | grep /.+/php.ini -oE) 



#################
# Install Composer:
#################
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN mkdir -p /var/www/.composer/cache/repo
RUN chown -R www-data:www-data /var/www/.composer
RUN chmod -R 777 /var/www/.composer/cache
