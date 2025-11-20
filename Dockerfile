# --- STAGE 1: Build with Maven + Java 25 ---
FROM maven:3.9.11-eclipse-temurin-25-alpine AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

# build the Spring Boot application JAR
RUN mvn clean package -DskipTests


# --- STAGE 2: Runtime with JRE that is light ---
FROM eclipse-temurin:25-jre-jammy

WORKDIR /app

COPY --from=build /app/target/*.jar /app/app.jar

ENV MODEL_HOST="http://model-service:8081"

# env variable for app port (default 8080)
ENV APP_PORT=8080

# expose application port (just documentation)
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
