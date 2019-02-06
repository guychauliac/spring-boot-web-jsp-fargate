### Docker image with amazon corretto

	build the image in the docker folder: 'docker build -t spring-boot-web-jsp:latest .'
	run the image: 'docker run -p 8080:8080/tcp -it spring-boot-web-jsp'
	
	
### Create docker image on openshift

	Create a new build that tracks amazoncorretto:8 : 'oc new-build --strategy docker --binary --docker-image amazoncorretto:8 --name spring-boot-web-jsp'
	Create the image: 																'oc start-build spring-boot-web-jsp --from-dir . --follow'
	Deploy application: 															'oc new-app spring-boot-web-jsp'
	Expose port: 																			'oc expose dc/spring-boot-web-jsp --port=8080'
	


	
