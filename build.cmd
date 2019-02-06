call mvn clean install
copy target/spring-boot-web-jsp-1.0.war docker
cd docker
call oc new-build --strategy docker --binary --docker-image amazoncorretto:8 --name spring-boot-web-jsp
call oc start-build spring-boot-web-jsp --from-dir . --follow
call oc new-app spring-boot-web-jsp
call oc expose dc/spring-boot-web-jsp --port=8080
