# Integración de Base de Datos y Leaderboard en el Videojuego

## Descripción del proyecto

En este proyecto se realizó la adaptación e integración de una base de datos al videojuego, con el objetivo de almacenar y gestionar información relevante del jugador y permitir el registro de sus puntuaciones. Como parte de esta implementación, se desarrolló un sistema de *leaderboard* (tabla de clasificación) que permite visualizar y comparar los resultados obtenidos por los jugadores.

La integración de la base de datos permite conservar información entre distintas sesiones de juego, facilitando el seguimiento del rendimiento y la consulta de puntuaciones.

## Objetivos

- Adaptar la estructura de la base de datos a las necesidades del videojuego.
- Implementar el almacenamiento de las puntuaciones obtenidas durante las partidas.
- Incorporar un leaderboard para mostrar las mejores puntuaciones.
- Facilitar la consulta y comparación de resultados entre jugadores.
- Mejorar la experiencia de juego mediante un sistema de clasificación.

## Funcionalidades implementadas

### Adaptación de la base de datos

Se modificó y adaptó la estructura de la base de datos para integrarla con los sistemas del videojuego. Esta adaptación permite organizar la información necesaria para registrar los resultados de las partidas y relacionarlos con los jugadores correspondientes.

La integración busca mantener la información estructurada y facilitar su consulta desde el videojuego.

### Sistema de puntuaciones

Se incorporó un mecanismo para registrar las puntuaciones generadas durante las partidas. Al finalizar una sesión, los resultados pueden almacenarse en la base de datos para su posterior consulta, de acuerdo con la lógica implementada en el juego.

### Leaderboard

Se implementó un leaderboard que permite mostrar las puntuaciones de los jugadores en una tabla de clasificación. Su finalidad es identificar los mejores resultados y ofrecer una referencia del rendimiento obtenido durante las partidas.

El sistema permite consultar las puntuaciones almacenadas y organizarlas para mostrar los resultados más destacados, fomentando la competencia y la posibilidad de superar marcas anteriores.

## Integración con el videojuego

La base de datos se conectó con los componentes del videojuego responsables de gestionar los resultados. De esta manera, el sistema puede utilizar la información almacenada para mostrar las puntuaciones en la interfaz correspondiente.

El flujo general de funcionamiento es el siguiente:

1. El jugador inicia y juega una partida.
2. El videojuego calcula el resultado obtenido.
3. La puntuación se registra en la base de datos.
4. El leaderboard consulta los resultados disponibles.
5. Las puntuaciones se presentan en la tabla de clasificación.

## Beneficios de la implementación

La adaptación de la base de datos y la incorporación del leaderboard permiten ampliar las funcionalidades del videojuego, conservar los resultados de las partidas y proporcionar una forma organizada de consultar las puntuaciones.

Además, esta implementación establece una base para futuras mejoras, como la incorporación de perfiles de jugador, estadísticas históricas, filtros de clasificación y sistemas de logros.

## Conclusión

La integración de la base de datos y el desarrollo del leaderboard representan una mejora en la gestión de la información del videojuego. Con estas funcionalidades, es posible registrar y consultar puntuaciones, así como visualizar una clasificación basada en los resultados obtenidos. Esta implementación contribuye a mejorar la experiencia del jugador y facilita la ampliación futura del sistema.


