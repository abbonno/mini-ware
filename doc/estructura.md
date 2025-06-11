# Estructura

> El contenido es temporal y está poco madurado **(actualizar, está outdated)**

/GameFramework/
│── /core/                  # Código base del framework
│   ├── GameManager.gd       # Controlador principal del juego
│   ├── SceneManager.gd      # Maneja cambios de escenas/minijuegos
│   ├── InputManager.gd      # Procesa entrada del jugador
│   ├── EventManager.gd      # Sistema de eventos y lógica del juego
│── /assets/                 # Recursos multimedia
│   ├── /backgrounds/        # Fondos de pantalla
│   ├── /characters/         # Sprites de personajes
│   ├── /music/              # Música de fondo
│   ├── /sounds/             # Efectos de sonido
│── /games/                  # Minijuegos definidos por el usuario
│   ├── /game1/              # Minijuego de ejemplo 1
│   │   ├── game.json        # Configuración del minijuego
│   │   ├── script.json      # Diálogos y eventos
│── /ui/                     # Interfaz gráfica
│   ├── HUD.tscn             # Interfaz común del juego
│   ├── MainMenu.tscn        # Menú principal
│── /config/                 # Archivos de configuración del framework
│   ├── settings.json        # Configuración general
│── /export/                 # Carpeta para juegos exportados
│── main.gd                  # Script de inicio
│── project.godot            # Archivo del proyecto en Godot

## Flujo de información

El framework seguirá un modelo basado en Gestión de Escenas y Eventos, donde los archivos JSON definirán la lógica del juego y el motor de Godot se encargará de representarla.

📌 Flujo de Información
1️⃣ Inicio: GameManager.gd carga los archivos de configuración y el menú principal.
2️⃣ Selección de Juego: El usuario elige un minijuego, SceneManager.gd lo carga desde /games/.
3️⃣ Carga de Recursos: ResourceLoader.gd busca en /assets/ los elementos definidos en el JSON del juego.
4️⃣ Ejecución: Se generan los elementos en pantalla y EventManager.gd gestiona la lógica del juego.
5️⃣ Interacción del Usuario: InputManager.gd captura teclas, clics o toques en pantalla.
6️⃣ Finalización: Se guarda el progreso (si aplica) y se vuelve al menú o se cambia de minijuego.

## Elementos

Para que sea fácil de usar y extensible, el framework tendrá los siguientes componentes clave:

Elemento	Descripción
GameManager	Controlador principal del framework, inicia y finaliza juegos.
SceneManager	Maneja la carga de minijuegos y cambios de escena.
EventManager	Gestiona eventos del juego como diálogos, acciones y lógica.
InputManager	Captura las entradas del usuario (teclado, ratón, táctil).
ResourceLoader	Carga dinámicamente imágenes, sonidos y configuraciones.
HUD/UI	Interfaz gráfica común a todos los juegos (barra de vida, botones, texto).

...