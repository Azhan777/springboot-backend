# Base Image
FROM maven:3.8.4-openjdk-17 AS builder
WORKDIR /app
COPY . .
RUN mvn -B -DskipTests clean package

FROM openjdk:17
VOLUME /tmp
EXPOSE 8080
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]