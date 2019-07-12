# Intro

This project describes the full path to get a simple spring boot application deployed on AWS Fargate

# Run application

To test and run the application from an IDE, open the 'SpringBootWebApplication.java' class and run the main method.
Test the application at url http://localhost:8080/ 
You should see a basic html page with a message 'Message: Hello Mkyong'

# Building

To build the application run the command
 
	mvn clean install
	
It should produce a war file 'spring-boot-web-jsp-1.0.war' in the target folder.

# Running the war file

After building the war file the application can  be launched with

	java -jar spring-boot-web-jsp-1.0.war -Dspring.profiles.active=default
	
# Installing docker

Download and install docker from [https://docs.docker.com/install/](https://docs.docker.com/install/)
	
# Building a docker image

Have a look at the 'Dockerfile' in the root of the project

Launch the the docker CLI and run [the docker build command](https://docs.docker.com/engine/reference/commandline/build/)

	docker build -t spring-boot-web-jsp:latest .
	
You should see as output something like

	Successfully built 4b04fb9f7aa6
	Successfully tagged spring-boot-web-jsp:latest
	
You have now build a docker image and stored it in the local image repository.

Check that the image is present in the local image repository with the command

	docker images
	
You should see a line like:

	REPOSITORY                                              TAG                 IMAGE ID            CREATED             SIZE
	spring-boot-web-jsp                                     latest              4b04fb9f7aa6        4 minutes ago       543MB

# Running the docker image

To run the image execute the [Docker run command](https://docs.docker.com/engine/reference/commandline/run/):

	docker run -p 8080:8080/tcp -it spring-boot-web-jsp
	
-p 8080:8080/tcp will forward the port 8080 on the docker host to port 8080 on your system.
-it will launch the container in interactive mode with terminal emulation
	
To test the application running in the docker container you need to know the ip address of the docker host.  The easiest way to achieve it is to just note it down right after startup of the docker CLI. 

	

                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

	docker is configured to use the default machine with IP 192.168.99.100
	For help getting started, check out the docs at https://docs.docker.com

In this example the application can be tested at

	http://192.168.99.100:8080/
	
# Install AWS CLI

Follow the instructions at [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

After installing the CLI configure it to [connect to your account](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html#post-install-configure)

	
# Pushing the image to AWS ECR (Elastic Container Registry)

An ECR is a repository for docker images.  Each AWS account has a single deafult ECR.  In our example we will create a new ECR and upload the image to this repository.

Logon to your AWS account and search for the service 'ECR'.
Click on 'Create Repository'
Enter 'applications/spring-boot-web-jsp' as repo name. Note down the URI that was created for this repo.

[Amazon documentation on pushing a docker image to ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)

To be able to push the docker image to ECR we first need to register the ECR within docker.  Use the following AWS command to obtain the docker command to link docker with your AWS account: (replace eu-west-2 with the preferred region for you account)

	aws ecr get-login --region eu-west-2 --no-include-email
	
copy the command and execute it in the docker terminal

you should see an output stating

	Login Succeeded

By using a tag on the docker image we will instruct link a docker image to a certain image repository

	docker tag [image id] [ECR uri]
	
The image id can be obtained with the command
	
	docker images 
	
the ECR uri can be obtained from aws in the ECR repository overview

Next instruct docker to upload the images which are linked to a certain repository with the command

	docker push [ECR uri]
	
The upmload could take a while, when it's done you see something like:

	$ docker push ************.dkr.ecr.eu-west-1.amazonaws.com/applications/spring-boot-web-jsp
	The push refers to repository [************.dkr.ecr.eu-west-1.amazonaws.com/applications/spring-boot-web-jsp]
	6fb55b3ad549: Pushed
	513ee910d41a: Pushed
	5174cb14ea84: Pushed
	latest: digest: sha256:7385d1c4992295760647043e4258d6f5bb0eb42c9e3e72f0f2136379194797cf size: 954
	
Check your ECR Registry 'applications/spring-boot-web-jsp' that the image has been uploaded correctly
	
Cool, time to spin up our farget cluster!

# Setting up a fargate cluster

On the amazon console search for the 'ECS' service.
Click 'Create Cluster'
Click on 'Networking only' and click 'Next Step'
Give the cluster a name 'Applications'
Check 'Create a new VPC for this cluster' and leave the defaults.  By default it will create a VPC with CIDR 10.0.0.0/16 and 2 subnets within that range which will be hosted in different availability zones.
Check 'enable Container insights'
Press 'Create'

# Setting up a fargate task

Navigate again to the 'ECS' service.
Click on 'Task Definitions' and 'Create new task definition'
Click on 'Fargate'
Click 'Next Step'
Enter 'spring-boot-web-jsp' as name for the task
Leave all the defaults and assign '0.5GB' memory and '0.25 CPU'
Click 'Add container' 
Use 'spring-boot-web-jsp' as container name
Use the image URI you can find in the ECR as the image location. e.g. ************.dkr.ecr.eu-west-1.amazonaws.com/applications/spring-boot-web-jsp:latest
Add a port mapping for 8080 -> 8080 with: '8080 TCP'
Leave all the other options and click create


 

	
	