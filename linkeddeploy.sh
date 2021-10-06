#!/bin/bash

while getopts "e:g:v" opt; do
    case $opt in
        e)
            env=$OPTARG #name of the resource group to create
        ;;
        g)
            rg=$OPTARG #name of the resource group to create
        ;;
    esac
done

echo "Creating Container Registry, pushing docker image"
#container registry + docker start
az deployment group create --name containerRegistry --template-file containerregistry.json --parameters containerregistry.parameters.json --resource-group $rg 

cd nordcloud-ucn-azure-casestudy-951c75f1f403/web
docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg IMAGE_TAG_REF=v1 -t rating-web .

ACR_SERVER=$(az acr show -n acr30239455 --query loginServer | sed -e 's/^"//' -e 's/"$//')
ACR_USER=$(az acr credential show -n acr30239455 --query username  | sed -e 's/^"//' -e 's/"$//')
ACR_PWD=$(az acr credential show -n acr30239455 --query passwords[0].value  | sed -e 's/^"//' -e 's/"$//')
docker login --username $ACR_USER --password $ACR_PWD $ACR_SERVER
docker tag rating-web $ACR_SERVER/ucn-casestudy/rating-web:v1
docker push $ACR_SERVER/ucn-casestudy/rating-web:v1
docker logout $ACR_SERVER
cd -
#container registry + docker end

echo "Creating Storage Account and Container"
storageName=deployments302344
containerName=depcon13491234

az storage account create -n $storageName -g $rg -l westeurope --sku Standard_LRS 
artifactsStorageAccountKey=$( az storage account keys list -g "$rg" -n "$storageName" -o json | jq -r '.[0].value' )

az storage container create --account-name $storageName --account-key "$artifactsStorageAccountKey" --name $containerName 

end=`date -u -d "1 hour" "+%Y-%m-%dT%H:%MZ"`

echo "Uloading templates and scripts to container"

#loganalytics start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f loganalytics-workspace.json -n loganalytics-workspace.json  
logAnalyticsTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n loganalytics-workspace.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#loganalytics end

#loganalytics  db start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f extensionscript.json -n extensionscript.json  
logAgentDbTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n extensionscript.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#loganalytics end

#keyvault start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f key-vault.json -n key-vault.json  
keyvaultTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n key-vault.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#keyvault end

#Network start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f network.json -n network.json  

networkTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n network.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#Network end

#NSG start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f nsg.json -n nsg.json  

nsgTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n nsg.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#NSG end

#Bastion start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f bastion.json -n bastion.json 
bastionTemplateUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n bastion.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#Bastion end

#AppServicePlan start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f appserviceplan.json -n appserviceplan.json 
appServicePlanTemplateUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n appserviceplan.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#AppServicePlan end

#AppService start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f appservice.json -n appservice.json 
appServiceTemplateUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n appservice.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#AppService end

#AppGateway start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f appgateway.json -n appgateway.json 
appGatewayTemplateUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n appgateway.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#Appgateway end

#DB start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f mongodb.json -n mongodb.json 
dbTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n mongodb.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')

artifactsDir=artifacts
zipFile=db.zip
deployScript=deploy-dbvm.sh

az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$deployScript -n $deployScript 
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$zipFile -n $zipFile 

end=`date -u -d "1 hour" "+%Y-%m-%dT%H:%MZ"`

blobEndpoint=$( az storage account show -n $storageName -g $rg -o json | jq -r '.primaryEndpoints.blob' )
storageBaseUrl=${blobEndpoint}${containerName}
sasTokenZipFile=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $zipFile --permissions r --expiry $end --https-only | sed -e 's/^"//' -e 's/"$//')

deployScriptUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $deployScript --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')

dbScriptFile=dbDeploy.sh
cat > $artifactsDir/$dbScriptFile <<EOF
curl -sL "$deployScriptUri" -o $deployScript
chmod 744 $deployScript
sudo ./$deployScript -e dev -u ${storageBaseUrl} -s "?${sasTokenZipFile}"
EOF

az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$dbScriptFile -n $dbScriptFile 
dbScriptFileUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $dbScriptFile --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#DB end

#LBi start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f lbi.json -n lbi.json 
lbiTemplateUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n lbi.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#LBi end

#API start
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f vmss.json -n vmss.json 
apiTemplatetUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n vmss.json --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')

artifactsDir=artifacts
zipFile=api.zip
deployScript=deploy-apivm.sh

az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$deployScript -n $deployScript 
az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$zipFile -n $zipFile 

end=`date -u -d "1 hour" "+%Y-%m-%dT%H:%MZ"`
blobEndpoint=$( az storage account show -n $storageName -g $rg -o json | jq -r '.primaryEndpoints.blob' )
storageBaseUrl=${blobEndpoint}${containerName}
sasTokenZipFile=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $zipFile --permissions r --expiry $end --https-only | sed -e 's/^"//' -e 's/"$//')

deployScriptUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $deployScript --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')

apiScriptFile=apiDeploy.sh
cat > $artifactsDir/$apiScriptFile <<EOF
curl -sL "$deployScriptUri" -o $deployScript
chmod 744 $deployScript
sudo ./$deployScript -e dev -u ${storageBaseUrl} -s "?${sasTokenZipFile}" -m 10.10.2.10
EOF

az storage blob upload --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -f $artifactsDir/$apiScriptFile -n $apiScriptFile 
apiScriptFileUri=$(az storage blob generate-sas --account-name $storageName --account-key "$artifactsStorageAccountKey" -c $containerName -n $apiScriptFile --permissions r --expiry $end --https-only --full-uri | sed -e 's/^"//' -e 's/"$//')
#API end

echo "Deploying Templates"
az deployment group create --output json --name azuredeploy --resource-group $rg \
    --parameters createNetworkUrl=$networkTemplatetUri \
    --parameters createBastionUri=$bastionTemplateUri \
    --parameters createDbUri=$dbTemplatetUri \
    --parameters createApiUri=$apiTemplatetUri \
    --parameters createLbiUri=$lbiTemplateUri \
    --parameters createAppServicePlanUri=$appServicePlanTemplateUri \
    --parameters createAppServiceUri=$appServiceTemplateUri \
    --parameters createAppGatewayUri=$appGatewayTemplateUri \
    --parameters createKeyVaultUri=$keyvaultTemplatetUri \
    --parameters createLogAnalyticsUri=$logAnalyticsTemplatetUri \
    --parameters createLogAgentDbUri=$logAgentDbTemplatetUri \
    --parameters createNSGUri=$nsgTemplatetUri \
    --parameters dbScript=$dbScriptFileUri \
    --parameters apiScript=$apiScriptFileUri \
    --parameters adminPwdOrKey=salasana21! \
    --parameters dbCommandToExecute="sh $dbScriptFile" \
    --parameters apiCommandToExecute="sh $apiScriptFile" \
    --parameters storageAccountName=$storageName \
    --parameters dockerRegistryUrl=$ACR_SERVER \
    --parameters dockerRegistryUsername=$ACR_USER \
    --parameters dockerRegistryPassword=$ACR_PWD \
    --parameters secretName=vmPass \
    --parameters secretValue=salasana21! \
    --parameters kvobjectid=`az ad signed-in-user show | jq -r '.objectId'` \
    --template-file azuredeploy.json 


