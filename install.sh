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

