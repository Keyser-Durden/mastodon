#!/bin/bash
source settings.conf

# Add the upstream repository.
echo "deb [signed-by=/etc/apt/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Import the PostgreSQL public key.
sudo mkdir -p /etc/apt/keyrings/
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/keyrings/postgresql.asc

# Update repository index and install PostgreSQL.
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Check that the postgress is opening the port on localhost
sudo ss -lnpt | grep postgres

# Start postgres if it is not running
sudo systemctl start postgresql

# Become postgresql user and setup database
sudo -u postgres -i psql
# This should be done via cmdline from inside psql
# CREATE DATABASE mastodon;
# CREATE USER mastodon;
# ALTER USER mastodon WITH ENCRYPTED PASSWORD 'your_preferred_password';
# ALTER USER mastodon createdb;
# ALTER DATABASE mastodon OWNER TO mastodon;
# \q





