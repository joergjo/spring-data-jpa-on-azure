FROM mcr.microsoft.com/java/jre-headless:11-zulu-alpine AS base
EXPOSE 8080

FROM mcr.microsoft.com/java/jdk:11-zulu-alpine AS build
ARG profile="postgresql"
WORKDIR /build

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw -B dependency:go-offline -P $profile

COPY src src
RUN ./mvnw -B package -DskipTests -P $profile

FROM base AS final
WORKDIR /app
RUN wget -q -O applicationinsights-agent-3.0.0-PREVIEW.jar https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.0.0-PREVIEW/applicationinsights-agent-3.0.0-PREVIEW.jar
COPY ApplicationInsights.json .
COPY --from=build /build/target/spring-data-jpa-on-azure-*.jar spring-data-jpa-on-azure.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent-3.0.0-PREVIEW.jar", "-jar", "spring-data-jpa-on-azure.jar"]
