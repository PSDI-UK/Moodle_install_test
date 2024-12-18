# https://docs.moodle.org/405/en/Step-by-step_Installation_Guide_for_Ubuntu


PROTOCOL="http://";
read -p "Enter the web address (without the http:// prefix, eg domain name mymoodle123.com or IP address 192.168.1.1.): " WEBSITE_ADDRESS

 sudo apt-get update && sudo apt upgrade -y 
 sudo apt-get -y install apache2 php libapache2-mod-php php-mysql graphviz aspell git clamav php-pspell php-curl php-gd php-intl ghostscript php-xml php-xmlrpc php-ldap php-zip php-soap php-mbstring unzip mariadb-server mariadb-client certbot python3-certbot-apache ufw nano

cd /var/www/html
sudo git clone https://github.com/moodle/moodle.git 
cd moodle 
sudo git checkout origin/MOODLE_403_STABLE 
sudo git config pull.ff only

sudo mkdir -p /var/www/moodledata
sudo chown -R www-data:www-data /var/www/moodledata
sudo find /var/www/moodledata -type d -exec chmod 700 {} \; 
sudo find /var/www/moodledata -type f -exec chmod 600 {} \;
sudo chmod -R 777 /var/www/html/moodle 
sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini
echo "* * * * * www-data /var/www/moodle/admin/cli/cron.php >/dev/null" | sudo tee -a /etc/crontab

sudo sed -i '/ServerName/c\    ServerName $WEBSITE_ADDRESS' /etc/apache2/sites-available/000-default.conf
sudo sed -i '/ServerAlias/c\    ServerAlias www.$WEBSITE_ADDRESS' /etc/apache2/sites-available/000-default.conf
sudo certbot --apache
sudo systemctl reload apache2
PROTOCOL="https://";


MYSQL_MOODLEUSER_PASSWORD=$(openssl rand -base64 6)
sudo mysql -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY '$MYSQL_MOODLEUSER_PASSWORD';"
sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON moodle.* TO 'moodleuser'@'localhost';"
echo "Your Moodle user password is $MYSQL_MOODLEUSER_PASSWORD. Write this down as you will need it in a web browser install"



MOODLE_ADMIN_PASSWORD=$(openssl rand -base64 6)
sudo -u www-data /usr/bin/php /var/www/html/moodle/admin/cli/install.php --non-interactive --lang=en --wwwroot="$PROTOCOL$WEBSITE_ADDRESS/moodle" --dataroot=/var/www/moodledata --dbtype=mariadb --dbhost=localhost --dbname=moodle --dbuser=moodleuser --dbpass="$MYSQL_MOODLEUSER_PASSWORD" --fullname="Moodle Docs Step by Step Guide" --shortname="SG" --adminuser=admin --summary="" --adminpass="$MOODLE_ADMIN_PASSWORD" --adminemail=joe@123.com --agree-license
echo "Moodle installation completed successfully. You can now log on to your new Moodle at $PROTOCOL$WEBSITE_ADDRESS/moodle as admin with $MOODLE_ADMIN_PASSWORD and complete your site registration"

