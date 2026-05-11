# ETAPA 1: Construcción (Build) - Aquí "cocinamos" el archivo .jar
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app

# Copiamos archivos de configuración de Maven para descargar dependencias primero
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamos el código fuente y generamos el archivo ejecutable
COPY src ./src
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución (Run) - Aquí solo dejamos lo mínimo para que funcione
FROM --platform=linux/amd64 eclipse-temurin:17-jre-alpine
WORKDIR /app

# SEGURIDAD: Creamos un usuario que NO sea root (Requisito IE1)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

# Traemos el archivo .jar desde la etapa de construcción
COPY --from=build /app/target/*.jar app.jar

# Exponemos el puerto 8080 para que la aplicación sea accesible desde fuera del contenedor
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]