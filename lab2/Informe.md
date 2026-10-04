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

Describa de manera clara y concisa el propósito general del diseño realizado en este laboratorio, su funcionamiento global y cómo interactúa con el usuario a través de las entradas y salidas de la tarjeta FPGA.

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