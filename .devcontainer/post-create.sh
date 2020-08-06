sudo cp  .devcontainer/config/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

sudo sed -i "s|/var/www/html|$PWD/silverstripe/public|g" /etc/apache2/sites-available/default-ssl.conf

service apache2 reload