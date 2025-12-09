# TP Assembler - BAR GAME

Trabajo Práctico desarrollado en **Assembly 8086**.

## 🎮 ¿En qué consiste?
Es un juego de habilidad y velocidad donde el objetivo es **presionar la barra espaciadora** lo más rápido posible para llenar una barra de progreso antes de que se agote el tiempo límite.

### Características Técnicas
El proyecto destaca por su modularidad y el manejo de interrupciones:
* **Interrupción:** Se incluye un programa (`int77.asm`) que se instala en la memoria y crea una **interrupción personalizada (INT 77h)**.
* **Librería propia:** Uso de un módulo secundario (`libtp.asm`) para rutinas comunes como imprimir en pantalla y conversiones ASCII.
* **Manejo de Hardware:** Acceso directo a memoria de video y manejo del timer del sistema para calcular el tiempo transcurrido.

## 📂 Archivos del Repositorio
* `maintp.asm`: Código fuente principal con la lógica del juego.
* `libtp.asm`: Librería de funciones auxiliares.
* `int77.asm`: Código residente de la interrupción 77h.
* `comp.bat`: Script de automatización para compilar, linkear y ejecutar todo.

## ⚙️ Requisitos y Ejecución
Para correr el juego necesitas un emulador de DOS (como **DOSBox**) y el compilador **TASM** (Turbo Assembler).
