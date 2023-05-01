# The base image for the production stage, which is amazoncorretto:20-alpine-slim. This image contains amazon corretto 20,
# which is needed to run the Spring Boot application. The alpine-slim variant is a minimal image that
# reduces the size and attack surface of the container image.
FROM amazoncorretto:20-alpine

# Copies the jar file from the builder stage (/app/target/writer-*.jar) to the production stage (/writer.jar).
# This way, only the jar file is included in the final container image, not the source code or dependencies.
COPY target/writer-*.jar /writer.jar

# Runs the java command on container startup, which executes the jar file as a Java application.
# The -Djava.security.egd=file:/dev/./urandom option is used to improve startup performance by
# using a non-blocking entropy source for secure random number generation.
CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/writer.jar"]