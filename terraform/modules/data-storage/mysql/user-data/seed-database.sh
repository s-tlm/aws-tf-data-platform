#!/bin/bash

echo "Updating packages..."
yum update -y
echo "Installing packages..."
yum install -y httpd wget php-fpm php-mysqli php-json php php-devel
yum install -y mariadb105-server
echo "Downloading sample data..."
curl https://downloads.mysql.com/docs/sakila-db.zip -o sakila.zip
unzip sakila.zip
cd sakila-db || exit
echo "Pushing data to database..."
mysql --host="${host}" --user="${username}" --password="${password}" -f < sakila-schema.sql
mysql --host="${host}" --user="${username}" --password="${password}" -f < sakila-data.sql
