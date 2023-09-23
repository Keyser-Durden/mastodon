#!/bin/bash
source settings.conf

install_snaps() {
echo "### Installing Snaps ###"
# Instal snaps
while IFS= read -r snap_line; do
    if [ -n "snap_line" ]; then
        snap install $snap_line
    fi
done < snaps.list
}

install_packages() {
# Install Packages
export DEBIAN_FRONTEND=noninteractive
apt update
# apt -y upgrade
cat packages.list | xargs apt-get install -y
unset DEBIAN_FRONTEND
}

# Add mastodon user
useradd -m -s /usr/sbin/nologin $os_username

sudo apt install -y postgresql postgresql-contrib

setup_db() {
psql_script=$(tr -d '\n' < psql.list)
echo $psql_script
}

setup_db


exit 1

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
#sudo apt install -y ruby ruby-dev
#ruby -v 

# Create the mastodon user
sudo adduser mastodon --system --group --disabled-login

# Install Git
#sudo apt install -y git

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
#sudo snap install node --classic --channel=16

# Install "npm" (not sure if it is already) : maybe use snap if needs to match node version
#apt install -y npm

# Install Yarn (method 1)
npm install --global yarn

# Install Yarn (method 2)
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#sudo apt update
#sudo apt -y install yarn

# If need to lookup a snap version
# snap info node
# snap info npm

# Install packages (perhaps separate into own file)
#sudo apt install -y redis-server optipng pngquant jhead jpegoptim gifsicle nodejs imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file g++ libprotobuf-dev protobuf-compiler pkg-config gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev libidn11-dev libicu-dev libjemalloc-dev

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

#  Prepare the database now? y
# Compile the assets now? (Y/n) y
# If Mastodon fails to compile, you should upgrade the server to 2 CPU cores and 3G RAM

# Run this Rails as mastodon user
sudo -u mastodon RAILS_ENV=production bundle exec rake mastodon:setup

# Create UI admin user
    # Do you want to create an admin user straight away? Yes
    # Username: super_admin
    # E-mail: xiao@linuxbabe.com
    # You can login with the password: <it will output password here. Save it>

# Setup Mastodon systemd template
sudo cp /var/www/mastodon/dist/mastodon*.service /etc/systemd/system/

# Edit service file
sudo sed -i 's/home\/mastodon\/live/var\/www\/mastodon/g' /etc/systemd/system/mastodon-*.service

# Change /home/mastodon/.rbenv/shims/bundle to /usr/local/bin/bundle.
sudo sed -i 's/home\/mastodon\/.rbenv\/shims/usr\/local\/bin/g' /etc/systemd/system/mastodon-*.service

# Reload systemd for the changes to take effect
sudo systemctl daemon-reload

# Enable and start mastodon
sudo systemctl enable --now mastodon-web mastodon-sidekiq mastodon-streaming

# Make sure they are all in active (running)
sudo systemctl status mastodon-web mastodon-sidekiq mastodon-streaming

# Check if mastodon is running on port 3k (wait a few seconds after running the above command)
sudo ss -lnpt | grep 3000

# Configure Nginx Reverse Proxy
#sudo apt -y install nginx
sudo mkdir -p /var/nginx/cache/
sudo cp /var/www/mastodon/dist/nginx.conf /etc/nginx/sites-available/mastodon.conf
# sed for hostname and replace
# Sed for root and replace
    # find : root /home/mastodon/live/public;
    # Replace with : root /var/www/mastodon/public;
# generate certs with lets encrypt. Update nginx conf file
# test config
sudo nginx -t
# Reload config
systemctl reload nginx

# Should be able to hit the site Now




