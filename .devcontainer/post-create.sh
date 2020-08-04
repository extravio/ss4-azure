sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/ss4.conf

sudo sed -i "s|/var/www/html|$PWD/silverstripe/public|g" /etc/apache2/sites-available/ss4.conf

sudo a2ensite ss4

service apache2 reload