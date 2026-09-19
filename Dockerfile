FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/examenFinal_automatizacionPruebas-1.0-SNAPSHOT.jar app.jar

EXPOSE 8080

CMD ["java", "-cp", "app.jar", "cl.figio.automatizacion.LoginHttpServer"]