#!/bin/bash

arch=`uname -m`
case $arch in
"x86_64")
     TAG=$(curl -s -S 'https://registry.hub.docker.com/v2/repositories/rameshthoomu/fabric-ccenv-x86_64/tags/' | awk -F'"name": ' '{sub(/ .*/,"",$2);print $2}'  | tr -d "\"|,")
     if [[ "$TAG" == "latest" ]]
     then
     TAG=$(curl -s -S 'https://registry.hub.docker.com/v2/repositories/rameshthoomu/fabric-ccenv-x86_64/tags/' | awk -F'"name": ' '{sub(/ .*/,"",$2);print $3}'  | tr -d "\"|," | awk '{print $1}')
fi
  ;;
*)
  echo "No Architectural Images Available for Architecture: $arch - Please call ibm service"
  return
  ;;
esac
# replace latest tag in docker-compose-channel.yml file
cat ccenv/Dockerfile.in | sed -e "s/_ARCH_TAG_/$TAG/g" > ccenv/Dockerfile
sleep 5
cat docker-compose-channel.yml | sed -e 's/\(hyperledger\/fabric-ccenv:\)\(.*\)/\1latest/' > docker-compose-channel_bkp.yml; mv -f docker-compose-channel_bkp.yml docker-compose-channel.yml
sleep 5
echo "moving compose file"
cat docker-compose-channel.yml | sed 's/'"latest"'/'"$TAG"'/' > docker-compose-channel_bkp.yml; mv -f docker-compose-channel_bkp.yml docker-compose-channel.yml
