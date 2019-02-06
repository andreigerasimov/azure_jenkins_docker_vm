#!/bin/bash
echo "AZURE JENKINS"
echo "Azure name:"
read AZ_NAME
read -sp "Azure password: " AZ_PASS && echo && az login -u $AZ_NAME -p $AZ_PASS
echo "Name Group  VM"
read GROUP_NAME
az group create --name $GROUP_NAME --location eastus
echo "VM name"
read VM
echo "Admin user name"
read ADMIN
az vm create --resource-group $GROUP_NAME --name $VM --image UbuntuLTS --admin-username $ADMIN --generate-ssh-keys --custom-data cloud-init.txt
az vm open-port --resource-group $GROUP_NAME --name $VM --port 8080 --priority 1001
az vm open-port --resource-group $GROUP_NAME --name $VM --port 1337 --priority 1002
RESULT=$(az vm show --resource-group $GROUP_NAME --name $VM -d --query [publicIps] --o tsv)
echo $RESULT
echo "Whait 5 min"
sleep 200
ssh $ADMIN@$RESULT -y << EOF
sudo usermod -aG docker $ADMIN
sudo usermod -aG docker jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
EOF
echo "Go to " $RESULT":8080 and Unlock Jenkins"
sleep 30
echo "Connect to Azure..."
