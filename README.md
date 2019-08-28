# ivbor7_microservices
ivbor7 microservices repository

## Homework #12 (docker-2 branch)

Within the hw#12 the following tasks were done:
 - TravisCI plugged up to current repository and integrated with Slack chat
 - Install Docker – 17.06+, docker-compose – 1.14+, docker-machine – 0.12.0+
 - major docker commands considered:
 ```
Here is a list of the basic Docker commands from this page, and some related ones if you’d like to explore a bit before moving on.

docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello  # Run "friendlyhello" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode
docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rmi <image id>           # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine
docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag                   # Run image from a registry
 ```
 - the main differences between image and container described (*)
 - GCP preparation tasks fulfilled
 - working with Docker - explore main docker commands
 - docker repository structure created
 - Dockerfile created
 - build and running the container
 - working with Dockerhub
 

 - [x] install [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) plus [postinstall](https://docs.docker.com/install/linux/linux-postinstall/) 
and [docker-machine](https://docs.docker.com/machine/install-machine/)


```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

 - [x] new project "docker", ID=docker-250311 created on GCP
 - [x] create Docker-host on GCP with Docker installed:
```
export GOOGLE_PROJECT=docker-250311
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-project docker-250311 \
docker-host
. . .
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!

$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://104.155.51.208:2376           v19.03.1
```
  - to switch to a remote host run command `$ eval $(docker-machine env docker-host)` after that all subsequent commands will be executed on remote GCP host via docker daemon.
  - `eval $(docker-machine env --unset)` - use this command to switch to local docker
  - `docker-machine rm <host-name>` - use this command to remove instance

 - [x] compare outputs of the comman1ds from lecture  
   `$ docker run --rm -ti tehbilly/htop`
     - the only one running process (htop) with PID=1
 
   `$ docker run --rm --pid host -ti tehbilly/htop`
     - we can see all processes running on host system including docker-daemon's worker processes in -namespace moby 

 - [x] create Dockerfile to build image with help Docker:
 `$ docker build -t reddit:latest .` 
 Attention: the dot "." at the end of command is mandatory. It points the path to Docker context(see the command output 1-st line: `Sending build context to Docker daemon   7.68kB`).
Run the created container running the command: `docker run --name reddit -d --network=host reddit:latest` After running the container the service running on this host was not reachable due to the lack of appropriate firewall rule. To fix this issue add the firewall rule:
```
$ gcloud compute firewall-rules create reddit-app \
--allow tcp:9292 \
--target-tags=docker-machine \
--description="Allow PUMA connections" \
--direction=INGRESS
```
 - [x] register on docker hub 
 - [x] assign a tag "reddit:latest" to our image with the reddit application onboard and push it to the docker hub for further using it from anywhere:
 ```
$ docker tag reddit:latest <dockerhub-login>/otus-reddit:1.0
$ docker push <dockerhub-login>/otus-reddit:1.0
 ```
 - [x] after running reddit image let's doing some checks:
 ```
$ docker logs reddit -f   <-- view the container's log
$ docker exec -it reddit bash  <-- login to the container, display the process list and kill the container
  • ps aux
  • killall5 1
$ docker start reddit  <-- run the container again
$ docker stop reddit && docker rm reddit  <-- stop and remove the container
$ docker run --name reddit --rm -it <dockerhub-login>/otus-reddit:1.0 bash  <-- run the container without application and display the processes
  • ps aux
  • exit
 ```


 - [ ] Extra task with (*) - create the prototype of infrastructure **in ToDo list** 


## Homework #13 (docker-3 branch)

Within the hw#13 the following tasks were done:

 - split our application into several components called microservices
 - run the our microservice application
 - building and running an application in their containers
 - extra task with (*) - run the containers under the different network aliases
 - second task with (*) - take measures to optimize the docker images for microservices
 - plug a volume to container with mongodb to store posts
 
 - [x] Run the container created earlier in previous task:
`$ docker run --name reddit -d -p 9292:9292 ivbdockerhub/otus-reddit:1.0`
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://35.205.104.66:2376           v19.03.1
```
> switch to the remote docker-host running command:
`$ eval $(docker-machine env docker-host)`


 - [x] Create new structure for application in src folder:
      - src/post - service for posts creating
      - src/comment - service for comments writing
      - src/ui - web-interface that interacts with other services
 
 - [x] Download the latest version of MongoDB: `docker pull mongo:latest`
Then build images separate one for each service:
```
docker build -t <your-dockerhub-login>/post:1.0 ./post-py
> Error: 
> unable to execute 'gcc': No such file or directory
>    error: command 'gcc' failed with exit status 1
> fix: add install gcc and dev pack inot Dockerfile:
> RUN apk add --update gcc python python-dev py-pip build-base
docker build -t <your-dockerhub-login>/comment:1.0 ./comment
docker build -t <your-dockerhub-login>/ui:1.0 ./ui
```
 - [x] create special network, as the network aliases do not work in default bridge network:
 `docker network create reddit`
   - and run our containers:
 ```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:1.0
 ```
 Note: to remove the user-defined bridge, it's needed to disconnect a running container from user-defined bridge first: `docker network disconnect network-name container-name` then remove it: `docker network rm network-name` 
 
 - [x] extra task with (*): run the containers using another network aliases without re-creating the base images. As for network-scoped aliases [this article](https://docs.docker.com/v17.09/engine/userguide/networking/work-with-networks/) will be usefull: 
```
For mongo-container the network aliases replaced with "db4post" and "db4comment" for connection between MongoDB <--> Post-service and MongoDB <--> Comment-service containers respectively:
`$ docker run -d --network=reddit --network-alias=db4post --network-alias=db4comment mongo:latest`
 - Post-service container:
$ docker run -d --network=reddit --network-alias=post_add -e POST_DATABASE_HOST=db4post ivb/post:1.0
 - Comment-microservice container
$ docker run -d --network=reddit --network-alias=comment_add -e COMMENT_DATABASE_HOST=db4comment ivb/comment:1.0
$ docker run -d --network=reddit -p 9292:9292 --env POST_SERVICE_HOST=post_add --env COMMENT_SERVICE_HOST=comment_add ivb/ui:1.0

 - after 1-st approach of improving the -ui- image:
 docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
ivb/ui                 2.0                 6bd3f2d523a3        36 minutes ago      453MB
ivb/ui                 1.0                 8bfb88638c48        5 hours ago         782MB
```
 - [x] extra task with (*) - optimize image assembly using other base-images, the Alpine Linux in this particular case:
```
  $ docker images
  REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
> ivb/post               3.0                 a250aa037b71        6 seconds ago       110MB
> ivb/comment            3.0                 97f2a8416753        28 minutes ago      69.9MB
> ivb/ui                 3.0                 94f0f07d7248        53 minutes ago      71.3MB
> ivb/ui                 2.0                 6bd3f2d523a3        6 hours ago         453MB
> ivb/ui                 1.0                 8bfb88638c48        10 hours ago        782MB
> ivb/comment            1.0                 ff6a1498524f        10 hours ago        779MB
> ivbdockerhub/post      1.0                 38f99d2f28ea        10 hours ago        199MB
============================================================================================
```
Dockerfile.# - files contain optimized image description for docker and are located in each folder responsible for particular microservice.

 - [x] create a volume and connect it to the container with mongodb:
 ```
 $ docker volume create reddit_db
 $ docker run -d --network=reddit --network-alias=post_db \
--network-alias=comment_db -v reddit_db:/data/db mongo:latest
```
other microservice images: post, comment and ui can be mounted in usual way.

## Homework #14 (docker-4 branch)

Within the hw#14 the following tasks were done:
 - have investigated how docker work with different network drivers (none, host and bridge) `> docker network create reddit --driver ["none","bridge","host"]`:
   for investigation joffotron/docker-net-tools, tutum/dnsutils and nginx images were used: 
   ```
   docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
   docker run -ti --rm --network br1 joffotron/docker-net-tools -c "traceroute 127.0.0.11"
   docker network create --driver=bridge test
   docker run --network test tutum/dnsutils nslookup c_nginx 127.0.0.11
   docker run --network host -d nginx
   ```
   to monitor net-namespaces netns utility was used on docker-host:
   `> sudo ln -s /var/run/docker/netns /var/run/netns`
   `> sudo ip netns`
   to run a process in a given namespace run this command: `ip netns exec <namespace> <command>`
   - run the containers in one reddit bridge-network 
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post ivb/post:3.0
docker run -d --network=reddit --network-alias=comment ivb/comment:3.0
docker run -d --network=reddit -p 9292:9292 ivb/ui:3.0
```
   - create different subnetworks:
``` 
> docker network create back_net --subnet=10.0.2.0/24
> docker network create front_net --subnet=10.0.1.0/24
```
   - then run the containers within the subnetworks :
```
> docker run -d --network=front_net -p 9292:9292 --name ui <your-login>/ui:1.0
> docker run -d --network=back_net --name comment <your-login>/comment:1.0
> docker run -d --network=back_net --name post <your-login>/post:1.0
> docker run -d --network=back_net --name mongo_db \
--network-alias=post_db --network-alias=comment_db mongo:latest

   - to fix the connection error "post" and "comment" containers were connected to front_net subnet. It allowed them to resolve the issue of interaction with ui container `> docker network connect <network> <container>`:
> docker network connect front_net post
> docker network connect front_net comment
```
  - bridge-utils package was installed on docker-host to show configuration info of bridges and veth-interfaces:
```
> docker-machine ssh docker-host
> sudo apt-get update && sudo apt-get install bridge-utils
> brctl show <interface>
```
`> sudo iptables -nL -v -t nat` - shows iptables info. POSTROUTING and DNAT chains were in our focus.

 - [x] installed docker-compose  
 - [x] assebmled reddit application images with help of docker-compose
 - [x] run reddit application using docker-compose
 - [x] modify docker-compose.yml so as to provide possibility to parameterize port of UI service, networks aliases, service versions and some other options usin an .env file. 

**Regarding the project naming logic:**
  The default project name is the basename of the project directory. You can set a custom project name by using the -p command line option or the COMPOSE_PROJECT_NAME environment variable. For more ditails [see this](https://docs.docker.com/compose/reference/envvars/#compose-project-name) or [this](https://docs.docker.com/compose/#multiple-isolated-environments-on-a-single-host)

 - [x] extra task with (*): create a docker-compose.override.yml and provide the possibility to modify the code on the fly. Puma appliction shuold be run in debug mode and with two workers.
Differences between "volumes" and "bind mount" approach is described [there](https://docs.docker.com/storage/volumes/) 
The new <volumes> key mounts the project directory (microservices directory) on the host to /app inside the container, allowing us to modify the code on the fly, without having to rebuild the image.


## Homework #15 (-4 branch)

 - create vm instance via gcloud compute command group:
```
$ gcloud compute --project=docker-250311 instances create gitlab-ci --zone=us-central1-a --machine-type=n1-standard-1 --subnet=default --network-tier=STANDARD --maintenance-policy=MIGRATE --service-account=613343191311-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server --image=ubuntu-1604-xenial-v20190816 --image-project=ubuntu-os-cloud --boot-disk-size=100GB --boot-disk-type=pd-standard --boot-disk-device-name=gitlab-ci --reservation-affinity=any

$ gcloud compute --project=docker-250311 firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

$ gcloud compute --project=docker-250311 firewall-rules create default-allow-https --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:443 --source-ranges=0.0.0.0/0 --target-tags=https-server
to remove instance run the command:
$ gcloud compute instances delete gitlab-ci

```

then install Docker and docker-machine using ansible or manually
For manual installation use this commands set:
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ apt-get update
$ apt-get install docker-ce docker-compose
```
or use docker-machine:
``` 
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-subnet=default \
--google-disk-size=100GB --google-disk-type=pd-standard \
--google-zone us-central1-a \
--google-project docker-250311 \
gitlab-ci
```
 - create docker-compose.yml in /srv/gitlab folder to prepare the environment for GitlabCI. Content for docker-compose file can be obrained from this [resource](https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose) 


 - register 1-st "my-runner":
 ```
 docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
 - after running it's needed to register my-runner:
 ----------------------------------------------------
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=20 revision=a987417a version=12.2.0
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://35.208.30.171/
Please enter the gitlab-ci token for this runner:
4wusEQuUdkJsm4TkFPQ9
Please enter the gitlab-ci description for this runner:
[8c73878a4efb]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=4wusEQuU
Please enter the executor: custom, docker-ssh, shell, virtualbox, docker-ssh+machine, kubernetes, docker, parallels, ssh, docker+machine:
docker
Please enter the default Docker image (e.g. ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
 ```
 - added reddit application tests in .gitlab-ci.yml
 - added dev-environment 
 