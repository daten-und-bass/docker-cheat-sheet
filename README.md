

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
* Compose, and  
* Swarm  

An explaining blog post can be foud here:  
https://daten-und-bass.io/blog/new-docker-cheat-sheet-complete-rewrite-for-docker-version-1-13/
        
## COMPUTE (Services) ##
### Docker CLI ###
* create & run: `docker run -itd -p 3000:3000 -v /source/path/on/host:/destination/path/in/container --name <ctr_name> <img_name>` 
    * Description: Interactive container not attached to the current shell with port to host mapping and a host bind volume
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

ARG <port_env_var>
ENV NODE_ENV ${<nodejs_env>}  

RUN <some_bash_cmd> \
    && <another_bash_cmd>

COPY <file_name> /destination/path/in/container
VOLUME /source/path/on/host:/destination/path/in/container  

EXPOSE ${<port_env_var>}    # only exposed by container, but not yet mapped to the docker host  

USER <user_name>            # set permisions accordingly (before) ... if not specified: root
WORKDIR <dir_name>
CMD <main_bash_cmd>         # or ENTRYPOINT command (not overwritable) for external scripts
```  

* build:  
`cd .`  
`docker build -t <image_name> .`
* list all images: `docker images [-a]`
* delete: `docker rmi <img_name>`
* delete dangling images in docker ps (listed as "none"): `docker rmi $(docker images --quiet --filter "dangling=true")` 
    * Alternative: `docker images -qf dangling=true | xargs docker rmi` // untested yet, but always without error even if no dangling images exist  

### Docker Compose ###
```yaml
version: "3"

services: 
  <srv_name>:
    build:
      context: ./path/to/dir
      args:
        - <port>
    image: <reg_tag>/<img_name>:<img_tag>
    networks:
      - <net_name>
    ports:
       - "${<port_env_var>}:${<port_env_var>}"                  # port to host mapping
    environment:
      - NODE_ENV=<nodejs_env>
      - PORT_ENV_VAR="${<port_env_var>}"
    volumes:
      - /source/path/on/host:/destination/path/in/container     # host bind
    security_opt:
      - no-new-privileges

networks:
  <net_name>:           # custom network created before
    external: true

volumes:
  <vol_name>:           # named volume created before
    external: true
```
* test config: `docker-compose config`

* build: `docker-compose build`

* push to registry: `docker-compose push    # as specified above by <reg_tag>`

* create & start in one: `docker-compose up`               

* start | stop: `docker-compose start|restart|stop <project_name>`

* kill | delete: `docker-compose kill|rm <project_name>`



### Docker Swarm ###
* deploy stack: `docker stack deploy --compose-file=docker-compose.yml <stack_name>    # e.g. ${COMPOSE_PROJECT_NAME}`
    * before do: `docker-compose build` and `docker-compose push`

```yaml
version: "3"

services: 
  <srv_name>:
    <...>:  

    deploy:
      mode: replicated         # or 'global' for one on each docker swarm host
      replicas: <amount>          
      restart_policy:
        condition: <condition>
        max_attempts: <amount>
        delay: <amount>s
      resources:
        limits:                # hard limit
          cpus: '<cpu_share>'
          memory: <amount>M
        reservations:          # soft limit
          cpus: '<cpu_share>'
          memory: <amount>M  
  
networks:
  <...>:  

volumes:
  <...>:
```

* list all stacks: `docker stack ls`

* list tasks of stack: `docker stack ps <stack_name>`

* list services of stack: `docker stack services <stack_name>     # services `

* delete: `docker stack rm <stack_name>`  


## NETWORK ##
### Docker CLI ###
* list networks: `docker network ls`
* get info for default container network "bridge": `docker network inspect bridge`
* get docker host ip: `docker-machine ip <host_name>`
* create custom bridge network: `docker network create --driver bridge <network_name>`
    * Optional:
        * specify a subnet (to avoid overlap with other networks!): `<...> --subnet=192.168.0.0/16 <...>`
        * specify which ip's to take: `<...> --ip-range=192.168.1.0/24 <...>`
        * specify as internal: `--internal`
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
### Docker Dockerfile ###
```dockerfile
<...>

EXPOSE 3000 # only exposed by container, but not yet mapped to the docker host

<...>
```
### Docker Compose ###
```yaml
version: "3"

services: 
  <...>:


networks:
  <net_name>:       # custom network created before
    external: true

volumes:
  <...>:
```

### Docker Swarm ###
* specify ip or eth settings for swarm cluster: 
    * Advertised address to swarm members for API access and overlay networking: `docker swarm init --advertise-addr <addr> <...>`
    * Listening address for inbound swarm manager traffic: `docker swarm init --listen-addr <addr> <...>`

* create overlay network: `docker network create --driver overlay --subnet=<ip_range> --gateway=<ip_address> <net_name>`
    * Optional: `--attachable` for allowing unmanaged (non-swarm) containers and `--opt encrypted` for encryption


## STORAGE ##
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


### Docker Dockerfile ###
```dockerfile
<...>

VOLUME /source/path/on/host:/destination/path/in/container

<...>
```
### Docker Compose ##
```yaml
version: "3"

services: 
  <...>:

networks:
  <...>:

volumes:
  <vol_name>:       # named volume created before
    external: true
```
### Docker Swarm ###
Work in progress

Keep in mind that regular volumes (see above) are always local to that host only (so a container needing that volume can only correctly start on thist host).


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
 
### OTHER ###
* get help: `docker <command_name> --help`

## Further information ##

Reference documentation:
https://docs.docker.com/reference/





    
