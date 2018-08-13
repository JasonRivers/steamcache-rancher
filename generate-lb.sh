#!/bin/bash

set -x

#DOCKERFILE=${PWD}/templates/lancache-fullstack/0/docker-compose.yml
#RANCHERFILE=${PWD}/templates/lancache-fullstack/0/rancher-compose.yml

DOCKER_TEMPLATE=${PWD}/build/docker-compose.yml
RANCHER_TEMPLATE=${PWD}/build/rancher-compose.yml

curl -s -o services.json https://raw.githubusercontent.com/uklans/cache-domains/master/cache_domains.json

cat ${DOCKER_TEMPLATE}.tmp > ${DOCKER_TEMPLATE}
cat ${DOCKER_TEMPLATE}.tmp > ${DOCKER_TEMPLATE}

cat services.json | jq -r .cache_domains[].name  | while read SERVICE ; do
## For each service, we want to add the service to the dockerfile. The default dockerfile should only have the loadbalancer, dns & sni-proxy defined
    echo "${SERVICE}"

    echo "  ${SERVICE}:" >> ${DOCKER_TEMPLATE}
    echo "    image: steamcache/generic:latest" >> ${DOCKER_TEMPLATE}
    echo "    volumes:" >> ${DOCKER_TEMPLATE}
    echo "      - \${CACHE_ROOT}/${SERIVCE}/cache:/data/cache" >> ${DOCKER_TEMPLATE}
    echo "      - \${CACHE_ROOT}/${SERIVCE}/logs:/data/logs" >> ${DOCKER_TEMPLATE}

    curl -s -o ${SERVICE}.txt https://raw.githubusercontent.com/uklans/cache-domains/master/${SERVICE}.txt
    for URL in `cat ${SERVICE}.txt`; do
        if ! grep "${URL}" ${RANCHER_TEMPLATE} >/dev/null 2>&1 ; then
            echo "      - hostname: '${URL}'" >> ${RANCHER_TEMPLATE}
            echo "        path: ''" >> ${RANCHER_TEMPLATE}
            echo "        priority: 1" >> ${RANCHER_TEMPLATE}
            echo "        protocol: http" >> ${RANCHER_TEMPLATE}
            echo "        service: ${SERVICE}" >> ${RANCHER_TEMPLATE}
            echo "        source_port: 80" >> ${RANCHER_TEMPLATE}
            echo "        target_port: 80" >> ${RANCHER_TEMPLATE}
            echo $URL
        fi
    done
rm ${SERVICE}.txt

done

rm services.json



