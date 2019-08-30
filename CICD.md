# Setting up a CI CD

 In this section we will setup an AWS Codepipeline. The pipeline will
 	- checkout the code from the git repository
 	- build the project
 	- create the docker images
 	- upload the docker image to the AWS repository
 	- Deploy the new image on the ECS Fargate cluster
 	
# References
This tutorial is based on [build-a-continuous-delivery-pipeline-for-your-container-images-with-amazon-ecr-as-source](https://aws.amazon.com/blogs/devops/build-a-continuous-delivery-pipeline-for-your-container-images-with-amazon-ecr-as-source/)

[AWS Code pipeline](https://aws.amazon.com/codepipeline/)
[AWS CodeBuild](https://aws.amazon.com/codebuild/)
[AWS Code Deploy](https://aws.amazon.com/codedeploy/)

 
# Build specification
 
The actions that need to be done to build the application and create the image can either be stored in the pipeline itself or as a build specification in the project itself.

In this tutorial we will put the build specification in the project itself.

Have a look at the file [buildspec.yaml](buildspec.yaml)

The build specifaction contains the different steps to build the project, create the image and upload it to the AWS image repository.

note the generated output artifact 'imagedefinitions.json' which is required for the deployment step in the build pipeline. 

# Setting up a build pipeline
Navigate to the AWS Code build service

## Build the project 
Within the codebuild navigate to Build -> Build projects
Press 'Create build project'  
Call the project spring-boot-web-jsp
Select Github as source
Select 'Public Repository'
Provide the github url:  https://github.com/guychauliac/spring-boot-web-jsp.git
	
 

 