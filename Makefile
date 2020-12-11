PROJECT="corda-node"
IMG="corda-node:latest"

default:
	echo ${PROJECT}

run: 
	docker run -it --rm \
		--name ${PROJECT} \
		--memory=2048m \
		--cpus=2 \
	 	-p 8080:8080 \
	 	-p 10200:10200 \
	 	-p 10222:2222 \
		${IMG}

docker-build:
	docker build . -t ${IMG}

ssh:
	docker exec -it ${PROJECT} bash

corda-ssh:
	ssh 192.168.99.109 -p 10222 -l admin