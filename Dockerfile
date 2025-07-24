# Stage 1: Build frontend assets with Node.js
FROM node:18 AS node-builder
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
COPY yarn.lock* ./

# Install dependencies
RUN npm ci --only=production

# Copy all source files needed for build
COPY . .

# Build frontend assets (this should compile Tailwind)
RUN npm run build

# Stage 2: PHP Laravel backend
FROM php:8.2-fpm
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip curl git libxml2-dev libzip-dev libpng-dev libjpeg-dev libonig-dev \
    sqlite3 libsqlite3-dev nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY --chown=www-data:www-data . /var/www

# Copy built frontend assets from node-builder stage
COPY --from=node-builder --chown=www-data:www-data /app/public /var/www/public

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Setup environment
COPY .env.example .env
RUN php artisan key:generate

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]