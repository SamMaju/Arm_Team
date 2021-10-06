curl -sL "https://deployments302344.blob.core.windows.net/depcon13491234/deploy-dbvm.sh?se=2021-09-30T14%3A20Z&sp=r&spr=https&sv=2018-11-09&sr=b&sig=lG%2F7GU7vH7sJhVFZ1dPFjb0NMANfToRhf9NeO5x2VUA%3D" -o deploy-dbvm.sh
chmod 744 deploy-dbvm.sh
sudo ./deploy-dbvm.sh -e dev -u https://deployments302344.blob.core.windows.net/depcon13491234 -s "?se=2021-09-30T14%3A20Z&sp=r&spr=https&sv=2018-11-09&sr=b&sig=IQYHIlLT3pS5iwasHaZVOi9OuWknqqVqvSu%2BZToSBCs%3D"
