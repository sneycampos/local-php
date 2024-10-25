# Local PHP Environment

This repository provides a Docker-based solution for running PHP and Composer locally without installing them directly on your system. It creates system-wide binaries that seamlessly integrate with your terminal, making it feel like PHP and Composer are installed natively.

## Features

- Run PHP commands without installing PHP locally
- Use Composer without installation
- Easy switching between PHP versions
- Based on FrankenPHP for better performance
- Includes common PHP extensions pre-installed
- Minimal setup required

## Prerequisites

- Docker
- Make
- Root/sudo access (for binary installation)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/sneycampos/local-php.git
cd local-php
```

2. Build the Docker image (default PHP version is 8.3):
```bash
make build
```

Or specify a different PHP version:
```bash
make build PHP_VERSION=8.2
```

3. Install the binaries (requires sudo):
```bash
sudo make install
```

After installation, you'll have access to both `php` and `composer` commands in your terminal.

## Usage

### PHP

Run PHP version:
```bash
php -v
```

Execute a PHP file:
```bash
php script.php
```

### Composer

Run Composer commands as usual:
```bash
composer init
composer require package/name
```

### Switching PHP Versions

To switch between different PHP versions:

1. Build the new version:
```bash
make build PHP_VERSION=8.2
```

2. Switch to the new version:
```bash
sudo make switch PHP_VERSION=8.2
```

## Available Make Commands

- `make build` - Build the Docker image
- `make install` - Install PHP and Composer binaries
- `make switch` - Switch PHP version
- `make help` - Display help information

### Command Arguments

- `PHP_VERSION` - Specify PHP version (default: 8.3)
- `IMAGE_NAME` - Specify Docker image name (default: php-local)

## Included PHP Extensions

The following PHP extensions are pre-installed:
- PDO MySQL
- GD
- Intl
- ZIP
- Redis
- PCNTL
- Composer (installed globally)

## How It Works

This solution uses Docker containers to run PHP and Composer commands. The `make install` command creates shell scripts that act as wrappers around Docker commands, making them behave like native system commands. When you run a PHP or Composer command, it:

1. Spins up a temporary Docker container
2. Mounts the current directory as a volume
3. Executes the command inside the container
4. Returns the output to your terminal
5. Removes the container automatically

## Contributing

Feel free to submit issues and enhancement requests!
