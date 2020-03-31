#/bin/bash
set -e

name=${1:-joergjo-springboot-pgsql}
resource_group=${2:-springboot-demos}
location=${3:-francecentral}
appservice_plan=${4:-springboot-plan}
sku=${5:-P1V2}

rg_exists=$(az group exists --name ${resource_group})
if [[ $rg_exists ]]; then
    az group delete --name ${resource_group} --yes
fi

echo "Creating resource group ${resource_group} in ${location}..."
az group create \
  --name ${resource_group} \
  --location ${location}

echo "Creating App Service plan ${appservice_plan} as ${sku}..."
az appservice plan create \
  --name ${appservice_plan} \
  --resource-group ${resource_group} \
  --sku ${sku} \
  --is-linux

echo "Deploying Web App ${name}..."
az webapp create \
  --name ${name} \
  --resource-group ${resource_group} \
  --plan ${appservice_plan} \
  --deployment-container-image-name joergjoeu.azurecr.io/springboot-samples/appservice

echo "Updating configuration..."
az webapp config appsettings set \
  --name ${name} \
  --resource-group ${resource_group} \
  --settings PGSQL_JDBC_URL="jdbc:postgresql://joergjo-springboot.postgres.database.azure.com:5432/mypgsqldb?sslmode=require" PGSQL_USERNAME="joergjo@joergjo-springboot" PGSQL_PASSWORD="LjX_SH7ICpGsUPmwxb_r"

az webapp restart \
  --name ${name} \
  --resource-group ${resource_group}

sleep 5
echo "Ready. Pinging Web app..."
curl -s "https://${name}.azurewebsites.net/pets"
