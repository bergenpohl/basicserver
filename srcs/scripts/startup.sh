#!/bin/bash

## UPDATE FILE PERMISSIONS FOR /root/
sudo chown root:root -R /root/*

## SETUP USERS
sudo adduser --gecos "" admin
sudo adduser --no-create-home --gecos "" ftp_user

## DISABLE ROOT LOGIN
cat /etc/ssh/sshd_config | sed 's/.*PermitRootLogin.*/PermitRootLogin no/g' > /etc/ssh/sshd_config
/etc/init.d/ssh restart

## CONFIGURE FIREWALL
# sudo ufw allow 22/tcp
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp
# sudo ufw status

## SSL
openssl req -newkey rsa:4096 \
              -x509 \
              -sha256 \
              -days 365 \
              -nodes \
              -out /etc/ssl/certs/localhost.crt \
              -keyout /etc/ssl/private/localhost.key

## NGINX
mkdir /var/www/localhost

wget https://wordpress.org/latest.zip
unzip latest.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.2/phpMyAdmin-5.1.2-all-languages.zip
unzip phpMyAdmin-5.1.2-all-languages.zip

mkdir /var/www/localhost/index/
cp -r /root/srcs/index/* /var/www/localhost/index/

mkdir /var/wwwlocalhost/app/
cp -r /root/srcs/index/nodejs/* /var/www/localhost/app/

cp -r /root/srcs/wordpress /var/www/localhost/
mkdir /var/www/localhost/phpmyadmin
cp -r /root/srcs/phpMyAdmin-5.1.2-all-languages/* /var/www/localhost/phpmyadmin

rm -f /etc/nginx/sites-enabled/*
cp /root/srcs/nginx/config/localhost.conf /etc/nginx/sites-enabled/
cp /root/srcs/nginx/htpasswd/.htpasswd	/etc/nginx/

chown www-data:www-data /var/www
chown www-data:www-data -R /var/www/*

find /var/www/* -type d -exec chmod 755 {} \;
find /var/www/* -type f -exec chmod 644 {} \;

/etc/init.d/nginx restart
/etc/init.d/nginx status

## MYSQL (DATABASE)
/etc/init.d/mariadb restart

echo "DELETE FROM mysql.user WHERE User='';" | mysql -u root
echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root

echo "CREATE DATABASE wpdb;" | mysql -u root
echo "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'password';" | mysql -u root
echo "GRANT ALL PRIVILEGES ON wpdb.* TO 'wp_user'@'localhost';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root
	
echo "SOURCE /var/www/localhost/phpmyadmin/sql/create_tables.sql;" | mysql -u root
echo "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'wp_user'@'localhost';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root

## PHP
/etc/init.d/php7.4-fpm start
/etc/init.d/php7.4-fpm status

## VSFTPD (FILE TRANSFER PROTOCALL)
cp /root/srcs/vsftpd/vsftpd.conf /etc/vsftpd.conf
cp /root/srcs/vsftpd/vsftpd.user_list /etc/vsftp.user_list

/etc/init.d/vsftpd start
/etc/init.d/vsftpd status

## SHELL
/bin/bash

## TAIL NGINX ACCESS AND ERROR LOGS
# tail -f /var/log/nginx/access.log /var/log/nginx/error.log
