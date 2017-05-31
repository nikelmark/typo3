#!/bin/sh

set -x

MY_SRV=$(echo $OPENSHIFT_BUILD_NAME|awk -F'-' '{print $1"-"$2}')

TP3_SITEURL=https://${MY_SRV}-${OPENSHIFT_BUILD_NAMESPACE}.${ENV_SUB_DOMAIN}

export MY_SRV

if [ ! -f  ${CONTENT_DIR}/$(basename $( echo ${TP3_FULL_FILE}|envsubst ) '.tar.gz')/index.php ]; then
  tar xfz $( echo ${TP3_FULL_FILE} | envsubst) -C ${CONTENT_DIR}
fi

exec /opt/rh/httpd24/root/sbin/httpd-scl-wrapper -D FOREGROUND
