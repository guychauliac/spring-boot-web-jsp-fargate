# Alpine Linux with OpenJDK JRE
FROM amazoncorretto:8
# copy WAR into image
COPY target/spring-boot-web-jsp-1.0.war /app.war 
# run application with this command line 
CMD ["/usr/bin/java", "-jar", "-Dspring.profiles.active=default", "/app.war"]