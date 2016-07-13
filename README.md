

                                      ##         .
                                ## ## ##        ==
                             ## ## ## ## ##    ===
                         /"""""""""""""""""\___/ ===
                    ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
                         \______ o           __/
                           \    \         __/
                            \____\_______/ 

# Docker Cheat Sheet #
Important Docker Commands Ordered by Engine, Images and Container and then by Compute, Network, Storage

## General ##

### General: NAMING CONVENTION ###

GUIDELINE
* container / images /etc.
	* short if possible/still telling)
		* app1_tl1_tl2 app1_tl1_tl2_img
    	* 'tl1' as for tool1 e.g app1_node_exp_ssl or app1_node_exp_ssl_img
    * Use docker-compose project prefix and instance suffix

### General: EXTERNAL SOURCES ###

* @TODO:
	* Intgrate: https://dzone.com/articles/10-practical-docker-tips-for-day-to-day-docker-usa
		

## Docker ##

### Docker: ENGINE ###

COMPUTE
* start|stop: `docker-machine start|stop <host_name>` 
* ssh into: `docker-machine ssh <host_name>` 
* send one ssh command: `docker-machine ssh <host_name> '<command> <params> <...>`
* adjust time drift: `docker-machine ssh <host_name> 'sudo ntpclient -s -h pool.ntp.org`
	* only neccessary in a docker toolbox vm on virtualbox 

NETWORK
* list network: `docker network ls`
* get info for default container network "bridge": `docker network inspect bridge`
* get docker host ip: `docker-machine ip <host_name>`
* create custom bridge network: `docker network create --driver bridge <network_name>`
	* Optional:
		* specify a subnet (to avoid overlap with other networks!): `<...> --subnet=192.168.0.0/16 <...>`
      	* specify which ip's to take: `<...> --ip-range=192.168.1.0/24 <...>`
    * connect container to it:
      * in `run` command (only one network): `docker run <...> --net=<network_name> <...> `
      * connect existing container: `docker network connect <network_name> <container_name>`
      * give container a static ip: `<...> --ip=192.168.1.11 <...>`
* delete custom network: `docker network rm <network_name>`

STORAGE
* list volumes: `docker volume ls`
* create (named) volume (available only on this docker host): `docker volume create --name <volume_name>`
* Edit container file: (http://stackoverflow.com/questions/32750748/how-to-edit-files-in-stopped-not-starting-docker-container):
	```
    docker-machine ssh <host_name> 
	sudo -i
	cd /mnt/sda1/var/lib/docker/aufs/diff/<longContainerId>/etc/arangodb# vi <file_name>
	```
* copy from docker host into container: `docker cp /source/path/on/host <container_name>:/destination/path/in/container`
* delete (named) volume: `docker volume rm <volume_name>`

OTHER
* listen to events: `docker events`
* get help: `docker-machine <command_name> --help`
* get env vars: `docker-machine env <host_name>`


### Docker: IMAGES ###

COMPUTE
* build:
	```
	cd .
    docker build -t <image_name> .
    ```
* list: `docker images [-a]`
* delete: `docker rmi app1_tl1_tl2_img`
* delete dangling images in docker ps (listed as "none"):
	`docker rmi $(docker images --quiet --filter "dangling=true")`
    `docker images -qf dangling=true | xargs docker rmi` // untested yet, but always without error even if no dangling images exist)
   
NETWORK

STORAGE

OTHER
* get help: `docker <command_name> --help`


### Docker: CONTAINER ###

COMPUTE
* create & run: `docker run -itd -p 3000:3000 -v /source/path/on/host:/destination/path/in/container --name app1_tl1_tl2_1 app1_tl1_tl2_img` 
	* Optional:
		* check results: `docker inspect app1_tl1_tl2_1`
* "ssh"/bash into: `docker exec -it app1_tl1_tl2_1 /bin/bash`
	* Alternative: `docker attach app1_tl1_tl2_1`( http://stackoverflow.com/questions/30960686/difference-between-docker-attach-and-docker-exec )
	> Attach isn't for running an extra thing in a container, it's for attaching to the running process.

* start|stop: `docker start|restart|stop app1_tl1_tl2_1`
* rename: `docker rename app1_tl1_tl2_1 <new_name>`
* list: `docker ps [-a]`
* get runnings processes: `docker top app1_tl1_tl2_1`
* get logs: `docker logs app1_tl1_tl2_1`
* delete: `docker rm [-vf] app1_tl1_tl2_1`
* get long id: `docker ps -a --no-trunc`

NETWORK
* get container ip:
			```
			docker ps // get id
			docker network inspect <network_name> // check ip of that id
			```
	* Alternative: `docker inspect <container_name>`
* map exposed port to docker host: `docker run <...> -p 8529:8529 <...>`

STORAGE
* map volumes (from host to container: `docker run <...> -v /source/path/on/host:/destination/path/in/container <...>`
* volume deletion (via `-v` in `docker run`, not for named volumes) needs to happen excplitly on container deletion via `-v`: `docker rm -v <container_name>`
* delete all exited containers including their volumes: `docker rm -v $(docker ps -a -q -f status=exited)`
* delete the unwanted / left overs:
	* __README first__: https://dzone.com/articles/docker-clean-after-yourself
		`docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes`

OTHER
* get help: `docker <command_name> --help
	