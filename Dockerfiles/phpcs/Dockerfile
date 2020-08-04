FROM php:7.3-apache

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends apt-utils dialog 2>&1 && \
    #
    # Install git, procps, lsb-release (useful for CLI installs)
    # Install ssl-cert to get the "snakeoil" certs
    apt-get -y install git procps iproute2 lsb-release vim.tiny \
            wget curl gzip g++ openssh-client libmagickwand-dev \
            libcurl4-openssl-dev libgd-dev libjpeg-dev libpng-dev libldap2-dev libtidy-dev libxslt-dev zlib1g-dev libzip-dev libicu-dev \
            mariadb-client ssl-cert && \
    curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin && \
    curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    pecl install imagick-3.4.3 && \
    #
    # Install xdebug
    yes | pecl install xdebug && \
    echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    groupadd --gid $USER_GID $USERNAME && \
    useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    # [Optional] Add sudo support for non-root user
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    #
    # Install PHP Extensions
    docker-php-ext-configure intl && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr  && \
    docker-php-ext-enable xdebug && \
    docker-php-ext-enable imagick && \
    docker-php-ext-install -j$(nproc) intl gd ldap mysqli pdo pdo_mysql soap tidy xsl zip sockets && \
    #
    # Fix ServerName warning & execute apache on ports 8080 & 8443
    chmod -R 775 /etc/ssl/private && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's/443/8443/g' /etc/apache2/ports.conf && \
    sed -i 's/_default_:443/*:8443/g' /etc/apache2/sites-available/default-ssl.conf && \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini && \
    echo "date.timezone = Pacific/Auckland" >> /usr/local/etc/php/php.ini && \
    #
    # Clean up
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Adminer
RUN mkdir /usr/share/adminer && \
    wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php && \
    ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php && \
    echo "Alias /adminer.php /usr/share/adminer/adminer.php" | tee /etc/apache2/conf-available/adminer.conf && \
    a2enconf adminer.conf

# SilverStripe Apache Configuration
RUN a2enmod rewrite && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    service apache2 restart

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=