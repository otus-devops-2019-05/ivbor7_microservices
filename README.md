# ivbor7_microservices
ivbor7 microservices repository

## Table of Contents:

- [HW#12 (docker-2): branch: TravisCI, Docker, Docker-compose](./README.md#homework-12)
- [HW#13 (docker-3): branch: Microservices](./README.md#homework-13)
- [HW#14 (docker-4): Docker network](./README.md#homework-14)
- [HW#15 (docker-5) GitlabCI arrangement](./README.md#homework-15)
- [HW#16 (monitoring-1): Introduction to monitoring systems](./README.md#homework-16)
- [HW#17 (monitoring-2): Application and Infrastructure monitoring](./README.md#homework-17)
- [HW#18 (logging-1): Logging and disributed tracing](./README.md#homework-18)
- [HW#19 (kubernetes-1): Introduction to Kubernetes](./README.md#homework-19)
- [HW#20 (kubernetes-2): Launch Cluster, Application. Security Model](./README.md#homework-20)
- [HW#21 (kubernetes-3): Kubernetes: Networks, Storages](./README.md#homework-21)

## Homework #12
(docker-2 branch)

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
docker images -f dangling=true -q | xargs docker rmi  # deletes images with no label and no running container
docker service create --replicas 1 --name my-prometheus \
    --mount type=bind,source=/tmp/prometheus.yml,destination=/etc/prometheus/prometheus.yml \
    --publish published=9090,target=9090,protocol=tcp \
    prom/prometheus                       # add service with single replica

docker service create \
  --replicas 10 \
  --name ping_service \
  alpine ping docker.com                  # add service with 10 tasks that just ping docker.com non-stop 

docker service remove ping_service        # stop and remove the ping_service service,
 ```

**Image testing**
> [goss](https://github.com/aelsabbahy/goss) - утилита для тестирования инфраструктуры

> [dgoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) - обертка на bash, запускающая 
контейнер из данного образа и выполняющая тесты

> [Container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) от Google

 [Top 15 Docker Commands – Docker Commands Tutorial](https://www.edureka.co/blog/docker-commands/)
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

```sh
#
# export GOOGLE_PROJECT=docker-250311
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

```sh
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

## Homework #13
(docker-3 branch)

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


## Homework #14
(docker-4 branch)

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

## Homework #15
(gitlab-ci-1 branch)

 - create vm instance via gcloud compute command group:

```sh
$ gcloud compute --project=docker-250311 instances create gitlab-ci \
--zone=us-central1-a \
--machine-type=n1-standard-1 \
--subnet=default --network-tier=STANDARD \
--maintenance-policy=MIGRATE \
--service-account=613343191311-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=http-server,https-server \
--image=ubuntu-1604-xenial-v20190816 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=100GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=gitlab-ci

 - create the firewall rules for http(s) access:
------------------------------------------------

$ gcloud compute --project=docker-250311 firewall-rules create default-allow-http \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=http-server

$ gcloud compute --project=docker-250311 firewall-rules create default-allow-https \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:443 \
--source-ranges=0.0.0.0/0 \
--target-tags=https-server

and run docker and docker-compose installation using ansible:
------------------------------------------------------------
`$ ansible-playbook playbooks/docker-setup.yml -i dyninv.gcp.yml`

to remove instance run the command:
-----------------------------------
`$ gcloud compute instances delete gitlab-ci # remove GCP instance`
```

Then install Docker and docker-machine using ansible or manually.
For manual installation use this commands set:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-compose
```

or use docker-machine:

```sh 
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-subnet=default \
--google-disk-size=100GB --google-disk-type=pd-standard \
--google-zone us-central1-a \
--google-project docker-250311 \
gitlab-ci
```
 - create docker-compose.yml in /srv/gitlab folder to prepare the environment for GitlabCI. 
Content for docker-compose file can be obtained from this [resource](https://docs.gitlab.com/omnibus/docker/README.html#install-gitlab-using-docker-compose) 
 - register 1-st "my-runner"([Regestring runners](https://docs.gitlab.com/runner/register/)):
```
 docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest

```

[One-line registration command](https://docs.gitlab.com/runner/register/#one-line-registration-command):

```sh
$ sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "docker,aws,linux,xenial,ubuntu,docker" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
```

and case when Runner is running in Docker-container:

```sh
$ docker run --rm -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register \
  --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url "https://gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --description "docker-runner" \
  --tag-list "docker,aws,linux,xenial,ubuntu,docker" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"
```

 - after running it's needed to register my-runner:

```bash
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=20 revision=a987417a version=12.2.0
Running in system-mode.
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://35.208.30.171/
Please enter the gitlab-ci token for this runner:
4wuersUSUdkJsm5TkFR1O
Please enter the gitlab-ci description for this runner:
[8c73878a4efb]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=4wuersUS
Please enter the executor: custom, docker-ssh, shell, virtualbox, docker-ssh+machine, kubernetes, docker, parallels, ssh, docker+machine:
docker
Please enter the default Docker image (e.g. ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

 - added reddit application tests in .gitlab-ci.yml
 - added dev-environment to deploy our application after each commit 
 - added two additional stages: stage и production, for deploying the application:
   - in manual mode:
```
staging:
  stage: stage
  when: manual
```

- added version filter semver-tag as a deployment restriction on stage and production envs:

```yml
staging:
  stage: stage
    when: manual
    only:
      - /^\d+\.\d+\.\d+/
```

in such case, only the commit marked with tag with version number will run the full pipline:

```sh
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```

 - added job for creating the dynamic environment for any branch except the master:

```yml
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master
```

Useful links:
[GitLab CI/CD Examples](https://docs.gitlab.com/ee/ci/examples/)
[How To Build Docker Images and Host a Docker Image Repository with GitLab](https://www.digitalocean.com/community/tutorials/how-to-build-docker-images-and-host-a-docker-image-repository-with-gitlab)
[Registering Runners](https://docs.gitlab.com/runner/register/)
[The official way of deploying a GitLab Runner instance into your Kubernetes cluster](https://docs.gitlab.com/runner/install/kubernetes.html)
[Cofiguring GitLab Runner](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)
[How to build multiple docker containers with GitLab CI](https://stackoverflow.com/questions/50683869/how-to-build-push-and-pull-multiple-docker-containers-with-gitlab-ci)
[TOML - ](https://github.com/toml-lang/toml)
[Best practices for building docker images with GitLab CI](https://blog.callr.tech/building-docker-images-with-gitlab-ci-best-practices/)

## Homework #16
(monitoring-1 branch)

Within the hw#16 the following tasks were done:
 - Prometheus: run, configure and familiarity with Web UI
 - Monitoring the microservices state
 - Collecting hosts metrics using the exporter 
 - Extra tasks with (*)

 Firewall rules for Prometheus and Puma:

```sh
$ gcloud compute firewall-rules create prometheus-default --allow tcp:9090
$ gcloud compute firewall-rules create puma-default --allow tcp:9292
```

Create a Docker host in DCE:

```sh
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-project docker-250311 \
docker-host
```

configure local env for prometheus, cd to monitoring and switch to docker-host:
`eval $(docker-machine env docker-host)`

Run Prometheus monitoring system in Docker container:

```sh
$ docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus:v2.1.0
$ docker-machine ip docker-host
35.187.69.99
$ docker stop prometheus
```

 - Repos structure: docker-monolith folder, .env, docker-compose.* was sreamlined for subsequent monitoring

```sh
 rename {src => docker}/.env.example (100%)
 rename {src => docker}/docker-compose.override.yml (100%)
 rename {src => docker}/docker-compose.yml (100%)
 rename {docker-monolith => docker/docker-monolith}/Dockerfile (100%)
 rename {docker-monolith => docker/docker-monolith}/db_config (100%)
 rename {docker-monolith => docker/docker-monolith}/docker-1.log (100%)
 rename {docker-monolith => docker/docker-monolith}/mongod.conf (100%)
 rename {docker-monolith => docker/docker-monolith}/start.sh (100%)
```

The entire configuration of Prometheus, unlike many other monitoring systems going through 
configuration files and command line options.
- assemble the Prometheus image :

```sh
export USER_NAME=username
docker build -t $USER_NAME/prometheus .
```

then build images for each microservice in their folders:
`for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done`
All this images contain healthcheck inside that checks if the services are alive
Running the docker-compose we've encountered an issue connected with network name generating.
The network that docker-compose creates for us has a funky name. It takes the name of the current directory and then concatenates it with the service name, and then an index. This will break things.

- [x] added node-exporter into docker container to collect info regarding Docker itself
- [x] all created images were pushed to docker registry, available at this [link](https://cloud.docker.com/u/ivbdockerhub/repository/list)

- [x] - extra task with (*): monitoring MongoDB using the exporter. 
[Exporters and Integrations](https://prometheus.io/docs/instrumenting/exporters/). There are a lot of libraries and servers which help in exporting existing metrics from third-party systems as Prometheus metrics. As for [MongoDB Exporter](https://github.com/dcu/mongodb_exporter) it's not supported for now. So, I've used [Percona MongoDB exporter](https://github.com/percona/mongodb_exporter) Based on MongoDB exporter by David Cuadrado (@dcu), but forked for full sharded support and structure changes.

Assemble the docker image based on official image:

```bash
git clone git@github.com:percona/mongodb_exporter.git && rm -rf ./mongodb_exporter/.git && cd  mongodb_exporter/
docker build -t ivbdockerhub/mongodb-exporter:1.0 .
docker push $USER_NAME/mongodb-exporter
```

The following options may be passed to the [mongodb:metrics](https://libraries.io/github/percona/mongodb_exporter) monitoring service as additional options within the compose file:

```bash
--mongodb.uri=mongodb://root:example@mongodb:27017 
--groups.enabled 'asserts,durability,background_flusshing,connections,extra_info,global_lock,index_count'
--restart=always'
--collect.database
```

mongodb_extra_info_page_faults_total comes from "extra_info" group, which is governed by the `-groups.enabled` option
the following code added into docker-compose.yml:

```yml
  mongodb-exporter:
    hostname: mongodb-exporter
#   build: .
    image: ivbdockerhub/mongodb-exporter:1.0
    command:
      - '--mongodb.uri=mongodb://post_db:27017'
#      - '--groups.enabled=asserts,durability,background_flusshing,connections,extra_info,global_lock,index_counters,network,op_counters,op_counters_repl,memory,locks,metri$
      - '--collect.collection'
      - '--collect.database'
    restart: always
    ports:
      - 9216:9216
    networks:
      - ${NETW_BACK}
```

In Promethteus's config file promtheus.yml additional job 'mongodb-exporter' was added:

```yml
  - job_name: 'mongodb-exporter'
    static_configs:
      - targets: ['mongodb-exporter:9216']
```

after this rebuild docker image for Prometheus: `docker build -t $USER_NAME/prometheus .`
Then run monitoring in docker container from the docker folder: `docker-compose up -d`

To calculate how many containers are present and running execute these commands:

```bash
$ docker ps | sed -n '1!p'| /usr/bin/wc -l | sed -ne 's/^/node_docker_containers_running_total /p'
node_docker_containers_running_total 7
$ docker ps -a | sed -n '1!p'| /usr/bin/wc -l | sed -ne 's/^/node_docker_containers_total /p'
node_docker_containers_total 7
```

run the docker-compose: `docker-compose up -d`
mongodb_up and mongodb_network_bytes_total metrics were analyzed during switching the post_db service

- [x] extra task with (*): use Blackbox Exporter for services monitoring Prometheus [this example of code](https://kamaok.org.ua/?p=3090) might be useful.

Configure docker-compose by adding the blackbox service:

```yml
  blackbox-exporter:
    hostname: blackbox-exporter
    image: prom/blackbox-exporter:latest
    volumes:
      - '../monitoring/exporters/blackbox-exporter:/config'
    command:
      - '--config.file=/etc/blackbox_exporter/config.yml'
    ports:
      - '9115:9115'
    networks:
      - ${NETW_FRONT}
      - ${NETW_BACK}
```

Add new target to prometheus.yml:

```yml
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://ui:9292
        - http://post:5000
        - http://comment:9292
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115  # The blackbox exporter's real hostname:port.
```

Note: don't forget to rebuild the promethteus image: `monitoring/prometheus $ docker build -t $USER_NAME/prometheus .`

Push assembled images to the Docker Registry:
`$ docker login; for i in ui post comment prometheus mongodb_exporter; do docker push $USER_NAME/$i:latest; done`

- [x] extra task with (*): develop the Makefile that can build any or all images and push them to the docker registry.
Usage:
  $ make microservices - to build reddit's microservices images
  $ make monitoring - to build monitoring images (prometheus, exporters)
  $ make push-microservices - pushing created microservices images to Docker Registry 
  $ make push-monitoring - pushing created images for monitoring to Docker Registry

Links to additional information: 
  - [GNU make rus](http://www.linuxlib.ru/prog/make_379_manual.html)
  - [GNU make en](http://www.gnu.org/software/make/manual/make.html)
  - [GNU make: Constructed Macro Names](http://make.mad-scientist.net/constructed-macro-names/)
  - [Docker & Makefile](https://itnext.io/docker-makefile-x-ops-sharing-infra-as-code-parts-ea6fa0d22946)
  - [Makefile to build, run, tag and publish a docker containier](https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db)
  - [Configuring Kubernetes Deployments With Makefiles and Envsubst](https://blog.zikes.me/post/config-k8s-with-make/)
  - [Makefile for your dockerfiles](https://philpep.org/blog/a-makefile-for-your-dockerfiles)

_IMPORTANT NOTE:_ before running Makefile, it's necessary to rename Madefile to Makefile in microservices' folders src/ui|comment|post-py

## Homework #17
(monitoring-2 branch)

- Docker containers monitoring
- Metrics visualization
- Collecting application metrics and business metrics
- Configuring and checking of alert service
- Extra tasks with (*)

Bring up the docker-host using gcloud and docker-machine:

```sh
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-project docker-250311 \
docker-host
```

Get the Docker Engine parameters to connect Docker Client to Engine:

```sh
docker-machine env docker-host
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://35.195.24.226:2376"
export DOCKER_CERT_PATH="/home/ivbor/.docker/machine/machines/docker-host"
export DOCKER_MACHINE_NAME="docker-host"
# Run this command to configure your shell: 
# eval $(docker-machine env docker-host)
```

switch to docker-host:

```sh
$ eval $(docker-machine env docker-host)
$ docker-machine ip docker-host
35.195.24.226
```

To monitor a state of docker containers we'll use [cAdvisor](https://github.com/google/cadvisor) 
cAdvisor collect the following information from containers:
 - the % of CPU, RAM using
 - network traffic etc.

Split the microservices and monitoring configurations on separate compose files and check it then:

```sh
docker-compose -f docker-compose.yml config
docker-compose -f docker-compose-monitoring.yml config
```

add firewall rule for cAdvisor service:
`gcloud compute firewall-rules create cadvisor-default --allow tcp:8080`

Add grafana monitoring service in docker-compose-monitoring.yml and don't forget add firewall rule for grafana:
`gcloud compute firewall-rules create grafana-default --allow tcp:3000`

Without stopping the container, run a separate container with grafana service:
`docker-compose -f docker-compose-monitoring.yml up -d grafana`

As Gafana support work with Prometheus out of box, all we need to do after running container is click the "Add data source" button on Grafana WI and choose Prometheus.

For alerting service we use [Alertmanager integration with Prometheus](https://medium.com/@abhishekbhardwaj510/alertmanager-integration-in-prometheus-197e03bfabdf) provided by Prometheus. For this purpose the monitoring/alertmanager folder with appropriate config file (config.yml) and Dockerfile were created. To post messages from external sources into Slack channel configure an [Incoming Webhooks](https://devops-team-otus.slack.com/apps/A0F7XDUAZ-incoming-webhooks?page=1).
Slack Integration checking: `curl -X POST --data-urlencode "payload={\"channel\": \"#ivan_boriskin\", \"username\": \"webhookbot\", \"text\": \"This is posted to #ivan_boriskin and comes from a bot named webhookbot.\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/<slack_token>` 
Build docker image for Alertmanager: monitoring/alertmanager `$ docker build -t $USER_NAME/alertmanager .`
and add this service to docker-compose-monitoring.yml in one network with Prometheus:

```yml
alertmanager:
  image: ${USER_NAME}/alertmanager
  command:
    - '--config.file=/etc/alertmanager/config.yml'
  ports:
    - 9093:9093
  networks:
    backend_net:
      aliases:
        - prometheus_net
```
In monitoring/prometheus/alerts.yml we describe rules and conditions for alert triggering and sending a message to Alertmanager:

```yml
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```

Inform Prometheus regarding the Alertmanager's location and alerting conditions by adding two sections in prometheus.yml:

```yml
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
      - targets:
        - "alertmanager:9093"
```

Config.yml file will be inserted into Alertmanager container via Dockerfile during image building. Alerting described in alert.yml will be added in Prometheus image via prometheus/Dockerfile:

```yml
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
ADD alerts.yml /etc/prometheus/
```

All generated images were pushed to the [Docker regestry](https://cloud.docker.com/u/ivbdockerhub/repository/list):
`for i in ui post comment prometheus alertmanager; do docker push $USER_NAME/$i:latest; done`


### Extra tasks:

#### with (*):
- [x] - Update Makefile. Add working with images for monitoring services 
- [x] - Add experimental feature that allows the [Docker metrics to be exported](https://docs.docker.com/config/thirdparty/prometheus/) using the Prometheus syntax. See an example [how to collect Docker daemon metrics](https://ops.tips/gists/how-to-collect-docker-daemon-metrics/) You can try to integrate the docker metrics locally on Docker-machine or with help [Katacoda browser based hands on lab](https://www.katacoda.com/courses/prometheus/docker-metrics). In case of GCP, once running the instance with docker onboard, connect to the docker host via ssh `docker-machine ssh docker-host` and take the following steps:

 1. The command below will update the systemd configuration used to start Docker to set the flags when the daemon starts and then restarts Docker.

```sh
sudo echo -e '{\n  "metrics-addr" : "0.0.0.0:9323",\n  "experimental" : true\n}' | sudo tee /etc/docker/daemon.json && sudo systemctl restart docker
```

or one-line command:

```sh
docker-machine ssh docker-host "sudo echo -e '{\\n  \"metrics-addr\" : \"0.0.0.0:9323\",\\n  \"experimental\" : true\\n}' | sudo tee /etc/docker/daemon.json && sudo systemctl restart docker"
```

add firewall rule: `gcloud compute firewall-rules create docker-metrics-default --allow tcp:9323`
checking: `curl <ip-docker-host>|localhost:9323/metrics`

 2. Defines in prometheus.yml the intervals, the servers and ports that Prometheus should scrape data from:

```yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'docker-host'

    static_configs:
      - targets: ['<ip-docker-host>:9323']
      # or locally ['127.0.0.1:9090', '127.0.0.1:9100', '127.0.0.1:9323']
        labels:
          group: 'docker-host'
```

More information on the default ports can be found [here](https://github.com/prometheus/prometheus/wiki/Default-port-allocations) 

docker run -d --net=host \
    -v /root/prometheus.yml:/etc/prometheus/prometheus.yml \
    --name prometheus-server \
    prom/prometheus

 3. Launch the Node Exporter container. By mounting the host /proc and /sys directory, the container has accessed to the necessary information to report on.

```sh
docker run -d \
  -v "/proc:/host/proc" \
  -v "/sys:/host/sys" \
  -v "/:/rootfs" \
  --net="host" \
  --name=prometheus \
  quay.io/prometheus/node-exporter:v0.13.0 \
    -collector.procfs /host/proc \
    -collector.sysfs /host/sys \
    -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
```

Running additional containers will result in changes to the metrics produced, which are viewable via the graphs and queries.
`docker run -d katacoda/docker-http-server:latest`

So, cAdvisor collects, aggregates, processes and exports information about running containers. While Docker daemon by itself can be monitored with help of Docker metrics. In turn, it's number in comparison with cAdvisor is not so diverse and numerous.
To visualise the collected docker-host metrics Grafana with [daemon-metrics.json - dashboard](https://github.com/cirocosta/sample-collect-docker-metrics) was used.

- [x] - Use InfluxDB Telegraf to collect metrics from docker daemon.
 1. [Configure Telegraf](https://docs.influxdata.com/telegraf/v1.7/administration/configuration/) using the following instructions [Input plugin](https://docs.influxdata.com/telegraf/v1.7/plugins/inputs/) and [Output plugin](https://docs.influxdata.com/telegraf/v1.7/plugins/outputs/) 
 As telegraf will collect metrics from [Docker daemon](https://docs.docker.com/engine/api/v1.20/) we need the input plugin configured, and to expose all this one to be polled by Prometheus - need to be configured the output plugin. See the examples of configuring the [Input plugin for Docker daemon](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker) and [Output plugin for Prometheus](https://github.com/influxdata/telegraf/tree/master/plugins/outputs/prometheus_client)
Thus the telegraf.conf is as follows:

```cnf
[[inputs.docker]]
  ## Docker Endpoint
  ##   To use TCP, set endpoint = "tcp://[ip]:[port]"
  ##   To use environment variables (ie, docker-machine), set endpoint = "ENV"
  endpoint = "unix:///var/run/docker.sock"


[[outputs.prometheus_client]]
  ## Address to listen on.
  listen = ":9273"

## If set, the IP Ranges which are allowed to access metrics.
  ##   ex: ip_range = ["192.168.0.0/24", "192.168.1.0/30"]
  ip_range = ["10.0.1.0./24","10.0.2.0/24"]

 ## Path to publish the metrics on.
  path = "/metrics"

```

also add telegraf job to prometheus.yml:

```yml
  - job_name: 'telegraf'
    scrape_interval: 5s
    static_configs:
      - targets: ['telegraf:9273']
```

Then add telegraf container to the docker-compose-monitoring.yml:

```cnf
  telegraf:
    image: ${USER_NAME}/telegraf
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
    networks:
      backend_net:
        aliases:
          - prometheus_net
```
 - [x] configure the Alertmanager integration with email notification along with notifications to slack.
For training we can use free temporary smtp service [Temp Mail](https://rapidapi.com/Privatix/api/temp-mail) also known as: tempmail, 10minutemail, throwaway email, fake-mail or trash-mail(can be filtered by antyspam). Or get free account at [Mailjet](https://www.mailjet.com/pricing/) or at [Mailtrap](https://mailtrap.io/)

Added two parameters to alerts.yml with different alert level "warning" send to mail and "critical" will be sent to slack and mail:

```yml
  - name: FDLimits
    rules:
    - alert: ProcessNearFDLimits
      expr: process_open_fds / process_max_fds > 0.8    # for checking replace process_open_fds with 1040000
      for: 10m
      labels:
        severity: critical
      annotations:
        description: 'On {{ $labels.instance }} of job {{ $labels.job }} is reaching the open file limit'
        summary: 'On Instance {{ $labels.instance }} too many files are opened'
  
  - name: ResponseTimeLatency
    rules:
    - alert: Response time exceeded 0.2 threshold
      expr: histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[1m])) by (le)) > 0.2
      for: 15s
      labels:
        severity: warning
      annotations:
        description: 'On {{ $labels.instance }} of job {{ $labels.job }} the high latency of response '
        summary: 'The high latency of responce on Instance {{ $labels.instance }} '
```
The appropriate settings made in Alertmanager's config.yml to react on alerts, outlined above.

Several related links: 
 - [Sending alert notifications to multiple destinations](https://www.robustperception.io/sending-alert-notifications-to-multiple-destinations)
 
 - [Setting up Prometheus alerts](https://0x63.me/setting-up-prometheus-alerts/)


## Homework #18
(logging-1 branch)

Within the hw#18 the following tasks were done:
 - unstructured logs collecting
 - logs visualization using Kibana
 - structured logs collecting using Fluentd  
 - distributed tracing
 - Extra tasks with (*)

The standart ELK includes: ElasticSearch, Logstash, Kibana. We will change it a bit and replace the Logstash with Fluentd, as a result we'll obtain EFK tools set.

#### Create GCP VM:

```sh
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-project docker-250311 \
--google-machine-type n1-standard-1 \
--google-open-port 5601/tcp \
--google-open-port 24224/tcp,24224/udp \
--google-open-port 9292/tcp \
--google-open-port 9411/tcp \
logging
```

#### Login to DockerHub: `sh docker login`

#### Build microservice's images - separate parts of Reddit application:

```sh
for i in ui comment; do cd src/$i; docker build -t $USER_NAME/$i:logging . && docker push $USER_NAME/$i; cd -; done`

cd src/post-py/; docker build -t $USER_NAME/post:logging . && docker push $USER_NAME/post; cd -; done
```

#### Switch to remote docker-machine env "logging":
`eval $(docker-machine env logging)`

#### checking the environment and image availability:

```sh
env | grep DOCKER
docker images
```

#### build Fluentd image for our centralized logging service
`cd logging/fluentd/ && docker build -t $USER_NAME/fluentd . && docker push $USER_NAME/fluentd && cd -`

#### Edit the .env file and replace Tag=latest witg Tag=logging

#### Run application's services:
`docker/ $ docker-compose up -d`

Fluentd serves for aggregation and transformation of logs in one place. To send the collected logs to Fluentd define the driver for logging in docker/docker-compose.yml:

```yml 
:docker/docker-compose.yml
...
post:
...
logging:
  driver: "fluentd"
  options:
    fluentd-address: localhost:24224
    tag: service.post
```

#### Build the fluentd image:

```sh
echo $USER_NAME
docker build -t $USER_NAME/fluentd . && cd -
cd docker/
docker-compose up -d
docker-compose logs -f post
```

#### Bring up logging center:

`$ docker-compose -f docker-compose-logging.yml up -d`

Error arised:
> Kibana server is not ready yet

Kibana log shows that elasticsearch has "No living connections":
> $ docker logs f2d6c0e6a96a 
> {"type":"log","@timestamp":"2019-09-16T07:04:58Z","tags":["warning","elasticsearch","admin"],"pid":1,"message":"No living connections"}

As Kibana depends on [The Elastic Stack, on Docker](https://github.com/elastic/stack-docker) add this dependency in compose file for Kibana service:
 `depends_on: ['elasticsearch']`

But it's not enough. Let's see ES startup log:

```sh
$ docker logs 6981964880e8
> [2019-09-16T09:06:03,704][INFO ][o.e.b.BootstrapChecks    ] [Trm8hlu] bound or publishing to a non-loopback address, enforcing bootstrap checks
ERROR: [1] bootstrap checks failed
[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

Apparently we've faced with known [Virtual memory issue](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html) also might be useful [Important Elasticsearch configuration](https://www.elastic.co/guide/en/elasticsearch/reference/master/important-settings.html) and [Elasticsearch is not starting](https://elk-docker.readthedocs.io/#es-not-starting-max-map-count)

Fix:

```sh
Temporary:
docker-machine ssh
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -p
or Permament:
In your host machine
  vi /etc/sysctl.conf
  make entry vm.max_map_count=262144
restart
```

Structured logs should have a single structure and format so as not to waste time and system resources on data conversion. 

Tune parsing for post and ui service  using the Grok pattern instead regexp:

```yml
<filter service.ui>
  @type parser
#  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=$
  format grok
  grok_pattern %{RUBY_LOGGER}
  key_name log
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>
```
 
 - [x] extra task with (*):

Here is the basic syntax format for a Logstash grok filter:

> %{PATTERN:FieldName}

For the convenience of writing a pattern use the [Grok Debugger](https://grokdebug.herokuapp.com/)
The following pattern was added to parse a log snippet that remained unparsed after previous two steps:

```yml
<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{UNIXPATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IPV4:remote_addr} \| method=%{DATA:method} \| response_status=%{NONNEGINT:response_status}
  key_name message
</filter>
```

Tracing report:

```sh
Services: ui_app
Date Time 	Relative Time 	Annotation 	Address
17/09/2019, 01:13:42 		Server Start 	10.0.2.2:9292 (ui_app)
17/09/2019, 01:14:15 	33.080s 	Server Finish 	10.0.2.2:9292 (ui_app)

post./post/<id>: 3.031s
Services: post,ui_app
Date Time 	Relative Time 	Annotation 	Address
17/09/2019, 01:13:42 	1.623ms 	Client Start 	10.0.2.2:9292 (ui_app)
17/09/2019, 01:13:42 	4.452ms 	Server Start 	10.0.1.4:5000 (post)
17/09/2019, 01:13:45 	3.025s 	Server Finish 	10.0.1.4:5000 (post)
17/09/2019, 01:13:45 	3.032s 	Client Finish 	10.0.2.2:9292 (ui_app)

 - !!!the weak link in our chain:!!!
-------------------------------------
post.db_find_single_post: 3.006s
Services: post
Date Time 	Relative Time 	Annotation 	Address
17/09/2019, 01:13:42 	4.562ms 	Client Start 	10.0.1.4:5000 (post)
17/09/2019, 01:13:42 	4.562ms 	Server Start 	10.0.1.4:5000 (post)
->17/09/2019, 01:13:45 	3.010s 	Client Finish 	10.0.1.4:5000 (post)
------------------------------------------------------------------
17/09/2019, 01:13:45 	3.010s 	Server Finish 	10.0.1.4:5000 (post)

As we can see the most time is spent accessing the database. Obviously, the issue with response delay should be sought in the post service (post_app.py)

```py
# Retrieve information about a post
@zipkin_span(service_name='post', span_name='db_find_single_post')
def find_post(id):
    start_time = time.time()
...
    else:
        stop_time = time.time()  # + 0.3
        resp_time = stop_time - start_time
        app.post_read_db_seconds.observe(resp_time)
!!!!==> #time.sleep(3)                              <==!!!!
        log_event('info', 'post_find',
                  'Successfully found the post information',
                  {'post_id': id})
        return dumps(post)
```

After applying the fix:

```sh
post.db_find_single_post: 4.384ms
Services: post
Date Time 	Relative Time 	Annotation 	Address
17/09/2019, 01:47:24 	14.506ms 	Client Start 	10.0.1.4:5000 (post)
17/09/2019, 01:47:24 	14.506ms 	Server Start 	10.0.1.4:5000 (post)
17/09/2019, 01:47:24 	18.890ms 	Client Finish 	10.0.1.4:5000 (post)
17/09/2019, 01:47:24 	18.890ms 	Server Finish 	10.0.1.4:5000 (post)
```

## Homework #19
(kubernetes-1 branch)

Walking through the setting up [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way), the configuration files and certificates were generated
and placed into kubernetes/the_hard_way folder

The final tests shows that Kubernetes cluster is functioning correctly:

### Verification

- Check the health of the remote Kubernetes cluster:

```sh
$ kubectl get componentstatuses
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok                  
scheduler            Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"} 

$ kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   7m    v1.15.3
worker-1   Ready    <none>   7m    v1.15.3
worker-2   Ready    <none>   7m    v1.15.3
```


#### The Routing Table

- Print the internal IP address and Pod CIDR range for each worker instance:

10.240.0.20 10.200.0.0/24
10.240.0.21 10.200.1.0/24
10.240.0.22 10.200.2.0/24
```

[x] Routes

- Create network routes for each worker instance:

```sh
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
-----------
Created [https://www.googleapis.com/compute/v1/projects/docker-250311/global/routes/kubernetes-route-10-200-0-0-24].
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP     PRIORITY
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20  1000
Created [https://www.googleapis.com/compute/v1/projects/docker-250311/global/routes/kubernetes-route-10-200-1-0-24].
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP     PRIORITY
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21  1000
Created [https://www.googleapis.com/compute/v1/projects/docker-250311/global/routes/kubernetes-route-10-200-2-0-24].
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP     PRIORITY
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22  1000
=====================================================================================


 > List the routes in the kubernetes-the-hard-way VPC network:
--------------------------------------------------------------
$ gcloud compute routes list --filter "network: kubernetes-the-hard-way"
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-7cd470abdb670dc5  kubernetes-the-hard-way  0.0.0.0/0      default-internet-gateway  1000
default-route-d8ec0acb03d84d87  kubernetes-the-hard-way  10.240.0.0/24  kubernetes-the-hard-way   1000
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20               1000
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21               1000
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22               1000
```

[x] The DNS Cluster Add-on

- Deploy the coredns cluster add-on:

```sh
 $ kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
```

- List the pods created by the kube-dns deployment:

```sh
$ kubectl get pods -l k8s-app=kube-dns -n kube-system
NAME                     READY   STATUS    RESTARTS   AGE
coredns-5fb99965-h9dwt   1/1     Running   0          2m18s
coredns-5fb99965-p2rwn   1/1     Running   0          2m18s
```

## Verification

- Create a busybox deployment:

```sh
kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600
```

- List the pod created by the busybox deployment:

```sh
$ kubectl get pods -l run=busybox
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          47s
```

- Retrieve the full name of the busybox pod:

```sh
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

$ kubectl exec -ti $POD_NAME -- nslookup kubernetes
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

- Print a hexdump of the kubernetes-the-hard-way secret stored in etcd:

```sh
$ gcloud compute ssh controller-0 \
>   --command "sudo ETCDCTL_API=3 etcdctl get \
>   --endpoints=https://127.0.0.1:2379 \
>   --cacert=/etc/etcd/ca.pem \
>   --cert=/etc/etcd/kubernetes.pem \
>   --key=/etc/etcd/kubernetes-key.pem\
>   /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a bf e7 55 f0 32 30 e3  |:v1:key1:..U.20.|
00000050  15 82 e5 10 dd 1a bf 52  dc 86 c2 2e 94 28 27 f2  |.......R.....('.|
00000060  88 82 e2 14 7d 51 99 39  21 69 dc cb 11 38 f5 53  |....}Q.9!i...8.S|
00000070  94 b8 63 9e ed 71 09 a9  b3 3a 09 1a fe c7 58 79  |..c..q...:....Xy|
00000080  59 64 d5 44 71 4b 7a ec  d9 73 d2 9e b8 f9 95 c8  |Yd.DqKz..s......|
00000090  a0 ea 90 24 cb 35 b5 95  6e 48 57 e6 95 8b 09 4c  |...$.5..nHW....L|
000000a0  b0 1b 44 7a c5 c9 9b 16  39 fc 52 02 67 b6 a2 dc  |..Dz....9.R.g...|
000000b0  22 2c f2 27 f3 13 73 e0  63 97 d7 7f 2a 48 79 d6  |",.'..s.c...*Hy.|
000000c0  09 ba df 4a e5 50 38 ef  26 1d 22 f7 93 7a 0d 91  |...J.P8.&."..z..|
000000d0  a5 dd f9 61 e9 b2 75 17  3e db c8 09 a8 95 c1 03  |...a..u.>.......|
000000e0  64 50 43 96 13 a1 c3 6b  a9 0a                    |dPC....k..|
000000ea
```

The etcd key is prefixed with k8s:enc:aescbc:v1:key1, which indicates the aescbc provider was used to 
encrypt the data with the key1 encryption key.

- [x] Verify the ability to create and manage Deployments.

- Create a deployment for the nginx web server:
`kubectl create deployment nginx --image=nginx`

- List the pod created by the nginx deployment:

```sh
$ kubectl get pods -l app=nginx
NAME                     READY   STATUS    RESTARTS   AGE
nginx-554b9c67f9-ttqvm   1/1     Running   0          15s
```

- [x] Port Forwarding

```sh
$ kubectl port-forward $POD_NAME 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
-->Handling connection for 8080 <--
^C
```

 - at the same time in new terminal command output:

```sh
$ curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK                                                                             
Server: nginx/1.17.3                                                                        
Date: Wed, 18 Sep 2019 12:36:09 GMT                                                         
Content-Type: text/html                                                                     
Content-Length: 612                                                                         
Last-Modified: Tue, 13 Aug 2019 08:50:00 GMT                                                
Connection: keep-alive                                                                      
ETag: "5d5279b8-264"                                                                        
Accept-Ranges: bytes 
```

- [x] Logs

- Print `pod` pod logs:

```sh
$ kubectl logs $POD_NAME
127.0.0.1 - - [18/Sep/2019:12:36:09 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.47.0" "-"
```

- [x] Exec

- Print the nginx version by executing the nginx -v command in the nginx container:

```sh
$ kubectl exec -ti $POD_NAME -- nginx -v
nginx version: nginx/1.17.3
```

 - [x] Services

- Expose the nginx deployment using a NodePort service:

```sh
$ kubectl expose deployment nginx --port 80 --type NodePort

$ NODE_PORT=$(kubectl get svc nginx \
>   --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
ivbor@ivbor-nout ~/k8sthw $ gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
>   --allow=tcp:${NODE_PORT} \
>   --network kubernetes-the-hard-way

Creating firewall...⠏Created [https://www.googleapis.com/compute/v1/projects/docker-250311/global/firewalls/kubernetes-the-hard-way-allow-nginx-service].
Creating firewall...done.                                                                      
NAME                                         NETWORK                  DIRECTION  PRIORITY  ALLOW      DENY  DISABLED
kubernetes-the-hard-way-allow-nginx-service  kubernetes-the-hard-way  INGRESS    1000      tcp:32543        False
ivbor@ivbor-nout ~/k8sthw $ 
ivbor@ivbor-nout ~/k8sthw $ EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
>   --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
ivbor@ivbor-nout ~/k8sthw $ curl -I http://${EXTERNAL_IP}:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.17.3
Date: Wed, 18 Sep 2019 12:44:41 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 13 Aug 2019 08:50:00 GMT
Connection: keep-alive
ETag: "5d5279b8-264"
Accept-Ranges: bytes
```


## Cleaning UP

- [x] Compute Instances

Delete the controller and worker compute instances:

```sh
gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2 \
  --zone $(gcloud config get-value compute/zone)
```

 - [x] Networking

- Delete the external load balancer network resources:

```sh
{
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete kubernetes-the-hard-way
}
```

- Delete the kubernetes-the-hard-way firewall rules:

```sh 
gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external \
  kubernetes-the-hard-way-allow-health-check
```

- Delete the kubernetes-the-hard-way network VPC:

```sh
{
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete kubernetes-the-hard-way
}
```

Related links:
1. [kops - Kubernetes Operations](https://github.com/kubernetes/kops) - The easiest way to get a production grade Kubernetes cluster up and running.
2. [Развертывание Kubernetes кластера при помощи Rancher 2.0](https://www.youtube.com/watch?v=3NX40K9D6tk)
3. [Rancher 2.0](https://habr.com/ru/company/flant/blog/339120/)
4. [Rancher 2.0 Tech preview](https://www.youtube.com/watch?v=Ma6FsuWI2Nc)
5. [Provisioning Kubernetes using Terraform and Ansible - Sample](https://github.com/opencredo/k8s-terraform-ansible-sample)
6. [Kubernetes from scratch to AWS with Terraform and Ansible 3 parts](https://opencredo.com/blogs/kubernetes-aws-terraform-ansible-1/)
7. [Kubernetes Architecture](https://www.padok.fr/en/blog/kubernetes-architecture-clusters)
8. [Kubernetes configuration & Best Practices](https://bcouetil.gitlab.io/academy/BP-kubernetes.html)


## Homework #20

- [x] installed and checked the availability of [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) on host.

- Run Minikube-cluster(one-node cluster): `$ minikube start`
While the minicube was bringing up the kubctl config file ~/.kube/config was configured.
~/.kube/config - it's a place where cluster's context (user, cluster, namespace) is stored. It's also known as a kubernetes manifest. To run the application in kubernetes the target applicatio state should be described via CLI or in yaml-file called manifest.
Key section in context: 
 _user_ - username for connection to cluster
 _cluster_ - API server:
   - _server_ - kubernetes API server address 
   - _ certificate-authority_ - the root certificate the SSL-certificate on server itself is signed with
   - _name_ - the name for identification in config
 _namespace_ - visibility area (not mandatory)

To run kubernetes of certain version use flag --kubernetes-version <version> (v1.8.0)
As default hypervisor the VirtualBox is used, but you can use other hypervisor specify option --vm-driver=<hypervisor>

- Getting info about nodes: 

```sh
$ kubectl get nodes                                          
NAME       STATUS   ROLES    AGE     VERSION                                                    
minikube   Ready    <none>   6m59s   v1.15.2
```

The usual cluster setup order is as follow. In such way the kubctl is configured for connection to certain cluster:
1. Create cluster : `$ kubectl config set-cluster ... cluster_name`
2. Create user credentials: `$ kubectl config set-credentials ... user_name`
3. Create a context: 

```sh
$ kubectl config set-context context_name \
--cluster=cluster_name \
--user=user_name
```

4. Use the context: `$ kubectl config use-context context_name`

- get the current context: `$ kubectl config current-context`
- get the list of contexts: 

```sh 
$ kubectl config get-contexts                                
CURRENT   NAME                      CLUSTER                   AUTHINFO   NAMESPACE              
          kubernetes-the-hard-way   kubernetes-the-hard-way   admin      
*         minikube                  minikube                  minikube
```
- run ui component:

```sh
$ kubectl apply -f ui-deployment.yml 
deployment.apps/ui created
$ kubectl get deployment
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     0/3     3            0           107s
```

- delete ui component: 

```sh
$ kubectl delete -f ui-deployment.yml 
deployment.apps "ui-deployment" deleted
or 
$ kubectl delete service ui
```

- Get the addons list:

```sh

ivbor@ivbor-nout ~/Otus/ivbor7_microservices/kubernetes/reddit $ minikube addons list
- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- heapster: disabled
- ingress: disabled
- logviewer: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled
```

- enable the dashboard addons: `minikube addons enable dashboard`
- looking for ip:port of dashboard:
`kubectl get svc --namespace=kube-system`
or `kubectl get all -n kube-system --selector k8s-app=kubernetes-dashboard`
- run the dashboard:
`$ minikube service kubernetes-dashboard -n kube-system`
in my case it was: `minikube dashboard`

- get information about running services:

```sh
$ kubectl get svc --namespace=kube-system
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
kube-dns               ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   6h16m
kubernetes-dashboard   ClusterIP   10.107.54.145   <none>        80/TCP                   16m

 $ kubectl get svc -A
NAMESPACE     NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       comment                ClusterIP   10.108.131.239   <none>        9292/TCP                 7h56m
default       comment-db             ClusterIP   10.99.231.69     <none>        27017/TCP                7h56m
default       kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP                  7h58m
default       post                   ClusterIP   10.98.64.24      <none>        5000/TCP                 7h56m
default       post-db                ClusterIP   10.97.211.168    <none>        27017/TCP                7h56m
default       ui                     NodePort    10.105.215.8     <none>        9292:32092/TCP           161m
dev           comment                ClusterIP   10.110.208.1     <none>        9292/TCP                 21m
dev           comment-db             ClusterIP   10.102.71.101    <none>        27017/TCP                21m
dev           mongodb                ClusterIP   10.107.85.27     <none>        27017/TCP                21m
dev           post                   ClusterIP   10.96.44.13      <none>        5000/TCP                 21m
dev           post-db                ClusterIP   10.96.164.170    <none>        27017/TCP                21m
dev           ui                     ClusterIP   10.111.175.117   <none>        9292/TCP                 20m
kube-system   kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   7h58m
kube-system   kubernetes-dashboard   ClusterIP   10.107.54.145    <none>        80/TCP                   118m

Possible resources include (case insensitive):

pod (po), service (svc), replicationcontroller (rc), deployment (deploy), replicaset (rs)
```

```sh
$ minikube dashboard
* Verifying dashboard health ...
* Launching proxy ...
* Verifying proxy health ...
* Opening http://127.0.0.1:40101/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```


To access Reddit application from outside we need to adjust the network. Forward application 9292 port to host 8080 port:

```sh
kubectl get pods --selector component=ui
kubectl port-forward <pod-name> 8080:9292
```

Error arised:

```sh
kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS                 RESTARTS   AGE
default       comment-6c58c4f89-9dprq            0/1     ImagePullBackOff       0          5m20s
default       comment-6c58c4f89-l8pzn            0/1     ImagePullBackOff       0          5m20s
default       comment-6c58c4f89-v69zk            0/1     ImagePullBackOff       0          5m20s
```

[Kubernetes Troubleshooting](https://managedkube.com/kubernetes/k8sbot/troubleshooting/imagepullbackoff/2019/02/23/imagepullbackoff.html):

```sh
$ kubectl describe pod comment-6c58c4f89-9dprq
Name:           comment-6c58c4f89-9dprq
Namespace:      default
Priority:       0
Node:           minikube/10.0.2.15
Start Time:     Fri, 20 Sep 2019 23:20:44 +0300
Labels:         app=reddit
                component=comment
                pod-template-hash=6c58c4f89
. . .
Warning  Failed     8m14s                 kubelet, minikube  Failed to pull image "ivbdockerhub/comment": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 10.0.2.3:53: read udp 10.0.2.15:46194->10.0.2.3:53: i/o timeout
  Normal   BackOff    5m43s (x15 over 10m)  kubelet, minikube  Back-off pulling image "ivbdockerhub/comment"
  Warning  Failed     43s (x37 over 10m)    kubelet, minikube  Error: ImagePullBackOff
```

Fix: point your docker client to the VM's docker daemon by running:
`eval $(minikube docker-env)` or [Creating a Secret with Docker Config](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config)

One more error occurred after rebooting the PC:

```sh
> $ kubectl get nodes
> error: You must be logged in to the server (Unauthorized)
> $ kubectl config view --minify | grep /.minikube | xargs stat
> stat: cannot stat 'certificate-authority:': No such file or directory
>  File: '/home/ivbor/.minikube/ca.crt'
> ...
```

Fix: 
 - delete the cluster using `minikube delete`
 - Clear everything from the config:

```sh
kubectl config delete-context minikube
kubectl config delete-cluster minikube
kubectl config unset.users minikube
rm -rf ~/.kube/config
rm -rf ~/.minikube
```

- cascade the deletion of the resources managed by this resource (e.g. Pods created by a ReplicationController)

```sh
$ kubectl delete deployment --cascade=true --all=true
deployment.extensions "comment-deployment" deleted
deployment.extensions "post-deployment" deleted
```

 But that wasn't enough, nothing has helped. I've noticed that minikube was installed with root privileges: `sudo install minikube /usr/local/bin` and certificetes was generated by user ivbor:

```sh
ls -al /usr/local/bin/
total 273348
drwxr-xr-x  2 root  root       4096 Sep 21 22:07 .
drwxr-xr-x 10 root  root       4096 Nov 24  2017 ..
-rwxr-xr-x  1 root  root       6536 Feb  7  2019 apt
--> -rwxrwxr-x  1 ivbor ivbor  20574840 Sep 15 20:50 cfssl
--> -rwxrwxr-x  1 ivbor ivbor  12670032 Sep 15 20:51 cfssljson
-rwxr-xr-x  1 root  root   16168192 Aug 24 23:19 docker-compose
-rwxr-xr-x  1 root  root   28164576 Aug 19 15:00 docker-machine
-rwxr-xr-x  1 root  root        535 Jun 29 10:27 gnome-help
-rwxr-xr-x  1 root  root        196 Feb  7  2019 highlight
-rwxr-xr-x  1 root  root        498 Aug 19 10:03 launchy
--> -rwxrwxr-x  1 root  root   55869264 Sep 19 16:20 minikube
```

So, I've aligned the privileges of these binaries, recreated the cluster and have got an access to it.

It's happened again, containers do not start, the cluster stops responding and VM is getting stuck. 
Increasing memory allocated to the VM fixed the problem: `$ minikube config set memory 6000`

- point the labels for pods identification within the cluster:

```yml
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: ui
>>labels:
>>  app: reddit
>>  component: ui
spec:
  replicas: 3
  selector:
    matchLabels:
>>    app: reddit
>>    component: ui
  template:
    metadata:
      name: ui-pod
>>    labels:
>>      app: reddit
>>      component: ui
    spec:
      containers:
      - image: ivbdockerhub/ui:latest
        name: ui
```
 
- mount the standard volume to store the data outside the container: 

```yml
...
spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
```

- create the Service abstraction that describes the way of microservices interaction and as a policy by which to access the appropriate microservices within the cluster:

```yml
---
apiVersion: v1
kind: Service
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: comment
```

- Pods have to be found by given labels:

```sh
$ kubectl describe service comment | grep Endpoints`
Endpoints:         172.17.0.4:9292,172.17.0.5:9292,172.17.0.6:9292
```

- point the external port to access the application from outside using type NodePort instead of default ClusterIP type:

```yml
spec:
  type: NodePort
  ports:
  - nodePort: 32092
    port: 9292
. . .
```

$ kubectl exec -ti <pod-name> nslookup comment
nslookup: can't resolve '(null)': Name does not resolve

```sh
$ minikube service list
|-------------|------------|-----------------------------|
|  NAMESPACE  |    NAME    |             URL             |
|-------------|------------|-----------------------------|
| default     | comment    | No node port                |
| default     | comment-db | No node port                |
| default     | kubernetes | No node port                |
| default     | post       | No node port                |
| default     | post-db    | No node port                |
| default     | ui         | http://192.168.99.100:32092 |
| kube-system | kube-dns   | No node port                |
```

- add information about environment to ui-deployment.yml:

```yml
    ...
    spec:
      containers:
      - image: chromko/ui
        name: ui
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```

- add new namespace "dev" and run our reddit application in new namespace, changed the NodePort beforehand in order to resolve port conflict:

```sh
kubectl apply -f ui-service.yml -n dev
service/ui configured

$ kubectl get svc -A
NAMESPACE     NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       comment                ClusterIP   10.108.131.239   <none>        9292/TCP                 8h
default       comment-db             ClusterIP   10.99.231.69     <none>        27017/TCP                8h
default       kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP                  8h
default       post                   ClusterIP   10.98.64.24      <none>        5000/TCP                 8h
default       post-db                ClusterIP   10.97.211.168    <none>        27017/TCP                8h
--> default   ui                     NodePort    10.105.215.8     <none>        9292:32092/TCP           173m
dev           comment                ClusterIP   10.110.208.1     <none>        9292/TCP                 34m
dev           comment-db             ClusterIP   10.102.71.101    <none>        27017/TCP                34m
dev           mongodb                ClusterIP   10.107.85.27     <none>        27017/TCP                34m
dev           post                   ClusterIP   10.96.44.13      <none>        5000/TCP                 34m
dev           post-db                ClusterIP   10.96.164.170    <none>        27017/TCP                34m
-->dev        ui                     NodePort    10.111.175.117   <none>        9292:31092/TCP           33m
kube-system   kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   8h
kube-system   kubernetes-dashboard   ClusterIP   10.107.54.145    <none>        80/TCP                   130m
```

After checking if everything work well locally, we are ready to deploy our application on Google Kubernetes Engine.
Create Kubernetes Cluster :

- management components are running in Container Engine:
  - kube-apiserver
  - kube-scheduler
  - kube-controller-manager
  - etcd
- workloads are running on work nodes, they are standard nodes of the Google compute engine
  - addons
  - monitoring
  - logging
  - ingress backend
  - runtimes

Before proceeding with the deploy of the application we need to connect to our cluster in GKE:

```sh
$ gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a --project docker-250311
Fetching cluster endpoint and auth data.
kubeconfig entry generated for standard-cluster-1.
```

As a result the user, cluster and context will be added into ~/.kube/config it can be checked running the command:

```sh
$ kubectl config current-context
gke_docker-250311_us-central1-a_standard-cluster-1
```

Now create the Dev namespace: 

```sh
$ kubectl apply -f ./kubernetes/reddit/dev-namespace.yml 
namespace/dev created
```

then deploy all components of the Reddit application in namespace dev:

```sh
$ kubectl apply -f ./kubernetes/reddit/ -n dev
deployment.apps/comment created
service/comment-db created
service/comment created
namespace/dev unchanged
deployment.apps/mongo created
service/mongodb created
deployment.apps/post created
service/post-db created
service/post created
deployment.apps/ui created
service/ui created
```

Get External IP of cluster nodes:

```sh
$ kubectl get nodes -o wide
NAME                                                STATUS   ROLES    AGE   VERSION         INTERNAL-IP   EXTERNAL-IP    OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-standard-cluster-1-default-pool-75430a20-1xdk   Ready    <none>   16m   v1.13.7-gke.8   10.128.0.16   35.202.251.2   Container-Optimized OS from Google   4.14.127+        docker://18.9.3
gke-standard-cluster-1-default-pool-75430a20-cwl7   Ready    <none>   16m   v1.13.7-gke.8   10.128.0.15   34.66.62.2     Container-Optimized OS from Google   4.14.127+        docker://18.9.3
```

Look for the exposed port UI service: `$ kubectl describe service ui -n dev | grep -i nodeport`

```sh
 $ kubectl describe service ui -n dev | grep -i nodeport
Type:                     NodePort
NodePort:                 <unset>  31092/TCP
```

Now we can connect to our application by the link http://<node-ip>:<NodePort>

- [x] Add the [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) by enabling it in the cluster's Add-ons of the cluster properties.
Run proxy: `$ kubectl proxy`: > "Starting to serve on 127.0.0.1:8001" 
According to [Kubernetes Dashboard Web UI for k8s clusters](https://github.com/kubernetes/dashboard) run this link: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

However we can't access the service due to RBAC limitations. So, we should add cluster-admin role to kubernetes-dashboard service account using clusterrolebinding:

```sh
kubectl create clusterrolebinding kubernetes-dashboard \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:kubernetes-dashboard
```

Commands below allow to edit or take token for service-account:

```sh
$ gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a --project docker-250311 \
&& kubectl edit secret default-token-szvgq --namespace dev

$ gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a --project docker-250311 \
&& kubectl edit secret kubernetes-dashboard-token-jms2n --namespace dev
```

Gaining access to the cluster that is now created with the commands available is quick. The two commands execute as shown:
`gcloud container clusters get-credentials <account> --zone <us-west1-a> --project <project_name>`
and then:
`kubectl proxy`

As a workaround we can [skip the login process](https://devblogs.microsoft.com/premier-developer/bypassing-authentication-for-the-local-kubernetes-cluster-dashboard/), of course it can be applied only for the local cluster. So, add the following arguments in kubernetes-dashboard.yml:

```yml
--enable-skip-login
--disable-settings-authorizer
```


- [x] Extra task with (*): deploy Kubernetes cluster in GKE using Terraform. Create yaml-manifests for entities responsible for access to dashboard. 
As for dashboard yaml-manifests, thanks to google, original github [Kubernetes/dashboard](https://github.com/kubernetes/dashboard/blob/master/aio/test-resources/kubernetes-dashboard-local.yaml), ["The Kubernetes Authors"](https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml) and  also to [followers](https://github.com/rootsongjc/kubernetes-handbook/blob/master/manifests/dashboard-1.7.1/kubernetes-dashboard.yaml), everything is done before us.




Related links: 
1. [KIND - Kubernetes IN Docker - local clusters for testing Kubernetes](https://github.com/kubernetes-sigs/kind)
2. [10 Most Common Reasons Kubernetes Deployments Fail](https://kukulinski.com/10-most-common-reasons-kubernetes-deployments-fail-part-1/)
3. [Getting Started strong](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-strong-getting-started-strong-)
4. [Infrastructure as Code Examples](https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code)
5. [Kubernetes on Google Cloud Platform](https://www.padok.fr/en/blog/kubernetes-google-cloud-terraform-cluster)


## Homework #21

(kubernetes-3 branch)

Create the cluster in GKE and deploy the reddit aplication using manifests from pevious Homework #20.
Connect the cluster aftewards: 

```sh
$ gcloud beta container clusters get-credentials reddit-cluster --region us-central1 --project docker-250311
Fetching cluster endpoint and auth data.
kubeconfig entry generated for docker-250311-cluster
```

Create dev namespace: `kubectl apply -f kubernetes/reddit/dev-namespace.yml`
and deploy application: `kubectl apply -f kubernetes/reddit/ -n dev`


In case of Zonal Cluster created

```sh
$ gcloud container clusters get-credentials reddit-cluster --zone us-central1-a --project docker-250311
Fetching cluster endpoint and auth data.
kubeconfig entry generated for reddit-cluster
```


Tune the ui service adding Coogle cloud Load-Balancer:

```sh
spec:
  type: LoadBalancer
  ports:
  - port: 80
    nodePort: 32092
    protocol: TCP
    targetPort: 9292
```

Now Load-Balancer has to be configured and obtain new External IP address to access the cluster and application. This process will take some time:

```sh
$ kubectl get service -n dev --selector component=ui
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
ui     LoadBalancer   10.51.246.81   <pending>     80:32092/TCP   14m
ivbor@ivbor-nout ~/Otus/ivbor7_microservices/kubernetes/reddit $ kubectl get service -n dev --selector component=ui
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
ui     LoadBalancer   10.51.246.81   35.184.181.50   80:32092/TCP   17m
```

Drawbacks of using LB Service:

- cannot be controlled using http URI (L7-balancing)
- are used only cloud LBs
- there are no flexible rules to handle the traffic

To fix these weaknesses the Kubernetes entity Ingress are called.
Ingress - this is a set of rules inside of Kubernetes cluster, designed to allow incoming connections could reach Services. Ingress managed by Ingress Conroller which has not started with cluster and can be activated like a pluggin and exists in the form of Pod.
Ingress Controller consist of two parts: first - utility that monitor a new Ingress objects via k8s API and  update the Balancer configuration and seconf part - Balancer (nginx, haproxy, traefik,...) handles the network traffic.

Create the Ingress for  UI  service:

```yml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
spec:
  backend:
    serviceName: ui
    servicePort: 80
```

and apply the manifest: `kubectl apply -f ui-ingress.yml -n dev`

- the new address of application now is:

```sh
 $ kubectl get ingress -n dev
NAME   HOSTS   ADDRESS       PORTS   AGE
ui     *       34.95.93.83   80      7m17s

kubectl get service -n dev --selector component=ui
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
ui     LoadBalancer   10.51.246.81   35.184.181.50   80:32092/TCP   164m
```

For now we have two balancer: Ingress and LoadBalancer. So, we can remove one of them. Let's restore type LoadBalancer return it to NodePort in ui-service.yml:

```yml
spec:
  type: NodePort
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
```

One more case. Let's make the Ingress Controller work as a classic web. Add the line in ui-ingress.yml:

```yml
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: ui
          servicePort: 9292
```

Currently Ingress is:

```sh
$ kubectl get ingress -n dev
NAME   HOSTS   ADDRESS       PORTS   AGE
ui     *       34.95.93.83   80      112m
```

Protect our Ingress with TLS:

```sh
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.95.93.83"
Generating a 2048 bit RSA private key
.+++
.....................+++
writing new private key to 'tls.key'
-----
```

upload it in cluster: `kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev`
check it then:

```sh
$ kubectl describe secret ui-ingress -n dev
Name:         ui-ingress
Namespace:    dev
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1099 bytes
tls.key:  1704 bytes
```

Now configure Ingress to accept only HTTPS traffic:

```sh
ui-ingress.yml
...
metadata:
  name: ui
  annotations:
    kubernetes.io/ingress.allow-http: "false"
spec:
  tls:
  - secretName: ui-ingress
  ...
```

After applying Ingress manifest an http protocol may not be deleted from existing Ingress rules, then you need to manually remove it and recreate:

```sh
$ kubectl delete ingress ui -n dev
$ kubectl apply -f ui-ingress.yml -n dev
```


- [x] extra task: describe [Kubernetes manifest for Secret](https://kubernetes.io/docs/concepts/configuration/secret/) object

```yml
---
# ------------------- UI Secret ------------------- #
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: ui
  name: ui-ingress
  namespace: dev
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
type: kubernetes.io/tls
```

Then create the Secret resource running command: `kubectl apply -f ./ui-secret.yaml`


Where (see outlined above code):
> base64 encoded cert|key - means the following : `cat tls.crt(key)|base64 -w0`

__Encoding Note:__ The serialized JSON and YAML values of secret data are encoded as base64 strings. Newlines are not valid within these strings and must be omitted. When using the base64 utility on Darwin/macOS users should avoid using the -b option to split long lines. Conversely Linux users should add the option -w 0 to base64 commands or the pipeline base64 | tr -d '\n' if -w option is not available

There are all the [types of Secrets](https://docs.okd.io/latest/dev_guide/secrets.html#types-of-secrets):
> SecretType = "Opaque"                                 // Opaque (arbitrary data; default)
> SecretType = "kubernetes.io/service-account-token"    // Kubernetes auth token
> SecretType = "kubernetes.io/dockercfg"                // Docker registry auth
> SecretType = "kubernetes.io/dockerconfigjson"         // Latest Docker registry auth

Types of Secrets:

The value in the type field indicates the structure of the secret’s key names and values. The type can be used to enforce the presence of user names and keys in the secret object. If you do not want validation, use the opaque type, which is the default.

Specify one of the following types to trigger minimal server-side validation to ensure the presence of specific key names in the secret data:

    kubernetes.io/service-account-token. Uses a service account token.

    kubernetes.io/dockercfg. Uses the .dockercfg file. for required Docker credentials.

    kubernetes.io/dockerconfigjson. Uses the .docker/config.json file for required Docker credentials.

    kubernetes.io/basic-auth. Use with Basic Authentication.

    kubernetes.io/ssh-auth. Use with SSH Key Authentication.

    kubernetes.io/tls. Use with TLS certificate authorities

Specify type= Opaque if you do not want validation, which means the secret does not claim to conform to any convention for key names or values. An opaque secret, allows for unstructured key:value pairs that can contain arbitrary values.

Next task is to limit traffic to mongodb. Allow the traffic only from post and comment services to mongodb. This task can be resolved with help Network Policy.

- Get the cluster's name:

```sh
$ gcloud container clusters list
NAME            LOCATION       MASTER_VERSION  MASTER_IP    MACHINE_TYPE  NODE_VERSION  NUM_NODES  STATUS
reddit-cluster  us-central1-a  1.13.7-gke.8    34.67.89.31  g1-small      1.13.7-gke.8  3          RUNNING
```

Enable network-policy for GKE:

```sh
$ gcloud container clusters update reddit-cluster --zone=us-central1-a --update-addons=NetworkPolicy=ENABLED
Updating reddit-cluster...done.                                                                                                                                                                
Updated [https://container.googleapis.com/v1/projects/docker-250311/zones/us-central1-a/clusters/reddit-cluster].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-central1-a/reddit-cluster?project=docker-250311
ivbor@ivbor-nout ~/Otus/ivbor7_microservices/kubernetes/reddit $ gcloud container clusters update reddit-cluster --zone=us-central1-a  --enable-network-policy
Enabling/Disabling Network Policy causes a rolling update of all cluster nodes, similar to performing a cluster upgrade.  This operation is long-running and will block other operations on the cluster (including delete) until it has run to completion.
Do you want to continue (Y/n)?  y
Updating reddit-cluster...done.
Updated [https://container.googleapis.com/v1/projects/docker-250311/zones/us-central1-a/clusters/reddit-cluster].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-central1-a/reddit-cluster?project=docker-250311
```

[Enable traffic](https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/10-allowing-traffic-with-multiple-selectors.md) for post sevice to mongodb:

```yml
...
 ingress:
  - from:
    - podSelector:
        matchLabels:
          app: reddit
          component: comment
    - podSelector:
        matchLabels:
          app: reddit
          component: post
```

Current storage for database does not save data after stopping the pod with mongo.
Create a disk in GCP:

```sh
$ gcloud compute disks create --size=25GB --zone=us-central1-a reddit-mongo-disk
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/docker-250311/zones/us-central1-a/disks/reddit-mongo-disk].
NAME               ZONE           SIZE_GB  TYPE         STATUS
reddit-mongo-disk  us-central1-a  25       pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
```



Related links:

1. [Kubernetes cheatsheet (Unofficial)](https://unofficial-kubernetes.readthedocs.io/en/latest/user-guide/kubectl-cheatsheet/)
2. [Init Containers - Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/?spm=a2c65.11461447.0.0.2ebb5d45blkPsA#what-can-init-containers-be-used-for)
3. [How to create and Use Secrets in Kubernetes](https://www.alibabacloud.com/blog/how-to-create-and-use-secrets-in-kubernetes_594723)
4. []()
