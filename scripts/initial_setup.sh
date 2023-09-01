#/bin/bash

echo "Creating mediaServer group and adding default user..."
uid=$(id -u)
sudo groupadd -g 1002 mediaServer
sudo useradd -m -s /bin/bash -u $uid -g 1002 $(whoami)
sudo chfn -o umask=002 $(whoami)

# echo "Creating directories"
# sudo mkdir -p "$3/appdata"
# sudo mkdir -p "$3/downloads/torrents/books"
# sudo mkdir -p "$3/downloads/torrents/movies"
# sudo mkdir -p "$3/downloads/torrents/music"
# sudo mkdir -p "$3/downloads/torrents/tv"
# sudo mkdir -p "$3/downloads/usenet/complete/books"
# sudo mkdir -p "$3/downloads/usenet/complete/movies"
# sudo mkdir -p "$3/downloads/usenet/complete/music"
# sudo mkdir -p "$3/downloads/usenet/complete/tv"
# sudo mkdir -p "$3/medialibrary/books"
# sudo mkdir -p "$3/medialibrary/movies"
# sudo mkdir -p "$3/medialibrary/music"
# sudo mkdir -p "$3/medialibrary/tv"

echo "Setting permissions on folders..."
sudo chown -R $(whoami):mediaServer /media # sudo chown -R shyonae:mediaServer /media
sudo chmod -R a=,a+rX,u+w,g+w /media       # sudo chmod -R a=,a+rX,u+w,g+w /media

### JQ INSTALL ###
echo "Installing JQ..."
sudo apt-get update
sudo apt-get install -y jq

### DOCKER INSTALL ###
echo "Installing Docker and dependencies..."
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Creating bridge networks..."
docker network create -d bridge socketProxyNetwork
docker network create -d bridge managementStackNetwork
docker network create -d bridge swagStackNetwork
docker network create -d bridge downloadStackNetwork
docker network create -d bridge arrStackNetwork
docker network create -d bridge jellyStackNetwork
docker network create -d bridge generalStackNetwork
docker network create -d bridge vaultNetwork

### GRAFANA LOKI DOCKER PLUGIN INSTALL ###
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
sudo touch /etc/docker/daemon.json
sudo runuser -l root -c 'jq -n "{debug: true, \"log-driver\": \"loki\", \"log-opts\": { \"loki-url\": \"http://localhost:3100/loki/api/v1/push\", \"loki-batch-size\": \"400\"}}" > /etc/docker/daemon.json'

### INFISICAL INSTALL ###
echo "Installing Infisical..."
curl -1sLf \
    'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' |
    sudo -E bash
sudo apt-get update && sudo apt-get install -y infisical
infisical login -i

### SUBLIME TEXT INSTALL ###
echo "Installing Sublime Text..."
sudo wget -O- https://download.sublimetext.com/sublimehq-pub.gpg | gpg -dearmor | sudo tee /usr/share/keyrings/sublimehq.gpg
echo 'deb [signed-by=/usr/share/keyrings/sublimehq.gpg] https://download.sublimetext.com/ apt/stable/' | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update && sudo apt install -y sublime-text

### TELEGRAM INSTALL ###
echo "Installing Telegram..."
sudo apt install -y telegram-desktop

### BRAVE INSTALL ###
echo "Installing Brave..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update && sudo apt install -y brave-browser

### TABBY INSTALL###
echo "Installing Tabby..."
sudo curl -s https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
sudo apt install -y tabby-terminal
