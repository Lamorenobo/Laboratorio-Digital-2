# Laboratorio 00: TÍTULO DEL LABORATORIO

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

- [Descripción General del Proyecto](#descripción-general-del-proyecto)
- [Evidencia del Smoke Test](#evidencia-del-smoke-test-programación-exitosa)
- [Parte 1: Ejercicio 1](#parte-1-ejercicio-1)
  - [Diseño implementado](#diseño-implementado-1)
  - [Simulaciones](#simulaciones-1)
  - [Implementación y Código Verilog](#implementación-y-código-verilog-1)
- [Parte 2](#parte-2)
  - [Diseño implementado](#diseño-implementado-2)
  - [Simulaciones](#simulaciones-2)
  - [Implementación](#implementación-2)
- [Evidencias de Funcionamiento en Hardware](#evidencias-de-funcionamiento-en-hardware-foto--video)
- [Conclusiones](#conclusiones)
- [Referencias](#referencias)

---

## Descripción General del Proyecto

Describa brevemente el objetivo global de la práctica de laboratorio.

---

## Evidencia del Smoke Test (Programación Exitosa)

Incluya aquí la captura de pantalla o evidencia que confirme que la tarjeta FPGA/Board fue programada correctamente sin errores durante el proceso de compilación y sintaxis.

---

## Parte 1: Ejercicio 1

### Diseño implementado (1)

Describa el diseño realizado para el Ejercicio 1:

- **Tipo de sistema:** (por ejemplo: Combinacional, FSM, FSM + datapath).
- **Funcionamiento general:** Explicación detallada del circuito.
- **Construcción de los operandos:** Explique explícitamente cómo se forman los operandos $A$ y $B$ a partir de las entradas físicas (switches y botones).
- **Mapeo de salidas:** Explique qué muestra cada LED (salidas `led`, `y`, `o`, `xo`).
- **Diagrama de estados / Bloques:** (Si aplica, agregue el diagrama).

---

### Simulaciones (1)

Describa las simulaciones realizadas para verificar el funcionamiento del Ejercicio 1.

- **Descripción del testbench:** Señales de prueba generadas.
- **Señales observadas:** Variables analizadas.
- **Resultados obtenidos:** Verificación lógica.

#### Evidencias de Simulación
*(Incluya capturas de pantalla de GTKWave donde se evidencie el correcto funcionamiento de las operaciones).*

---

### Implementación y Código Verilog (1)

Explique cómo se implementó el diseño en Verilog.

- **Organización del código:**
  - Identifique la presencia real de las operaciones **AND**, **OR**, **XOR** y **Suma/Resta** en el código.
- **Manejo de entradas y salidas:** Explicación de puertos de reloj, reset, switches y botones.
- **Comportamiento esperado del sistema:** Descripción del resultado al interactuar con el circuito.

> **Nota:** El código fuente completo debe encontrarse en la carpeta `src/`.

---

## Parte 2

### Diseño implementado (2)

Describa brevemente los diseños realizados en esta segunda sección.

- **Tipo de sistema:** (FSM, FSM + datapath, etc.).
- **Estados definidos:** Breve resumen de la lógica de estados.
- **Funcionamiento general del sistema.**

*(Incluya el diagrama de la máquina de estados si aplica).*

---

### Simulaciones (2)

Describa las simulaciones realizadas para la Parte 2.

- **Descripción del testbench.**
- **Señales observadas.**
- **Resultados obtenidos.**

#### Evidencias de Simulación
*(Incluya capturas de pantalla de GTKWave).*

---

### Implementación (2)

Explique la implementación en Verilog de la Parte 2.

- **Organización del código.**
- **Manejo de reloj y reset.**
- **Comportamiento esperado.**

> **Nota:** El código fuente debe encontrarse en la carpeta `src/`.

---

## Evidencias de Funcionamiento en Hardware (Foto / Video)

Muestre fotos o enlaces a vídeos donde se demuestre el circuito funcionando sobre la tarjeta física:

- [ ] **Funcionamiento correcto** de las operaciones planteadas.
- [ ] **Uso de todas las entradas** (demostración con switches y botones).
- [ ] **Uso de todas las salidas** (comprobación del encendido de los LEDs).

---

## Conclusiones

- Principales aprendizajes del laboratorio.
- Dificultades encontradas durante la implementación.
- Importancia de la simulación en el diseño digital.

---

## Referencias

- Documentación de la tarjeta FPGA / Tarjeta de desarrollo utilizada.
- Manual de sintaxis de Verilog HDL.