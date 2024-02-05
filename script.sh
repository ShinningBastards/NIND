rm -rf ~/.ssh/known_hosts

# Gitlab server

## Create debian-gitlab-server
echo "Creating gitlab server ..."
doctl compute droplet create debian-gitlab-server --droplet-agent=true --enable-monitoring --image ubuntu-20-04-x64 --no-header --region LON1 --size s-4vcpu-8gb --ssh-keys de:8e:e4:13:b9:11:56:dd:05:f1:ce:1c:87:82:de:f7 --tag-name gitlab --wait
## Assign reserved-ip to debian-gitlab-server
echo "Assign reserved ip to gitlab server ..."
ID_GITLAB=$(doctl compute droplet get debian-gitlab-server | awk 'NR==2{print $1}')
doctl compute reserved-ip-action assign 159.65.211.103 $ID_GITLAB
sleep 20
## Deploy Gitlab server
echo "Deploy gitlab server ..."
ansible-playbook -i ./ansible/hosts.ini ./ansible/gitlab/deploy_server.yml
ansible-playbook -i ./ansible/hosts.ini ./ansible/configure_firewall.yml

# Database

## Create debian-database
echo "Creating database ..."
doctl compute droplet create debian-database --droplet-agent=true --enable-monitoring --image ubuntu-20-04-x64 --no-header --region LON1 --size s-2vcpu-2gb --ssh-keys de:8e:e4:13:b9:11:56:dd:05:f1:ce:1c:87:82:de:f7 --tag-name database --wait
## Assign reserved-ip to database
echo "Assign reserved ip to database ..."
ID_DATABASE=$(doctl compute droplet get debian-database | awk 'NR==2{print $1}')
doctl compute reserved-ip-action assign 159.65.211.183 $ID_DATABASE
sleep 20
## Deploy database
echo "Deploy database ..."
ansible-playbook -i ./ansible/hosts.ini ./ansible/configure_database.yml

Server

# Create debian-server
echo "Creating server ..."
doctl compute droplet create debian-server --droplet-agent=true --enable-monitoring --image ubuntu-20-04-x64 --no-header --region LON1 --size s-4vcpu-8gb --ssh-keys de:8e:e4:13:b9:11:56:dd:05:f1:ce:1c:87:82:de:f7 --tag-name server --wait
## Assign reserved-ip to server
echo "Assign reserved ip to server ..."
ID_SERVER=$(doctl compute droplet get debian-server | awk 'NR==2{print $1}')
doctl compute reserved-ip-action assign 159.65.208.124 $ID_SERVER
sleep 20
Deploy server
echo "Deploy server ..."
rsync -avz -e "ssh -i ~/.ssh/ocean" ./src/front root@159.65.208.124:/opt
rsync -avz -e "ssh -i ~/.ssh/ocean" ./src/back root@159.65.208.124:/opt
ansible-playbook -i ./ansible/hosts.ini ./ansible/configure_server.yml