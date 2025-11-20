# --- STAGE 1: Build w java25 image ---
FROM eclipse-temurin:25-jdk-jammy AS build

# Installa Maven
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-3.9.6-bin.tar.gz -C /opt && \
    rm /tmp/apache-maven-3.9.6-bin.tar.gz
ENV M2_HOME /opt/apache-maven-3.9.6
ENV PATH $PATH:$M2_HOME/bin

# Set working directory
WORKDIR /app

# Copy source code and pom.xml
COPY pom.xml .
COPY src /app/src

# compile the Spring Boot app in an executable jar
RUN mvn clean package -DskipTests


# --- STAGE 2: Runtime w java25 jre image (lighter) ---
FROM eclipse-temurin:25-jre-jammy AS runtime

WORKDIR /app

# Copy .jar file compiled from stage 'build'
COPY --from=build /app/target/*.jar /app/app.jar

# env variable to connect to model-service
ENV MODEL_HOST="http://model-service:8081"

# expose application port
EXPOSE 8080

# cmd to start the spring boot application
ENTRYPOINT ["java", "-jar", "app.jar"]