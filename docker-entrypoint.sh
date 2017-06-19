#!/bin/sh

set -x

MY_TP3_ROOT=/opt/app-root/src
TP3_CONTENT_ROOT=/data/typo3
MY_SRV=$(echo $OPENSHIFT_BUILD_NAME|awk -F'-' '{print $1"-"$2}')

WP_SITEURL=https://${MY_SRV}-${OPENSHIFT_BUILD_NAMESPACE}.${ENV_SUB_DOMAIN}

echo "INST_TOOL_PW ${INST_TOOL_PW}"

# ENV_SUB_DOMAIN must be set in the template depend on playground or provided

INST_TOOL_PW_HASH=$(curl -sS 'https://tools.bartlweb.net/typo3saltedpassword/' -H Origin: 'https://tools.bartlweb.net' -H Upgrade-Insecure-Requests: 1 -H Referer: 'https://tools.bartlweb.net/typo3saltedpassword/'  --data "string=${INST_TOOL_PW}&password=" --compressed| awk -F'<' '/>\$P/ {print $3}'|awk -F'>' '{print $2}')

export MY_TP3_ROOT WP_CONTENT_ROOT MY_SRV INST_TOOL_PW_HASH

if [ ! -d /data/typo3 ]; then
  mkdir -p /data/typo3/{typo3conf,uploads,fileadmin}
  mkdir -p /data/typo3/typo3conf/ext
  chmod -R 777 /data/typo3
fi
if [ -e /opt/app-root/src/FIRST_INSTALL ]; then
  touch /opt/app-root/src/typo3conf/{LocalConfiguration.php,ENABLE_INSTALL_TOOL}
  chmod 666 /opt/app-root/src/typo3conf/{LocalConfiguration.php,ENABLE_INSTALL_TOOL}
fi

if [ ! -s ${MY_TP3_ROOT}/typo3conf/LocalConfiguration.php ];
then
  envsubst < ${MY_TP3_ROOT}/typo3conf/LocalConfiguration.php.template | sed -e 's/\$ /\$/g' > ${MY_TP3_ROOT}/typo3conf/LocalConfiguration.php
fi

if [ ! -d /data/typo3_src-8.7.1 ]; then
  cp -avx /tmp/typo3_src-8.7.1 /data/
fi

cat /data/typo3_src-8.7.1/_.htaccess > ${MY_TP3_ROOT}/.htaccess

mkdir -p /var/www/html/
cp /data/* /var/www/html/

env

# cleanup some sensitiv data
unset INST_TOOL_PW INST_TOOL_PW_HASH MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE

exec /opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper -D FOREGROUND
