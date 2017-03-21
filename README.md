

                                      ##         .
                                ## ## ##        ==
                             ## ## ## ## ##    ===
                         /"""""""""""""""""\___/ ===
                    ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
                         \______ o           __/
                           \    \         __/
                            \____\_______/ 

# Docker Cheat Sheet #
Important Docker Commands Ordered by  
* Compute (Services),  
* Network,  
* Storage  
  
and then by  
  
* Docker CLI,  
* Dockerfile,  
* Compose and  
* Swarm  
		
## COMPUTE (Services) ##
### Docker CLI ###
* create & run: `docker run -itd -p 3000:3000 -v /source/path/on/host:/destination/path/in/container --name <ctr_name> <img_name>` 
	* Description: Interactive container attached to the current shell with port to host mapping and a host bind volume
	* Optional:
		* Check results: `docker inspect <ctr_name>`
* "ssh"/bash into: `docker exec -it <ctr_name> /bin/bash`
	* Description: Connect to a running container with a new shell
	* Alternative: `docker attach <ctr_name>`( [more on Stackoverflow](http://stackoverflow.com/questions/30960686/difference-between-docker-attach-and-docker-exec) )

		> Attach isn't for running an extra thing in a container, it's for attaching to the running process.

* start | stop: `docker start|restart|stop <ctr_name>`
* rename: `docker rename <ctr_name> <new_name>`
* list: `docker ps [-a]`
* get runnings processes: `docker top <ctr_name>`
* get logs: `docker logs <ctr_name>`
* delete: `docker rm [-vf] <ctr_name>`
* get long id: `docker ps -a --no-trunc`
### Docker Dockerfile ###
```dockerfile
FROM <img_name>:<tag_name>
RUN <bash_cmd>
VOLUME /source/path/on/host:/destination/path/in/container
EXPOSE 3000 # only exposed by container, but not yet mapped to the docker host
CMD <bash_cmd>
```
### Docker Compose ###
### Docker Swarm ###

### NETWORK ###
### Docker CLI ###
* list networks: `docker network ls`
* get info for default container network "bridge": `docker network inspect bridge`
* get docker host ip: `docker-machine ip <host_name>`
* create custom bridge network: `docker network create --driver bridge <network_name>`
	* Optional:
		* specify a subnet (to avoid overlap with other networks!): `<...> --subnet=192.168.0.0/16 <...>`
      	* specify which ip's to take: `<...> --ip-range=192.168.1.0/24 <...>`
    * connect container to it:
      * in `run` command (only one network allowed): `docker run <...> --net=<network_name> <...> `
      * connect existing container: `docker network connect <network_name> <container_name>`
      * give container a static ip: `<...> --ip=192.168.1.11 <...>`
* delete custom network: `docker network rm <network_name>`

* get container ip:  
`docker ps` // get id  
`docker network inspect <network_name>` // check ip of this id
	* Alternative: `docker inspect <container_name>`
* map exposed container port to docker host: `docker run <...> -p 8529:8529 <...>`
## Docker Dockerfile ##
## Docker Compose ##
## Docker Swarm ##



### STORAGE ###
### Docker CLI ###
* list volumes: `docker volume ls`
* create (named) volume (available only on this docker host): `docker volume create --name <volume_name>`
* Edit (on docker host) a containter file (e.g. .conf) of a stopped | not starting containter:  
	* http://stackoverflow.com/questions/32750748/how-to-edit-files-in-stopped-not-starting-docker-container  
    `docker-machine ssh <host_name>`  
	`sudo -i`    
	`cd /mnt/sda1/var/lib/docker/aufs/diff/<longContainerId>/path/to/file`  
	`vi <file_name>`  
* copy from docker host into container: `docker cp /source/path/on/host <container_name>:/destination/path/in/container`
* delete (named) volume: `docker volume rm <volume_name>`

* map volumes (from host to container: `docker run <...> -v /source/path/on/host:/destination/path/in/container <...>`
* volume deletion (via `-v` in `docker run`, not for named volumes) needs to be excplit on container deletion via `-v`: `docker rm -v <container_name>`
* delete all exited containers including their volumes: `docker rm -v $(docker ps -a -q -f status=exited)`
* delete the unwanted / left overs:
	* __README first__: https://dzone.com/articles/docker-clean-after-yourself
		`docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes`


## Docker Dockerfile ##
## Docker Compose ##
## Docker Swarm ##

## Others ## 
### Docker Machine ###
* start | stop: `docker-machine start|stop <host_name>` 
* ssh into: `docker-machine ssh <host_name>` 
* send one ssh command: `docker-machine ssh <host_name> '<command> <params> <...>`
* adjust time drift: `docker-machine ssh <host_name> 'sudo ntpclient -s -h pool.ntp.org`
	* only neccessary in a docker toolbox vm on virtualbox
### Docker Events ###
* listen to events: `docker events`
* get help: `docker-machine <command_name> --help`
* get env vars: `docker-machine env <host_name>`
### Docker Images ###
* build:  
`cd .`  
`docker build -t <image_name> .`
* list: `docker images [-a]`
* delete: `docker rmi <img_name>`
* delete dangling images in docker ps (listed as "none"): `docker rmi $(docker images --quiet --filter "dangling=true")` 
	* Alternative: `docker images -qf dangling=true | xargs docker rmi` // untested yet, but always without error even if no dangling images exist 
### OTHER ###
* get help: `docker <command_name> --help`
### OTHER ###
* get help: `docker <command_name> --help`






	