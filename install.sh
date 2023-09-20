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

# Install packages (perhaps separate into own file)
sudo apt install redis-server optipng pngquant jhead jpegoptim gifsicle nodejs imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file g++ libprotobuf-dev protobuf-compiler pkg-config gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev libidn11-dev libicu-dev libjemalloc-dev

# install dependency packages for Mastodon
sudo -u mastodon bundle config deployment 'true'
sudo -u mastodon bundle config without 'development test'
sudo -u mastodon bundle install -j$(getconf _NPROCESSORS_ONLN)

# run setup 
sudo -u mastodon RAILS_ENV=production bundle exec rake mastodon:setup

# Expect : fill out 
echo before comment
: <<'END'

    Domain name: Choose a domain name to use for your Mastodon instance. For example, I use social.linuxbabe.com.
    Enable single user mode: If you want visitors to be able to register on your Mastodon instance, then don’t enable single user mode.
    Are you using Docker to run Mastodon: No.
    PostgreSQL host: 127.0.0.1
    PostgreSQL port: 5432
    PostgreSQL database: mastodon
    PostgreSQL user: mastodon
    PostgreSQL user password: enter the password for the mastodon user which is created in step 1.
    Redis host: 127.0.0.1
    Redis port: 6379
    Redis password: Just press Enter, because there’s no password for Redis.
    Do you want to store uploaded files on the cloud? If you want to store user-uploaded files in S3 object storage, then you can choose Yes. I just want to store files on my own server, so I choose No.
    Do you want to send emails from localhost? If this is your mail server, or you have set up an SMTP relay, then you can choose Yes. If you choose No, then you need to enter your SMTP server login credentials.
    E-mail address to send e-mails “from”: You can press Enter to use the default sender email address.
    Send a test e-mail with this configuration right now? Choose Yes to send a test email.
    Send test e-mail to: Enter the test email address.
    Save configuration? Choose Yes.
    
END
echo after comment



