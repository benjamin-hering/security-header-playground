#!/bin/bash
# Seperate script for the setup of the Apache websites

# Making sure this is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Installing PHP
apt-get install php libapache2-mod-php -y

# enabling needed modules
a2enmod headers

# Copying over site files
rysnc -av site-files/ /var/www/html/

# Copying over config files
rsync -av conf-files/ /etc/apache2/sites-available/

# Enabling sites
a2ensite www.evil.com.conf
a2ensite www.secure-headers.com.conf
a2ensite www.no-secure-headers.com.conf
systemctl restart apache2
