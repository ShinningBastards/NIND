# Gitlab server

## Create debian-gitlab-server
echo "Creating gitlab server ..."
doctl compute droplet create debian-gitlab-server --droplet-agent=true --enable-monitoring --image ubuntu-20-04-x64 --no-header --region LON1 --size s-4vcpu-8gb --ssh-keys de:8e:e4:13:b9:11:56:dd:05:f1:ce:1c:87:82:de:f7 --tag-name gitlab --wait
## Assign reserved-ip to debian-gitlab-server
echo "Assign reserved ip to gitlab server ..."
ID=$(doctl compute droplet get debian-gitlab-server | awk 'NR==2{print $1}')
doctl compute reserved-ip-action assign 159.65.211.103 $ID
## Deploy Gitlab server
echo "Deploy gitlab server ..."
ansible-playbook -i ./ansible/hosts.ini ./ansible/gitlab/deploy_server.yml
ansible-playbook -i ./ansible/hosts.ini ./ansible/configure_firewall.yml