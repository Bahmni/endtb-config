#!/bin/sh
set -e -x

mysql -uroot -p openmrs < deidentify_openmrs.sql
