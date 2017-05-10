FROM registry.access.redhat.com/rhscl/php-56-rhel7:latest

# Updated Version to 8.7.1
# To be able to change the Image
USER 0

#TYPO3_DL_ROOT=https://downloads.sourceforge.net/project/typo3/TYPO3%20Source%20and%20Dummy/TYPO3%208.7.1/typo3_src-8.7.1.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ftypo3%2Ffiles%2FTYPO3%2520Source%2520and%2520Dummy%2F&ts=1493118623&use_mirror=kent

#https://downloads.sourceforge.net/project/typo3/TYPO3%20Source%20and%20Dummy/TYPO3%208.7.1/typo3_src-8.7.1.tar.gz?r=&ts=1493118623&use_mirror=kent
# mysql.${PROJECT}.svc.cluster.local

ENV TZ=Europe/Vienna \
    TYPO3_VERSION=8.7.1 \

# only using for local docker test
#ENV PROJECT=hasimausi \
#    MYSQL_DATABASE=tp303 \
#    MYSQL_PASSWORD=MyPASSWORD \
#    MYSQL_USER=My_USER \
#    INST_TOOL_PW=asdf1234

# mod_authn_dbd mod_authn_dbm mod_authn_dbd mod_authn_dbm mod_echo mod_lua

RUN set -x && \
    yum -y autoremove rh-php56-php-pgsql rh-php56-php-ldap postgresql postgresql-devel postgresql-libs autoconf automake glibc-devel glibc-headers libcom_err-devel libcurl-devel libstdc++-devel make openssl-devel pcre-devel gcc gcc-c++ gdb gdb-gdbserver git libgcrypt-devel libgpg-error-devel libxml2-devel libxslt-devel openssh openssh-clients sqlite-devel zlib-devel  && \
    rpm -qa|sort && \
    cd /tmp/ && \
    id && \
    env && \
    wget -O - https://get.typo3.org/8.7.1 | tar xvfz - -C /tmp/ && \
    cd /opt/app-root/src && \
    ln -s /data/typo3_src-${TYPO3_VERSION} typo3_src && \
    ln -s typo3_src/index.php && \
    ln -s typo3_src/typo3 && \
    ln -s  /data/typo3/typo3conf typo3conf && \
    ln -s  /data/typo3/uploads uploads && \
    ln -s  /data/typo3/fileadmin fileadmin && \
    touch .htaccess && \
    chmod 666 .htaccess && \
    sed -i 's/LogFormat "%h /LogFormat "%{X-Forwarded-For}i /' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    sed -i 's/;date.timezone.*/date.timezone = Europe\/Vienna/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/^;always_populate_raw_post_data.*/always_populate_raw_post_data = -1/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/^max_execution_tim.*/max_execution_time=240/' /etc/opt/rh/rh-php56/php.ini && \
    sed -i 's/^; max_input_var.*/max_input_vars=1500/' /etc/opt/rh/rh-php56/php.ini && \
    echo 'xdebug.max_nesting_level=400' >> /etc/opt/rh/rh-php56/php.d/15-xdebug.ini && \
    echo '<?php phpinfo(); ' > /opt/app-root/src/pinf.php && \
    touch /opt/app-root/src/FIRST_INSTALL  && \
    chmod 666 /opt/app-root/src/FIRST_INSTALL && \
    chown -R 1001:0 /opt/app-root/src

# own volumes
# fileadmin
# typo3temp
# uploads

EXPOSE 8080

#USER 1001

ADD containerfiles/ /

RUN set -x && \
    touch /opt/app-root/src/typo3conf/LocalConfiguration.php && \
    chmod 666 /opt/app-root/src/typo3conf/LocalConfiguration.php && \
    ln -s /data/typo3/typo3conf/ext /opt/app-root/src/typo3conf/ext && \
    chmod -R 777 /var/opt/rh/rh-php56/lib/php/session /tmp/typo3_src-8.7.1 /opt/app-root/src /opt/app-root/src/typo3conf

RUN yum install -y yum-utils gettext hostname && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    INSTALL_PKGS="gettext rh-mysql56" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

#CMD ["/bin/sh","-c","while true; do echo hello world; sleep 60; done"]
CMD ["/docker-entrypoint.sh"]
