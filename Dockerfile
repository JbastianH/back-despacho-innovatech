# ETAPA 1: Construcción (Build) - Se encarga de transformar el código fuente en un binario ejecutable.
# Se utiliza una imagen de Maven con JDK 17 como base para compilar el proyecto.
FROM maven:3.8.5-openjdk-17-slim AS build

# Se define /app como el directorio de trabajo donde se realizarán todas las operaciones.
WORKDIR /app

# Se transfiere el archivo pom.xml al contenedor para gestionar las dependencias del proyecto.
COPY pom.xml .

# Se ejecutan las descargas de las dependencias necesarias de forma aislada para optimizar la caché de Docker.
RUN mvn dependency:go-offline

# Se transfiere la carpeta de código fuente (src) al entorno de construcción.
COPY src ./src

# Se compila el código y se genera el archivo .jar ejecutable, omitiendo las pruebas unitarias para acelerar el proceso.
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución (Run) - Se genera la imagen final optimizada para el despliegue.
# Se utiliza una imagen ligera (Alpine) que solo contiene el JRE (entorno de ejecución), reduciendo el tamaño y la superficie de ataque.
FROM --platform=linux/amd64 eclipse-temurin:17-jre-alpine

# Se establece nuevamente /app como el directorio de trabajo para la ejecución.
WORKDIR /app

# Se crea un grupo y un usuario de sistema denominado "spring" para evitar ejecutar la aplicación con privilegios de administrador (root).
RUN addgroup -S spring && adduser -S spring -G spring

# Se cambia el contexto de ejecución al usuario "spring" previamente creado para mejorar la seguridad del contenedor.
USER spring

# Se recupera el archivo .jar generado en la etapa de construcción (build) y se renombra a app.jar en la imagen final.
COPY --from=build /app/target/*.jar app.jar

# Se documenta que el contenedor escuchará peticiones en el puerto 8080.
EXPOSE 8080

# Se define el comando principal que iniciará la máquina virtual de Java y ejecutará la aplicación al arrancar el contenedor.
ENTRYPOINT ["java", "-jar", "app.jar"]
