# ---- Etapa 1: build con Maven ----
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copiar solo el wrapper y pom.xml primero (cache de capas: si no cambian, no se re-descargan dependencias)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Ahora sí copiar el código fuente y compilar
COPY src src
RUN ./mvnw package -DskipTests -B

# ---- Etapa 2: runtime ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Usuario no-root por seguridad
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]