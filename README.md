# ivbor7_microservices
ivbor7 microservices repository

## Homework #12 (docker-2 branch)

Within the hw#12 the following tasks were done:
 - Install Docker – 17.06+, docker-compose – 1.14+, docker-machine – 0.12.0+
 - major docker commands considered
 - the main differences between image and container described (*)
 - GCP preparation tasks fulfilled
 - working with Docker - 
 - docker repository structure created -
 - Dockerfile created
 - build and running the container
 - working with Dockerhub
 - create the prototype of infrastructure (*)

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

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash
```

 - [x] new project "docker", ID=docker-250311 created on GCP
 - [x] create Docker-host on GCP with Docker installed:
```
export GOOGLE_PROJECT=docker-250311
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
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
 - [x] assign a tag "reddit:latest" to our image with the reddit application onboard and push it to the docker hub for consequent using it from anywhere:
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
The prototype of the project is implemented according to the following logic
