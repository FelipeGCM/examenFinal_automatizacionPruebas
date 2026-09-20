# Examen Final - Automatización de Pruebas

Proyecto desarrollado para el examen final de la asignatura Automatización de Pruebas.

El proyecto toma como base el trabajo realizado durante las unidades anteriores y lo amplía incorporando versionamiento mediante Git, gestión de dependencias con Maven, pruebas unitarias, BDD, pruebas de integración, integración continua, pruebas de performance, despliegue en un ambiente de pruebas, acceptance tests y un mecanismo automático de rollback.

Repositorio:

https://github.com/FelipeGCM/examenFinal_automatizacionPruebas

---

## Tecnologías utilizadas

- Java 17
- Maven (Surefire y Failsafe)
- JUnit 5
- Cucumber
- JMeter
- GitHub Actions
- Docker
- Ubuntu Server (para Docker)

---

# 1. Versionamiento y configuración del proyecto

## Estrategia Git

Para organizar el desarrollo del examen se utilizó una estructura basada en GitFlow.

Se trabajó principalmente con:

- `main`: rama principal del proyecto.
- `develop`: rama creada como punto de integración.
- `feature/deployment-pipeline`: rama donde se realizaron los cambios asociados al despliegue, acceptance tests y rollback.

Durante el desarrollo del examen los cambios se trabajaron sobre la rama `feature/deployment-pipeline`, manteniéndolos separados de `main` mientras se realizaban las pruebas y validaciones.

---

## Maven

El proyecto utiliza Maven para manejar las dependencias y ejecutar las pruebas.

La configuración se encuentra en:

```text
pom.xml
```

Dentro del proyecto se utilizan JUnit, Cucumber, Surefire y Failsafe.

Para validar el proyecto completo se utilizó:

```text
mvn clean verify
```

Con esta ejecución se validaron:

- 5 pruebas mediante Maven Surefire.
- 2 pruebas de integración mediante Maven Failsafe.

---

# 2. Automatización de pruebas

## Pruebas unitarias

Las pruebas unitarias permiten validar el comportamiento de las clases del proyecto de forma aislada.

Estas pruebas son ejecutadas mediante Maven Surefire.

Para ejecutarlas:

```text
mvn test
```

---

## Pruebas BDD

Se mantuvieron los escenarios BDD desarrollados previamente con Cucumber.

Estos escenarios forman parte de la ejecución automática del proyecto y también se incluyen dentro del pipeline de integración continua.

---

## Pruebas de integración

Se agregaron pruebas de integración para validar el servicio HTTP de login de una forma más completa.

Durante estas pruebas se levanta temporalmente el servidor y se realizan solicitudes reales contra:

```text
POST /login
```

Se validan dos escenarios:

- Credenciales correctas.
- Credenciales incorrectas.

Estas pruebas se ejecutan mediante Maven Failsafe.

```text
mvn clean verify
```

Con esto se valida no solo la lógica interna, sino también que el servicio responda correctamente al recibir una solicitud real.

---

# 3. Integración continua

El proyecto utiliza GitHub Actions para ejecutar automáticamente las validaciones principales cada vez que se actualiza alguna de las ramas configuradas.

El workflow se encuentra en:

```text
.github/workflows/ci.yml
```

Dentro del pipeline se ejecutan:

1. Compilación del proyecto.
2. Pruebas unitarias.
3. Escenarios BDD.
4. Pruebas de integración.
5. Generación de reportes.
6. Prueba de performance con JMeter.
7. Publicación de los resultados generados.

El pipeline se ejecuta automáticamente ante cambios realizados en las ramas configuradas dentro del workflow.

---

## Pruebas de performance

Se mantuvo la prueba de performance desarrollada previamente con JMeter.

Durante el pipeline se levanta el servicio de login y luego se ejecuta la prueba definida para ese endpoint.

Los resultados quedan disponibles como artefactos dentro de GitHub Actions.

---

# 4. Ambiente de pruebas

Para la parte de despliegue se utilizó un servidor Ubuntu separado del computador donde se desarrolló el proyecto.

El servidor ya contaba con Docker, por lo que se utilizó como ambiente de pruebas para levantar y validar las distintas versiones de la aplicación.

