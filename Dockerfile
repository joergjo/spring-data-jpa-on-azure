FROM mcr.microsoft.com/java/jdk:11-zulu-alpine AS base
VOLUME /tmp
EXPOSE 8080

FROM mcr.microsoft.com/java/jdk:11-zulu-alpine AS build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw install -DskipTests -P postgresql
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM base AS final
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java", "-cp", "app:app/lib/*", "com.microsoft.azure.samples.spring.Application"]