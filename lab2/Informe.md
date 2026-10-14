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

El diseño se fundamenta en una arquitectura que divide el sistema en una ruta de datos (*datapath*) y una unidad de control. Esta separación garantiza que la ejecución de las operaciones aritmético-lógicas (lógica combinacional) sea completamente independiente de la captura y almacenamiento de datos del usuario (lógica secuencial).

###  Diagrama de bloques

![Figura1](lab02_alu4bits_datapath.png)

**Figura 1.** Diagrama de bloques del datapath y la unidad de control. Los switches comparten un bus que se captura en reg_A y reg_B mediante pulsos de un ciclo; la ALU es puramente combinacional.

### Datapath y registros de entrada

La ruta de datos relaciona  la información desde los periféricos físicos hasta las salidas visuales:

- **Bus de datos multiplexado:** los cuatro interruptores físicos de la FPGA (`sw[3:0]`) funcionan como un bus de entrada compartido en el tiempo.
- 
- **Registros de operandos:** se implementaron dos registros de 4 bits (`reg_A` y `reg_B`) utilizando memoria secuencial usando flip-flops sincronizados con la señal `clk`. Estos registros actúan como memorias de entrada que capturan el valor del bus temporalmente, reteniendo los operandos estables frente a la ALU de forma continua, sin importar si los interruptores cambian de posición posteriormente.

###  Unidad de control y generación de señales

Se encarga de manejar el flujo de captura de datos y seleccionar el estado de la operación a través de los botones (btn[3:0]):

- **Acondicionamiento de señal (detector de flanco):** la señal de los botones se hace pasar por un par de registros de desplazamiento (`btn_reg0` y `btn_reg1`) y se calcula `btn_pulse = btn_reg0 & ~btn_reg1`. Esto extrae un pulso limpio de un solo ciclo de reloj en el flanco de subida, de modo que una pulsación sostenida produce una única acción. Dicho pulso se usa como habilitador para la escritura segura en los registros.
- **Registro de instrucción (opcode):** un registro de control de 2 bits (`option_reg`) almacena la operación elegida. En lugar de requerir que el usuario mantenga el botón presionado, la unidad de control invierte cada bit individualmente mediante los pulsos de `BTN2` (bit 0) y `BTN3` (bit 1), actuando como una memoria de estado.

| Botón | Acción |
|-------|--------|
| BTN0 | `reg_A <= sw` |
| BTN1 | `reg_B <= sw` |
| BTN2 | `option_reg[0] <= ~option_reg[0]` |
| BTN3 | `option_reg[1] <= ~option_reg[1]` |

### Multiplexor combinacional (ALU)

El sistema combinacional, implementado en el módulo independiente `alu4bits.v`, se diseñó estructuralmente como un multiplexor lógico. Dado que carece de reloj o memoria interna, procesa simultáneamente las sumas, restas y operaciones lógicas de los operandos ingresados. La señal proveniente de la unidad de control (`option_reg`) funciona como el canal selector del multiplexor interno, enrutando el resultado de la operación deseada directamente hacia los LEDs de salida (`led[3:0]`).

| `option` | Operación |
|----------|-----------|
| `00` | Suma |
| `01` | Resta |
| `10` | AND |
| `11` | OR |

### Decodificador visual (LED RGB)

Un bloque de lógica combinacional secundario analiza el valor del registro de instrucción y lo decodifica para activar las compuertas lógicas asociadas a los pines `red`, `green` y `blue` del LED RGB. Su diseño permite la activación simultánea de canales (por ejemplo, encendiendo rojo y verde a la vez cuando el código es `11`) para ampliar la paleta de colores del indicador de estado.

| `option` | Operación | `red` | `green` | `blue` | Color |
|----------|-----------|:-----:|:-------:|:------:|-------|
| `00` | Suma | 0 | 1 | 0 | Verde |
| `01` | Resta | 1 | 0 | 0 | Rojo |
| `10` | AND | 0 | 0 | 1 | Azul |
| `11` | OR | 1 | 1 | 0 | Amarillo |
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
