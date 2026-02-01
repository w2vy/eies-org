FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MEDIAWIKI_VERSION=1.45.1

# Install dependencies
RUN apt-get update && apt-get install -y \
    mysql-server \
    nginx \
    apache2 \
    libapache2-mod-php \
    php-mysql \
    php-xml \
    php-mbstring \
    php-intl \
    php-curl \
    php-gd \
    php-apcu \
    imagemagick \
    diffutils \
    supervisor \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and extract MediaWiki
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/1.45/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
    && tar -xzf mediawiki.tar.gz -C /var/www/html --strip-components=1 \
    && rm mediawiki.tar.gz \
    && chown -R www-data:www-data /var/www/html

# Configure Apache to run on port 8080 (wiki)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/:80/:8080/' /etc/apache2/sites-available/000-default.conf \
    && rm -f /var/www/html/index.html /var/www/html/index.nginx-debian.html

# Configure Nginx for landing page on port 80
RUN rm /etc/nginx/sites-enabled/default
COPY nginx-landing.conf /etc/nginx/sites-enabled/landing.conf

# Copy landing pages
COPY eies.org/ /var/www/eies.org/
COPY whitescarver.com/ /var/www/whitescarver.com/

# Copy MediaWiki config (will be modified by entrypoint)
COPY wiki/LocalSettings.php /var/www/html/LocalSettings.php.template

# Copy database init script
COPY db/mwnew.sql /docker-entrypoint-initdb.d/mwnew.sql

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p /var/www/html/images \
    && chown -R www-data:www-data /var/www/html/images \
    && mkdir -p /run/mysqld \
    && chown mysql:mysql /run/mysqld \
    && mkdir -p /var/run/apache2 \
    && mkdir -p /var/log/supervisor

# Expose ports: 80 (landing), 8080 (wiki)
EXPOSE 80 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
