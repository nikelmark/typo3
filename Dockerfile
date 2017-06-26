FROM php:7.1-apache
MAINTAINER Nikel Mark

# Add the user UID:1000, GID:1000, home at /app
RUN groupadd -r docker && \
    useradd -u 1000 -r -g user
    usermod -aG docker user


# Specify the user to execute all commands below
USER user

# Install TYPO3
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
# Configure PHP
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev \
# Install required 3rd party tools
        graphicsmagick && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) mysqli soap gd zip opcache && \
    echo 'always_populate_raw_post_data = -1\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 32M\npost_max_size = 32M' > /usr/local/etc/php/conf.d/typo3.ini && \
    

# Configure Apache as needed
    a2enmod rewrite && \
    apt-get clean && \
    apt-get -y purge \
        libxml2-dev libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* /usr/src/*
    
# Configure Apache priviledges

RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
EXPOSE 8080
RUN chmod g+w /var/log/apache2 && \
    chmod g+w /var/lock/apache2 && \
    chmod g+w /var/run/apache2 


RUN cd /var/www/html && \
    wget -O - https://netcologne.dl.sourceforge.net/project/typo3/TYPO3%20Source%20and%20Dummy/TYPO3%208.7.1/typo3_src-8.7.1.tar.gz | tar -xzf - && \
    ln -s typo3_src-* typo3_src && \
    ln -s typo3_src/index.php && \
    ln -s typo3_src/typo3 && \
    ln -s typo3_src/_.htaccess .htaccess && \
    mkdir typo3temp && \
    mkdir typo3conf && \
    mkdir fileadmin && \
    mkdir uploads && \
    touch FIRST_INSTALL && \
    chown -Rvf www-data. .
    


# Configure volumes
VOLUME /var/www/html/fileadmin
VOLUME /var/www/html/typo3conf
VOLUME /var/www/html/typo3temp
VOLUME /var/www/html/uploads
