# Add the upstream repository. Maybe substitute with a snap for official support.
#echo "deb [signed-by=/etc/apt/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Import the PostgreSQL public key.
#sudo mkdir -p /etc/apt/keyrings/
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/keyrings/postgresql.asc

