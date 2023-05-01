# base image for the builder stage, which is maven:3.8.1-jdk-20. This image contains Maven and Java 20,
# which are needed to compile and package the Spring Boot application.
FROM maven:3.8.1-jdk-20 as builder

# Sets the working directory for the builder stage to /app, which is where the code and dependencies
# will be copied and built.
WORKDIR /app

COPY pom.xml .
COPY src ./src

# Build a release artifact.
RUN mvn package -DskipTests

# The base image for the production stage, which is adoptopenjdk/openjdk20:alpine-slim. This image contains OpenJDK 20,
# which is needed to run the Spring Boot application. The alpine-slim variant is a minimal image that
# reduces the size and attack surface of the container image.
FROM adoptopenjdk/openjdk20:alpine-slim

# Copies the jar file from the builder stage (/app/target/writer-*.jar) to the production stage (/writer.jar).
# This way, only the jar file is included in the final container image, not the source code or dependencies.
COPY --from=builder /app/target/writer-*.jar /writer.jar

# Runs the java command on container startup, which executes the jar file as a Java application.
# The -Djava.security.egd=file:/dev/./urandom option is used to improve startup performance by
# using a non-blocking entropy source for secure random number generation.
CMD ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/writer.jar"]