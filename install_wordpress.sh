#!/bin/bash

# using a function so that commands will work when executed in sub shell
function install_wordpress() {

yum update -y;
yum install -y httpd wget php-fpm php-mysqli php-json php php-devel unzip;
systemctl enable httpd;
wget https://wordpress.org/latest.tar.gz;
tar -xvf latest.tar.gz;
cp -r wordpress/*  /var/www/html/;
chown -R apache:apache /var/www/;
chmod -Rf 775  /var/www/;
setenforce 0;
systemctl restart httpd;
wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip";
unzip awscli-exe-linux-x86_64.zip;
bash ./aws/install;
export PATH=$PATH:/usr/local/bin;

#Storing variables
password=$(aws secretsmanager get-secret-value --secret-id MysqldbCreds --query 'SecretString' --output json | jq -r | jq .password | tr -d) 
dbname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .DBName | tr -d \")
username=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .MasterUsername | tr -d \")
dbhostname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .Endpoint.Address | tr -d \")

#Passing Values to wordpress config file

cd wordpress-config/;
sed -i "s/dbname/${dbname}/g" wp-config.php;
sed -i "s/username/${username}/g" wp-config.php;
sed -i "s/password/${password}/g" wp-config.php;
sed -i "s/dbhostname/${dbhostname}/g" wp-config.php;

cp wp-config.php /var/www/html;
chown -R apache:apache /var/www/html/wp-config;
chmod 775 /var/www/html/wp-config;


# calling funcrion
install_wordpress
