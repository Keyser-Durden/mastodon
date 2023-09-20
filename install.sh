#!/bin/bash
source settings.conf

# Add the upstream repository. Maybe substitute with a snap for official support.
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

# Install Ruby 2.7+.
sudo apt install ruby ruby-dev
ruby -v 

# Create the mastodon user
sudo adduser mastodon --system --group --disabled-login

# Install Git
sudo apt install git

# Create www dir if not exist
sudo mkdir -p /var/www/

# Move the mastodon directory to /var/www/.
sudo mv mastodon/ /var/www/

# Change the owner to mastodon
sudo chown mastodon:mastodon /var/www/mastodon/ -R

# Get mastodon software
cd /var/www/mastodon/
sudo -u mastodon git checkout v4.0.2

# Install bundler: the Ruby dependency manager
sudo gem install bundler

# Install Node.js v16 (NOT compatible with Node.js v18 or v19)
# https://github.com/nodejs/snap
sudo snap install node --classic --channel=16

# Install "npm" (not sure if it is already) : maybe use snap if needs to match node version
apt install npm

# Install Yarn (method 1)
npm install --global yarn

# Install Yarn (method 2)
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
sudo apt update
sudo apt -y install yarn

# If need to lookup a snap version
# snap info node
# snap info npm







# Install Node.js's Package Manager , Yarn
npm install --global yarn
