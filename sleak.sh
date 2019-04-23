#!/bin/bash
#Script by FordSenpai

if [ $USER != 'root' ]; then
	echo "You must run this as root"
	exit
fi

# Inizialize Var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "You are not running this script on Debian OS"
	exit
fi

# go to root
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);

#Purge PHP7.0
#apt-get remove -y --purge php7.0*

#Start Database Question

clear
echo "=======Debian9 OCS Panel Script by FordSenpai========"
echo ""
echo "I need to ask some questions before starting setup"
echo "You can leave the default option and just hit enter if you agree with the option"
echo ""
echo "First I need to know the new password of MySQL root user:"
read -p "Password: " -e -i fordsenpai DatabasePass
echo ""
echo "Finally, name the Database Name for OCS Panels"
echo " Please, use one word only, no special characters other than Underscore (_)"
read -p " Database Name: " -e -i OCS_PANEL DatabaseName
echo ""
echo "Okay, that's all I need. We are ready to setup your OCS Panels now"
read -n1 -r -p "Press any key to continue..."

#Setting UP MariaDB mysql
apt-get update -y
apt-get install build-essential expect -y
apt-get install -y mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/


#Setting UP Nginx and PHP
apt-get -y install nginx php-fpm php-cli php-mysql php-mcrypt
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup 
mv /etc/nginx/conf.d/vps.conf /etc/nginx/conf.d/vps.conf.backup 
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/johndesu090/AutoScriptDebianStretch/master/Files/Panel/nginx.conf" 
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/johndesu090/AutoScriptDebianStretch/master/Files/Panel/vps.conf" 
echo "cgi.fix_pathinfo=0" >> /etc/php/7.0/fpm/php.ini 
sed -i 's/listen = \/run\/php\/php7.0-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/7.0/fpm/pool.d/www.conf

useradd -m vps
mkdir -p /home/vps/public_html
rm /home/vps/public_html/index.html
cat > /home/vps/public_html/info.php <<-END
<?php
phpinfo();
?>
END
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html
service php7.0-fpm restart
service nginx restart

apt-get -y install zip unzip
cd /home/vps/public_html
wget https://github.com/johndesu090/AutoScriptDebianStretch/raw/master/Files/Panel/Panel.zip
unzip Panel.zip
rm -f Panel.zip
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

chmod 777 /home/vps/public_html/config
chmod 777 /home/vps/public_html/config/inc.php
chmod 777 /home/vps/public_html/config/route.php

apt-get -y --force-yes -f install libxml-parser-perl

clear
echo "Open Browser, access http://$MYIP/ and complete the data as below!"
echo "Database:"
echo "- Database Host: localhost"
echo "- Database Name: $DatabaseName"
echo "- Database User: root"
echo "- Database Pass: $DatabasePass"
echo ""
echo "Admin Login:"
echo "- Username: anything you want"
echo "- Password Baru: anything you want"
echo "- Re-enter New Password: as desired"
echo ""
echo "Click Install and wait for the process to finish, go back to terminal and then press [ENTER key]!"

sleep 3
echo ""
read -p "If the above step has been done, please Press [Enter] key to continue...."
echo ""
read -p "If you really believe the above step has been done, please Press [Enter] key to continue..."
echo ""
cd /root
#wget http://www.webmin.com/jcameron-key.asc
#apt-key add jcameron-key.asc
#sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
#service webmin restart

#rm -f /root/jcameron-key.asc

#rm -R /home/vps/public_html/installation

cd
rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

chmod 755 /home/vps/public_html/config
chmod 644 /home/vps/public_html/config/inc.php
chmod 644 /home/vps/public_html/config/route.php

# info
clear
echo "=======================================================" | tee -a log-install.txt
echo "Please login Reseller Panel at http://$MYIP" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "        Auto Script Installer OCS Panel"  | tee -a log-install.txt
echo "(https://johnfordtv.me - fb.com/johndesu090)"  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks " | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Installation Log --> /root/log-install.txt" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/

#rm -f /root/ocspanel.sh
