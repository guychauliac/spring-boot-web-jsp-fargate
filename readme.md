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

An ECR is a repository for docker images.  Each AWS account has a single default ECR.  In our example we will create a new ECR and upload the image to this repository.

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

# Give name to VPC

It's adviseable to give a name to the VPC that you just created.  For this goto the 'VPC' service, find the newly created VPC and give it a name. e.g. 'Fargate VPC'

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

Use 'CMD-SHELL,curl -f http://localhost:8080 || exit 1' as healt check command

Leave all the other options and click create

[building-deploying-and-operating-containerized-applications-with-aws-fargate](https://aws.amazon.com/blogs/compute/building-deploying-and-operating-containerized-applications-with-aws-fargate/)

# Setting up a Load Balancer

We will setup an [application load balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

The application load balancer will be the access point from the internet.  It will receive a DNS entry which is publically available.

Later we will define a Fargate service which will be running in 2 Availability Zones.  The load balancer will spread the requests across the 2 availability zones. 

Navigate to  EC2 service

Click on  Load Balancers

Click 'Create Load Balancer'

Select 'Application Load Balancer', click on 'Create'

As name type 'ApplicationLoadBalancer'

Use 'internet-facing'

Use IPV4

Make sure there is a listener defined at port 80

!! For the VPC, select the VPC that was created earlier during setup of the Farget cluster, i.e. the VPC with CIDR 10.0.0.0/16 !!

Select both availability zones

Click 'Next: Configure Security Settings'

Click 'Next : Configure Security Groups'

Select 'Create a new security group'

Give it a name e.g. 'application-load-balancer-security-group'

Make sure there is a rule to accept all incoming traffic at port 80.

Click 'Next: Configure Routing'

On this page you will configure the [Target Group](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html).  Withing a load balancer you can define multiple target groups.   As the name suggests a target group is a group of 'targets'.  A target is a single server that has been spinned up in the cluster.  Later we will link the fargate service with this target group.  As a result all spinned up instances will be registered in this target group. The target group exposes a service on a single port.  This port should correspond with the port that is being exposed by the containers running inside the fargate task.

Select 'New target group'

As name give it 'Spring-boot-web-jsp-target-group'

As type select 'IP'

For the port type '8080' as it should correspond with the port of our fargate task.

Leave the protocoal and path as is.

Click 'Next: Register Targets'

We will not manually register any targets.  Once we create the Fargate service and link it with this target group, the targets will register themselves with the target group.  We will check later if this happens correctly.

Click: 'Next : Review'

Click : 'Create'

Click: 'Close'


# Setting up a Fargate Service

A fargate service is responsible for starting a fargate task and making sure it keeps running.  The fargate service can be instructed to run any number of instances of the task within a predefined list of availability zones. The fargate service will monitor the tasks and if any of these dies it will launch a new task to make sure the required number of tasks instances is kept on running.    

Navigate to the ECS service

Click on the 'Applications' fargate cluster we created earlier

In the 'Services' tab click on 'Create' to create a new service

As launch type select 'Fargate'

For Task definition select 'spring-boot-web-jsp' with the latest revision.

As service name enter 'spring-boot-web-jsp'

For the number of tasks enter '2'

Leave the health percentages

Click 'Next Step'

For the cluster VPC, select the previously created VPC with CIDR 10.0.0.0/16

Select the 2 subnets associated wit this VPC

Click on the edit button for the security group.  Create a new security group named 'spring-boot-web-jsp-security-group' in which you accept only tcp port '8080'  For this select as type 'Custom TCP' with port range 8080 and source 'Anywhere'

put 'Auto-assign public IP' to DISABLED

Select 'Application load balancer' 

In the drop down select the load balancer previously created 'ApplicationLoadBalancer'

For container select 'spring-boot-web-jsp:8080:8080'

Click 'Add to load balancer'

This part of the wizard is a little bit confusing.  On this section of the page you can configure the target group and the port on which the load balancer should listen.  As we already did this and we previously created a target group named 'Spring-boot-web-jsp-target-group' we just have to select this target group and the other fields will be populated automatically.

Keep 'Enable service discovery integration' selected  (not sure why it's being used for)

Click 'Next Step'

Leave the Service auto scaling option as is.

Click 'Next step'

Click 'Create Service'

Verify that everything is green and click 'View Service'

In the 'tasks' tab you should see 2 tasks that are being created.  They will have the status 'PENDING'. After a while they should become 'RUNNING'.  You can also check the application logs by going to Services -> Cloudwatch -> logs -> /ecs/spring-boot-web-jsp -> select first log stream -> watch output of the spring application

Navigate to 'EC2' service.

Click on 'Target Groups'

Select the 'Spring-boot-web-jsp-target-group' 

Verify in the tab 'targets' that 2 targets where registered.

Verify if the service is running at the public DNS of the application load balancer

On the left click on 'Load balancers'.

Select the load balancer 'ApplicationLoadBalancer' and copy the DNS name.

Copy paste the DNS name in a browser and check if you correctly see the spring boot applications home page.


# Troubleshooting

- After launching the Fargate service, check the status of the 'Running' tasks withing the service.  They should all be 'RUNNING'.  Also check the 'Stopped' tasks.  If you see tasks there it means some of the tasks where stopped for some reason.  E.g. it could be because the health check of the container has failed.  In that case investigate why the healtch check is failing.  (In my case it was a wrong configured health check)

- When you see that all tasks within the service are running fine then check if the target group has the same number of targets as the task number of desired tasks that where defined in the service.

- Check that all the targets in the target group are healthy.

- If at this point you can still not reach your service, then check the settings of the security groups
	*  Did you correctly define that incoming http traffic on port 80 is allowed in the security group of the load balancer ?
	*  Did you correctly define that incoming http traffic on port 8080 is allowed in the security group of the  fargate service ?
	
- Check the target group
 	* Did you define it correctly to receive traffic at http port 80
 	* Did you correctly define it as target type 'IP'
	
- Check the load balancer
	* Did you create a listener that forwards http calls on port 80 to the correct target group ?
	
Continue to [CICD](CICD.md)
	