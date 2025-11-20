# --- STAGE 1: Build w java25 image ---
FROM eclipse-temurin:25-jdk-jammy AS build

# Install Maven
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-3.9.6-bin.tar.gz -C /opt && \
    rm /tmp/apache-maven-3.9.6-bin.tar.gz
ENV M2_HOME /opt/apache-maven-3.9.6
ENV PATH $PATH:$M2_HOME/bin

WORKDIR /app

COPY pom.xml .
COPY src /app/src
RUN mvn clean package -DskipTests

# --- STAGE 2: Runtime w java25 jre image (lighter) ---
FROM eclipse-temurin:25-jre-jammy AS runtime
WORKDIR /app

COPY --from=build /app/target/*.jar /app/app.jar

# env variable to connect to model-service
ENV MODEL_HOST="http://model-service:8081"

# env variable for app port (default 8080)
ENV APP_PORT=8080

# expose application port (just documentation)
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]