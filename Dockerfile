FROM registry.access.redhat.com/rhscl/php-56-rhel7:latest
# Edit Version - original: TP3_VERS=8.7.1
# To be able to change the Image
USER 0

ENV CONTENT_DIR=/data/typo3-content/ \
    APACHE_APP_ROOT=/opt/app-root/src \
    TP3_VERS=8.7.1 \ 
    TP3_FULL_FILE=typo3_src-\${TP3_VERS} \
    TYPO3_DL=https://get.typo3.org/8.7

# mod_authn_dbd mod_authn_dbm mod_authn_dbd mod_authn_dbm mod_echo mod_lua



WORKDIR /tmp

RUN set -x && \
    rm -fr /var/cache/* && \
    yum -y autoremove rh-php56-php-pgsql rh-php56-php-ldap postgresql postgresql-devel postgresql-libs autoconf automake glibc-devel glibc-headers libcom_err-devel libcurl-devel libstdc++-devel make openssl-devel pcre-devel gcc gcc-c++ gdb gdb-gdbserver git libgcrypt-devel libgpg-error-devel libxml2-devel libxslt-devel openssh openssh-clients sqlite-devel zlib-devel && \
    mkdir -p ${CONTENT_DIR} && \
    wget https://get.typo3.org/${TP3_VERS} && \
    tar -xf ${TP3_VERS} && \
    sed -i 's/LogFormat "%h /LogFormat "%{X-Forwarded-For}i /' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    sed -i 's/;date.timezone.*/date.timezone = Europe\/Vienna/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/; max_input_vars.*/max_input_vars = 1500/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/max_execution_time.*/max_execution_time = 240/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/' /etc/opt/rh/rh-php56/php.ini && \
    echo '<?php phpinfo(); ' > /opt/app-root/src/pinf.php && \
    echo 'xdebug.max_nesting_level=400'>>  /etc/opt/rh/rh-php56/php.d/15-xdebug.ini && \
    chmod 777 ${CONTENT_DIR} ${APACHE_APP_ROOT} && \
    chmod -R 777 ${CONTENT_DIR} /var/opt/rh/rh-php56/lib/php/session && \
    ln -s ${CONTENT_DIR}/$(basename $( echo ${TP3_FULL_FILE}|envsubst ) '') ${APACHE_APP_ROOT}/typo3_src && \
    cd ${APACHE_APP_ROOT} && \
    touch ${APACHE_APP_ROOT}/FIRST_INSTALL && \
    chmod 777 ${APACHE_APP_ROOT}/FIRST_INSTALL && \
    ln -s typo3_src/typo3 typo3 && \
    ln -s typo3_src/index.php index.php 

EXPOSE 8080


COPY containerfiles/ /


RUN chmod +x /docker-entrypoint.sh

#CMD ["/bin/sh","-c","while true; do echo hello world; sleep 60; done"]
ENTRYPOINT ["/docker-entrypoint.sh"]
