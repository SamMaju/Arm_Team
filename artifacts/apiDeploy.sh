curl -sL "https://deployments302344.blob.core.windows.net/depcon13491234/deploy-apivm.sh?se=2021-09-30T14%3A20Z&sp=r&spr=https&sv=2018-11-09&sr=b&sig=e0YSP%2B0F%2BT7%2FifGzHPwDqlPQH8%2BozcxtkkDGyuUD%2F3Y%3D" -o deploy-apivm.sh
chmod 744 deploy-apivm.sh
sudo ./deploy-apivm.sh -e dev -u https://deployments302344.blob.core.windows.net/depcon13491234 -s "?se=2021-09-30T14%3A20Z&sp=r&spr=https&sv=2018-11-09&sr=b&sig=vLU%2FeaMD9RSWImIlB%2BJhP35SliCy9x%2BVcM57y0ceM48%3D" -m 10.10.2.10
