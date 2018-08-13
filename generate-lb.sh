#!/bin/bash

set -e

#DOCKERFILE=${PWD}/templates/lancache-fullstack/0/docker-compose.yml
#RANCHERFILE=${PWD}/templates/lancache-fullstack/0/rancher-compose.yml

DOCKER_TEMPLATE=${PWD}/build/docker-compose.yml
RANCHER_TEMPLATE=${PWD}/build/rancher-compose.yml
SERVICES=${PWD}/build/services.yml

curl -s -o services.json https://raw.githubusercontent.com/uklans/cache-domains/master/cache_domains.json

cat ${DOCKER_TEMPLATE}.tmp > ${DOCKER_TEMPLATE}
cat ${RANCHER_TEMPLATE}.tmp > ${RANCHER_TEMPLATE}

cat services.json | jq -r '.cache_domains[] | .name, .domain_files[]' | while read L; do
#cat services.json | jq -r .cache_domains[].name  | while read SERVICE ; do
## For each service, we want to add the service to the dockerfile. The default dockerfile should only have the loadbalancer, dns & sni-proxy defined
    if ! echo ${L} | grep "\.txt" ; then
	SERVICE=${L}
	if [ "${SERVICE}" = "steam" ]; then
		CONTAINER="\${STEAMCACHE_CONTAINER}"
	else
		CONTAINER="generic"
	fi
        echo "${SERVICE}"
    
        echo "  ${SERVICE}:" >> ${DOCKER_TEMPLATE}
        echo "    image: steamcache/${CONTAINER}:latest" >> ${DOCKER_TEMPLATE}
        echo "    volumes:" >> ${DOCKER_TEMPLATE}
        echo "      - \${CACHE_ROOT}/${SERIVCE}/cache:/data/cache" >> ${DOCKER_TEMPLATE}
        echo "      - \${CACHE_ROOT}/${SERIVCE}/logs:/data/logs" >> ${DOCKER_TEMPLATE}

        echo "  ${SERVICE}:" >> ${SERVICES}
        echo "    scale: 1" >> ${SERVICES}
        echo "    start_on_create: true" >> ${SERVICES}
    else

	curl -s -o ${L} https://raw.githubusercontent.com/uklans/cache-domains/master/${L}
	## files don't have a newline at the end
	echo -e -n "\n" >> ${L}
	cat ${L} | grep -v "^#" | while read URL; do

	if [ "x${URL}" != "x" ] ; then
	echo " - ${URL}"
        if ! grep "${URL}" ${RANCHER_TEMPLATE} >/dev/null 2>&1 ; then
            echo "      - hostname: '${URL}'" >> ${RANCHER_TEMPLATE}
            echo "        path: ''" >> ${RANCHER_TEMPLATE}
            echo "        priority: 1" >> ${RANCHER_TEMPLATE}
            echo "        protocol: http" >> ${RANCHER_TEMPLATE}
            echo "        service: ${SERVICE}" >> ${RANCHER_TEMPLATE}
            echo "        source_port: 80" >> ${RANCHER_TEMPLATE}
            echo "        target_port: 80" >> ${RANCHER_TEMPLATE}
        fi
	fi
	done
rm ${L}
    fi

done

cat ${SERVICES} >> ${RANCHER_TEMPLATE}

#rm services.json
rm ${SERVICES}

