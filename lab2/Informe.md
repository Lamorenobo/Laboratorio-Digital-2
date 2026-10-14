# Laboratorio 02: TÍTULO DEL LABORATORIO

---

## Integrantes

- Laura Alejandra Moreno
- Jana Rubiano Hurtado
- Johana Tellez Gamez
- Alina Idaly Ortíz Martinez

**Grupo de trabajo:** [Número o nombre del grupo]  
**Semestre:** 2026-1  

---

## Índice

- [Explicación General del Sistema](#explicación-general-del-sistema)
- [Arquitectura Propuesta](#arquitectura-propuesta)
- [Módulos Desarrollados](#módulos-desarrollados)
- [Operaciones e Interfaz](#operaciones-e-interfaz)
  - [Tabla de Operaciones Implementadas](#tabla-de-operaciones-implementadas)
  - [Identificación Visual mediante LED RGB](#identificación-visual-mediante-led-rgb)
- [Gestión de Operandos y Código de Operación](#gestión-de-operandos-y-código-de-operación)
  - [Almacenamiento de Operandos](#almacenamiento-de-operandos)
  - [Conservación del Código de Operación](#conservación-del-código-de-operación)
- [Simulación y Verificación](#simulación-y-verificación)
  - [Capturas de GTKWave](#capturas-de-gtkwave)
  - [Explicación del Comportamiento Observado](#explicación-del-comportamiento-observado)
- [Implementación Funcional en FPGA](#implementación-funcional-en-fpga)
- [Conclusiones](#conclusiones)
- [Referencias](#referencias)

---

## Explicación General del Sistema

### Propósito general del diseño
El presente diseño consiste en el desarrollo e implementación de una Unidad Aritmético-Lógica (ALU) de 4 bits, la cual constituye el primer bloque funcional del *datapath* de un procesador digital. El propósito principal del sistema es ejecutar operaciones aritméticas (suma y resta) y lógicas (AND y OR) utilizando lógica puramente combinacional. Para lograr esto, el diseño separa estrictamente la ejecución de las operaciones (realizadas por la ALU) del almacenamiento de los datos y estados (gestionado por registros externos).

### Funcionamiento global
Dado que los recursos físicos de entrada son limitados, el sistema emplea una arquitectura de bus de datos compartido. El flujo de funcionamiento global mediante las entradas de l FPGA permiten  al usuario ingresar los operandos de forma secuencial y almacenarlos en registros independientes (Registro A y Registro B)  lo cual se realiza dentro del módulo principal. De manera paralela, el sistema cuenta con un registro de control de 2 bits que conserva el código de la operación seleccionada (00, 01, 10 u 11) regida por lo botones de la FPGA. Una vez almacenados los operandos y definida la operación, la ALU procesa los datos de manera combinacional y continua. El sistema está diseñado para mantener en memoria los valores ingresados y la operación activa incluso después de soltar los botones de control o modificar el bus de datos, actualizando el resultado únicamente cuando el usuario decide cambiar explícitamente algún operando o el código de operación.

### Interacción con las entradas y salidas de la FPGA
La interacción del usuario con el sistema se realiza de forma directa a través de los periféricos físicos de la tarjeta FPGA , distribuidos de la siguiente manera:

* **Entradas de datos (Switches SW0 a SW3):** Actúan como un bus de datos de 4 bits a través del cual el usuario configura el valor binario del operando que desea ingresar al sistema.
* **Entradas de control (Botones BTN0 a BTN3):** Permiten al usuario manejar el flujo de datos. El botón **BTN0** captura el valor actual de los switches y lo guarda como Operando A, mientras que el **BTN1**  guarda  el valor como Operando B. Por su parte, los botones **BTN2** y **BTN3** funcionan como selectores de operación al invertir  de forma individual los bits 0 y 1 del registro del código de operación.
  
* **Salidas de datos (LEDs estándar LED0 a LED3):** Se utilizan para visualizar en tiempo real el resultado de 4 bits de la operación matemática o lógica procesada por la ALU.
* **Salida de estado (LED RGB):** Proporciona informacion al usuario acerca de  qué operación se está ejecutando actualmente en el sistema. Emite luz de color **Verde** para la suma, **Rojo** para la resta, **Azul** para la operación AND, y **Amarillo** (combinación de rojo y verde) para la operación OR.
---

## Arquitectura Propuesta

Presente una descripción detallada de la arquitectura física/lógica elegida para resolver el problema (por ejemplo, datapath + unidad de control, registros de entrada, multiplexores, etc.).

*(Si aplica, incluya aquí un diagrama de bloques o esquema del sistema).*

---

## Módulos Desarrollados

Describa cada uno de los módulos en Verilog que componen la solución y sus correspondientes archivos en la carpeta `src/`:

* **`modulo_top`**: Función y rol dentro del diseño.
* **`modulo_alu`** *(o similar)*: Descripción de la unidad encargada de los cómputos.
* **`modulo_control / registros`**: Descripción de la lógica de almacenamiento o captura de entradas.

> **Nota:** Todos los archivos de código fuente deben encontrarse organizados dentro del directorio `src/`.

---

## Operaciones e Interfaz

### Tabla de Operaciones Implementadas

A continuación se detallan las operaciones soportadas por el sistema según el código de operación (*OpCode*) o la combinación de controles definida:

| Código / Selección | Operación | Explicación / Fórmula |
| :---: | :---: | :--- |
| `000` | Suma | $R = A + B$ |
| `001` | Resta | $R = A - B$ |
| `010` | AND | $R = A \ \& \ B$ |
| `011` | OR | $R = A \ \vert \ B$ |
| `100` | XOR | $R = A \ \oplus \ B$ |
| `...` | ... | ... |

---

### Identificación Visual mediante LED RGB

Tabla explicativa con los códigos de color utilizados en el LED RGB para identificar visualmente cada operación durante la ejecución:

| Operación | Estado LED RGB (R, G, B) | Color Resultante | Descripción / Indicación |
| :--- | :---: | :---: | :--- |
| **Suma / Resta** | `(1, 0, 0)` | Rojo | Operación aritmética activa |
| **AND** | `(0, 1, 0)` | Verde | Operación lógica AND activa |
| **OR** | `(0, 0, 1)` | Azul | Operación lógica OR activa |
| **XOR** | `(1, 1, 0)` | Amarillo | Operación lógica XOR activa |
| **...** | `(..., ..., ...)` | ... | ... |

---

## Gestión de Operandos y Código de Operación

### Almacenamiento de Operandos
Explique detalladamente el mecanismo utilizado para capturar y conservar los operandos (por ejemplo, uso de flip-flops/registros de entrada, almacenamiento mediante pulso de botón, lectura directa de switches, etc.).

### Conservación del Código de Operación
Describa cómo el sistema mantiene el código de operación (*OpCode*) seleccionado para asegurar que la ALU procese la instrucción deseada sin perder la selección durante la operación.

---

## Simulación y Verificación

### Capturas de GTKWave
*(Inserte aquí las imágenes de las ondas generadas en GTKWave)*

![GTKWave Simulation](path/to/image.png)

---

### Explicación del Comportamiento Observado
Describa paso a paso las señales observadas en la simulación:
* Verificación de la captura de operandos.
* Confirmación del cálculo correcto según el código de operación.
* Validación de las salidas de bandera o del LED RGB.

---

## Implementación Funcional en FPGA

Incluya las fotos o enlaces a vídeo que evidencien la ejecución en la tarjeta física:

- [ ] **Captura de entradas:** Demostración de ingreso de operandos y código de operación.
- [ ] **Verificación de resultados:** Salida correcta mostrada en los LEDs.
- [ ] **Identificación RGB:** Indicación correcta del color según la operación activa.

---

## Conclusiones

- Principales aprendizajes del diseño digital con captura/almacenamiento de datos.
- Dificultades técnicas encontradas durante la simulación o la síntesis.
- Aportes del análisis de ondas en GTKWave para la detección de errores.

---

## Referencias

- Documentación oficial del lenguaje Verilog HDL.
- Especificaciones de la tarjeta FPGA empleada en el laboratorio.
