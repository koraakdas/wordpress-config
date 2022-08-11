#!/bin/bash

# using a function so that commands will work when executed in sub shell
function install_wordpress() {

sudo yum update -y;
sudo yum install -y httpd wget php-fpm php-mysqli php-json php php-devel unzip;
sudo systemctl enable httpd;
sudo wget https://wordpress.org/latest.tar.gz;
sudo tar -xvf latest.tar.gz;
sudo wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip";
sudo unzip awscli-exe-linux-x86_64.zip;
sudo bash ./aws/install;
sudo export PATH=$PATH:/usr/local/bin;

#Storing variables
password=$(aws secretsmanager get-secret-value --secret-id MysqldbCreds --query 'SecretString' --output json | jq -r | jq .password | tr -d) 
dbname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .DBName | tr -d \")
username=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .MasterUsername | tr -d \")
dbhostname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .Endpoint.Address | tr -d \")

#Passing Values to wordpress config file

sudo sed -i "s/dbname/${dbname}/g" wp-config.php;
sudo sed -i "s/username/${username}/g" wp-config.php;
sudo sed -i "s/password/${password}/g" wp-config.php;
sudo sed -i "s/dbhostname/${dbhostname}/g" wp-config.php;

}

# calling function
install_wordpress