---

## Docker

La aplicación utiliza un Dockerfile multi-stage.

El archivo se encuentra en:

```text
Dockerfile
```
En una primera etapa se compila el proyecto utilizando Maven y Java 17.

Luego se genera una imagen final solamente con Java 17 y el archivo JAR de la aplicación.

Esto permitió realizar la compilación dentro de Docker sin tener que instalar Maven directamente en el servidor.

---

# 5. Pipeline de despliegue

El despliegue se automatizó mediante:

```text
deploy/deploy.sh
```

Para desplegar una versión se utiliza:

```text
./deploy/deploy.sh VERSION
```

Por ejemplo:

```text
./deploy/deploy.sh 1.1
```

El proceso realiza lo siguiente:

1. Construye la nueva imagen.
2. Reemplaza el contenedor anterior.
3. Levanta la nueva versión.
4. Ejecuta los acceptance tests.
5. Si todo está correcto, marca esa versión como stable.
6. Si alguna prueba falla, ejecuta el rollback.

De esta forma una versión solo queda como estable después de pasar las validaciones.

---

# 6. Acceptance Tests

Los acceptance tests se encuentran en:

```text
deploy/acceptance-tests.sh
```

El script valida directamente el servicio desplegado.

Se validan dos escenarios:

### Credenciales correctas

La aplicación debe responder:

```text
HTTP 200
acceso permitido
```

### Credenciales incorrectas

La aplicación debe responder:

```text
HTTP 401
acceso rechazado
```

Si alguna de estas respuestas no corresponde a lo esperado, el script finaliza con error y el despliegue se considera fallido

---

# 7. Rollback

El rollback se encuentra implementado en:

```text
deploy/rollback.sh
```

La imagen Docker identificada mediante la etiqueta:

```text
stable
```
se utiliza para identificar la última versión que pasó correctamente los acceptance tests.

Por ejemplo:

```text
1.0     -> versión anterior
1.1     -> nueva versión validada
stable  -> 1.1
```

Si después se intenta desplegar una versión 1.2 y esta falla, stable sigue apuntando a 1.1.

En ese caso el proceso elimina la versión defectuosa, vuelve a levantar la imagen stable y ejecuta nuevamente los acceptance tests para comprobar que el servicio quedó funcionando correctamente.

El proceso:

1. Elimina el contenedor correspondiente a la versión defectuosa.
2. Levanta nuevamente la imagen `stable`.
3. Ejecuta los acceptance tests sobre la versión recuperada.
4. Confirma que el servicio volvió a un estado correcto.

---

## Validación controlada del rollback

Para comprobar el funcionamiento del mecanismo se realizó una prueba controlada utilizando una versión `1.2` que provocaba un fallo en la autenticación.

Al ejecutar el despliegue, los acceptance tests detectaron la diferencia:

```text
ERROR: se esperaba HTTP 200 y se obtuvo 401
```

Frente a este resultado, el pipeline ejecutó automáticamente el rollback.

La aplicación volvió a levantar la imagen marcada como `stable` y los acceptance tests fueron ejecutados nuevamente.

El resultado final fue:

```text
ACCEPTANCE TESTS EXITOSOS

ROLLBACK COMPLETADO CORRECTAMENTE
```

Con esto se comprobó que una versión defectuosa no reemplaza la última versión conocida como estable.

---

# 8. Estructura del proyecto

```text
.
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── deploy/
│   ├── acceptance-tests.sh
│   ├── deploy.sh
│   └── rollback.sh
│
├── src/
│   ├── main/
│   │   └── java/
│   └── test/
│       ├── java/
│       └── resources/
│
├── Dockerfile
├── pom.xml
└── README.md
```

---

# 9. Resultado final

Con este proyecto se logró dejar automatizado el flujo desde la validación del código hasta el despliegue en un ambiente de pruebas.

Las pruebas se ejecutan mediante Maven y GitHub Actions, mientras que el despliegue se realiza utilizando Docker sobre un servidor Ubuntu.

Además, antes de considerar una versión como estable se ejecutan acceptance tests. Si estos fallan, el sistema vuelve automáticamente a la última versión que había sido validada correctamente.