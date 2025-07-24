FROM node:20 AS node

# Set working directory
WORKDIR /var/www/html

# Copy only the frontend files
COPY package*.json vite.config.js ./
COPY resources resources

# Install and build Vite assets
RUN npm install && npm run build

# ---------------------------

FROM php:8.2-cli

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    zip \
    sqlite3 \
    libsqlite3-dev \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring zip exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy backend files
COPY . .

# Copy built assets from Node build stage
COPY --from=node /var/www/html/public/build public/build

# Install Laravel dependencies
RUN composer install --optimize-autoloader --no-dev

# Generate empty sqlite file if not exists
RUN mkdir -p database && touch database/database.sqlite

# Set permissions
RUN chmod -R 775 storage bootstrap/cache

# Expose port
EXPOSE 10000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]



