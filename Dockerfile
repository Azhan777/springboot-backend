#FROM: Specifies the base image to build upon. In this case, it's maven:3.8.4-openjdk-17, which is an image containing Maven and OpenJDK 17.
#AS builder: Assigns a name (builder) to this stage. This allows for multi-stage builds, where you can have different stages for building and running your application.
FROM maven:3.8.4-openjdk-17 AS builder

#WORKDIR: Sets the working directory inside the container to /app. This is where subsequent commands will be executed.
WORKDIR /app

#Copies files from the Docker build context (the directory containing the Dockerfile) into the container's filesystem. The first . represents the source directory in the build context (current directory), and the second . represents the destination directory in the container (current working directory, which is /app).
COPY . .

#RUN: Executes a command inside the container during the image build process. Here, it runs Maven to build the application. The options -B (batch mode) and -DskipTests (skips running tests) are Maven options. The clean package command cleans any previous build artifacts and packages the application into a JAR file.
RUN mvn -B -DskipTests clean package

#Starts a new stage in the Dockerfile, using another base image (openjdk:17), which contains only the Java runtime environment (JRE) without Maven.
FROM openjdk:17

#Creates a mount point at /tmp in the container. Volumes are used to persist data outside the container's lifecycle. This can be useful for storing logs, configuration files, or any other data that needs to be preserved even if the container is deleted.
VOLUME /tmp

#Informs Docker that the container will listen on port 8080 at runtime. However, this does not actually publish the port; it is merely a documentation for users of the image.
EXPOSE 8080

#Sets the working directory inside the container to /app again, just like in the previous stage.
WORKDIR /app

#Copies the JAR file built in the previous stage (builder) into the current stage. --from=builder specifies the stage to copy from, and /app/target/*.jar is the source path of the JAR file. app.jar is the destination path inside the current stage.
COPY --from=builder /app/target/*.jar app.jar

#Specifies the command that will be executed when the container starts. Here, it runs the Java application by executing the JAR file (app.jar) using the java -jar command.
ENTRYPOINT ["java","-jar","app.jar"]