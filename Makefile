# Default variables
PHP_VERSION ?= 8.3
IMAGE_NAME ?= php-local

.PHONY: help build install switch

build:
	docker build -t $(IMAGE_NAME):$(PHP_VERSION) . --build-arg PHP_VERSION=$(PHP_VERSION)

# Installs the PHP and Composer binaries in the system
install:
	@if [ "$$EUID" -ne 0 ]; then \
		echo "Please run this command as root or using sudo."; \
		exit 1; \
	fi

	# Create binary for the specified PHP version
	@echo '#!/bin/sh' > /usr/local/bin/php$(PHP_VERSION)
	@echo 'if [ "$$#" -eq 0 ]; then' >> /usr/local/bin/php$(PHP_VERSION)
	@echo '    docker run --rm --interactive --tty $(IMAGE_NAME):$(PHP_VERSION) php -v;' >> /usr/local/bin/php$(PHP_VERSION)
	@echo 'else' >> /usr/local/bin/php$(PHP_VERSION)
	@echo '    docker run --rm --interactive --tty --volume "$$PWD:/app" $(IMAGE_NAME):$(PHP_VERSION) php "$$@";' >> /usr/local/bin/php$(PHP_VERSION)
	@echo 'fi' >> /usr/local/bin/php$(PHP_VERSION)
	@chmod +x /usr/local/bin/php$(PHP_VERSION)

	# creates the php binary using the create-binary target
	@make switch PHP_VERSION=$(PHP_VERSION)

	# installs Composer
	@make install-composer

	@echo "Binaries created! You can now use 'php' in the terminal."

install-composer:
	@if [ "$$EUID" -ne 0 ]; then \
		echo "Please run this command as root or using sudo."; \
		exit 1; \
	fi

	# Create binary for the specified PHP version
	@echo '#!/bin/sh' > /usr/local/bin/composer
	@echo 'docker run --rm --interactive --tty --volume "$$PWD:/app" $(IMAGE_NAME):$(PHP_VERSION) composer "$$@";' >> /usr/local/bin/composer
	@chmod +x /usr/local/bin/composer

	@echo "Composer binary created! You can now use 'composer' in the terminal."

# switches the PHP version to the specified version
switch:
	@if [ "$$EUID" -ne 0 ]; then \
		echo "Please run this command as root or using sudo."; \
		exit 1; \
	fi

	# Switch the PHP version to the specified version
	@ln -sf /usr/local/bin/php$(PHP_VERSION) /usr/local/bin/php

	@echo "PHP version switched to $(PHP_VERSION)."

help:
	@echo "Makefile Commands:"
	@echo ""
	@echo "  make build              - Build Docker images for specified PHP versions in parallel."
	@echo "                            Available argument: PHP_VERSIONS (space-separated list)"
	@echo "Example usage:"
	@echo "  make build PHP_VERSION=8.2"
	@echo ""
	@echo "  make install            - Install PHP and Composer binaries in the system."
	@echo "                            Available argument: PHP_VERSION"
	@echo "Example usage:"
	@echo "  make install PHP_VERSION=8.2"
	@echo ""
	@echo "  make switch             - Switch the PHP version to the specified version."
	@echo "                            Available argument: PHP_VERSION"
	@echo ""
	@echo "Example usage:"
	@echo "  make switch PHP_VERSION=8.2"
	@echo ""
	@echo "  make help               - Display this help message."
	@echo ""


