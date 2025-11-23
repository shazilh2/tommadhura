# ===== Stage 1: Build the WAR with Maven =====
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy project source
COPY src ./src

# Build project (this also downloads webapp-runner.jar into .m2)
RUN mvn package -DskipTests


# ===== Stage 2: Run with webapp-runner (Tomcat) =====
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy WAR from build stage
COPY --from=build /app/target/java-tomcat-maven-example.war app.war

# Copy webapp-runner from Maven local repo
COPY --from=build /root/.m2/repository/com/github/jsimone/webapp-runner/8.5.11.3/webapp-runner-8.5.11.3.jar webapp-runner.jar

EXPOSE 8095

# Run using embedded Tomcat
ENTRYPOINT ["java", "-jar", "webapp-runner.jar", "--port", "8095", "app.war"]
