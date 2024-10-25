# Default variables
PHP_VERSION ?= 8.3
IMAGE_NAME ?= php-local

.PHONY: help build install switch check

build:
	@echo "🔨 Building PHP $(PHP_VERSION) Docker image..."
	@docker build --quiet -t $(IMAGE_NAME):$(PHP_VERSION) . --build-arg PHP_VERSION=$(PHP_VERSION) > /dev/null || \
		(echo "❌ Build failed!"; exit 1)
	@echo "✅ Docker image $(IMAGE_NAME):$(PHP_VERSION) built successfully!"

# Installs the PHP and Composer binaries in the system
install:
	@echo "🚀 Starting PHP $(PHP_VERSION) installation..."

	@if [ "$$EUID" -ne 0 ]; then \
		echo "❌ Error: Please run this command as root or using sudo."; \
		exit 1; \
	fi

	@echo "📦 Creating PHP $(PHP_VERSION) binary..."
	@echo '#!/bin/sh' > /usr/local/bin/php$(PHP_VERSION)
	@echo 'if [ "$$#" -eq 0 ]; then' >> /usr/local/bin/php$(PHP_VERSION)
	@echo '    docker run --rm --interactive --tty $(IMAGE_NAME):$(PHP_VERSION) php -v;' >> /usr/local/bin/php$(PHP_VERSION)
	@echo 'else' >> /usr/local/bin/php$(PHP_VERSION)
	@echo '    docker run --rm --interactive --tty --volume "$$PWD:/app" $(IMAGE_NAME):$(PHP_VERSION) php "$$@";' >> /usr/local/bin/php$(PHP_VERSION)
	@echo 'fi' >> /usr/local/bin/php$(PHP_VERSION)
	@chmod +x /usr/local/bin/php$(PHP_VERSION)
	@echo "✅ PHP $(PHP_VERSION) binary created successfully!"

	@echo "\n🔄 Setting up default PHP version..."
	@make --no-print-directory switch PHP_VERSION=$(PHP_VERSION)

	@echo "\n🎼 Installing Composer..."
	@make --no-print-directory install-composer

	@echo "\n✨ Installation complete! You can now use 'php' and 'composer' in your terminal."
	@echo "📝 Run 'php -v' to verify the installation."

install-composer:
	@if [ "$$EUID" -ne 0 ]; then \
		echo "❌ Error: Please run this command as root or using sudo."; \
		exit 1; \
	fi

	@echo "📦 Creating Composer binary..."
	@echo '#!/bin/sh' > /usr/local/bin/composer
	@echo 'docker run --rm --interactive --tty --volume "$$PWD:/app" $(IMAGE_NAME):$(PHP_VERSION) composer "$$@";' >> /usr/local/bin/composer
	@chmod +x /usr/local/bin/composer
	@echo "✅ Composer binary created successfully!"

# switches the PHP version to the specified version
switch:
	@if [ "$$EUID" -ne 0 ]; then \
		echo "❌ Error: Please run this command as root or using sudo."; \
		exit 1; \
	fi

	# Check if the specified version binary exists
	@if [ ! -f "/usr/local/bin/php$(PHP_VERSION)" ]; then \
		echo "❌ Error: PHP $(PHP_VERSION) is not installed. Run 'sudo make install PHP_VERSION=$(PHP_VERSION)' first."; \
		exit 1; \
	fi

	@echo "🔄 Switching to PHP $(PHP_VERSION)..."
	@ln -sf /usr/local/bin/php$(PHP_VERSION) /usr/local/bin/php
	@echo "✅ PHP version switched to $(PHP_VERSION)"
	@php -v | head -n 1

check:
	@echo "🔍 Checking system prerequisites and installation..."

	# Check if Docker is installed and running
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker is not installed"; \
		exit 1; \
	else \
		echo "✅ Docker is installed"; \
	fi

	# Check if Docker daemon is running
	@if ! docker info >/dev/null 2>&1; then \
		echo "❌ Docker daemon is not running"; \
		exit 1; \
	else \
		echo "✅ Docker daemon is running"; \
	fi

	# Check if the Docker image exists
	@if ! docker image inspect $(IMAGE_NAME):$(PHP_VERSION) >/dev/null 2>&1; then \
		echo "❌ Docker image $(IMAGE_NAME):$(PHP_VERSION) not found. Run 'make build' first"; \
		exit 1; \
	else \
		echo "✅ Docker image $(IMAGE_NAME):$(PHP_VERSION) exists"; \
	fi

	# Check if PHP binary exists and is executable
	@if [ ! -x "/usr/local/bin/php" ]; then \
		echo "❌ PHP binary not found or not executable. Run 'sudo make install' first"; \
		exit 1; \
	else \
		echo "✅ PHP binary exists and is executable"; \
	fi

	# Check if Composer binary exists and is executable
	@if [ ! -x "/usr/local/bin/composer" ]; then \
		echo "❌ Composer binary not found or not executable"; \
		exit 1; \
	else \
		echo "✅ Composer binary exists and is executable"; \
	fi

	# Try to run PHP version check
	@echo "\n📋 Testing PHP installation..."
	@if ! php -v >/dev/null 2>&1; then \
		echo "❌ PHP installation test failed"; \
		exit 1; \
	else \
		echo "✅ PHP is working correctly ($(shell php -r 'echo PHP_VERSION;'))"; \
	fi

	# Try to run Composer version check
	@echo "\n📋 Testing Composer installation..."
	@if ! composer -V >/dev/null 2>&1; then \
		echo "❌ Composer installation test failed"; \
		exit 1; \
	else \
		echo "✅ Composer is working correctly ($(shell composer -V | cut -d' ' -f3))"; \
	fi

	@echo "\n🎉 All checks passed successfully!"

help:
	@echo "🛠️  Available Commands:"
	@echo ""
	@echo "  🔨 make build              - Build Docker image for PHP"
	@echo "                              Available argument: PHP_VERSION (default: $(PHP_VERSION))"
	@echo ""
	@echo "  📦 make install            - Install PHP and Composer binaries"
	@echo "                              Available argument: PHP_VERSION (default: $(PHP_VERSION))"
	@echo ""
	@echo "  🔄 make switch             - Switch PHP version"
	@echo "                              Available argument: PHP_VERSION (default: $(PHP_VERSION))"
	@echo ""
	@echo "  🔍 make check              - Verify system prerequisites and installation"
	@echo ""
	@echo "📋 Examples:"
	@echo "  make build PHP_VERSION=8.2"
	@echo "  sudo make install PHP_VERSION=8.2"
	@echo "  sudo make switch PHP_VERSION=8.2"
	@echo ""
	@echo "💡 Note: Commands that modify system binaries require sudo privileges"
	@echo ""