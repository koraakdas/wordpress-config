#!/bin/bash

# using a function so that commands will work when executed in sub shell
function install_wordpress() {

#AWS CLI Environment Variables
export AWS_DEFAULT_REGION=us-east-1;

sudo yum update -y;
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2;
sudo yum install -y httpd jq;
sudo systemctl enable httpd;


#Storing variables
password=$(aws secretsmanager get-secret-value --secret-id MysqldbCreds --query 'SecretString' --output text | jq .password | tr -d \") 
dbname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .DBName | tr -d \")
username=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .MasterUsername | tr -d \")
dbhostname=$(aws rds describe-db-instances --db-instance-identifier rds-mariadb-instance --query DBInstances[0] --output json | jq .Endpoint.Address | tr -d \")

#Passing Values to wordpress config file
cd wordpress-config/;
sudo sed -i "s/db_name/${dbname}/g" wp-config.php;
sudo sed -i "s/db_username/${username}/g" wp-config.php;
sudo sed -i "s/db_password/${password}/g" wp-config.php;
sudo sed -i "s/db_hostname/${dbhostname}/g" wp-config.php;

#Installing Wordpress
sudo wget https://wordpress.org/latest.tar.gz;
sudo tar -xvf latest.tar.gz;
sudp cp readme.html /var/www/html;
sudo cp wp-config.php /var/www/html;
sudo cp -r wordpress/*  /var/www/html/;
sudo chown -R apache:apache /var/www/;
sudo chmod -Rf 775  /var/www/;
sudo setenforce 0;
sudo systemctl restart httpd;

}

# calling function
install_wordpress
