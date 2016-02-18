#!/bin/sh -x

USER=bahmni

rm -rf /var/www/bahmni_config
ln -s /bahmni-code/endtb-config /var/www/bahmni_config
chown -h ${USER}:${USER} /var/www/bahmni_config