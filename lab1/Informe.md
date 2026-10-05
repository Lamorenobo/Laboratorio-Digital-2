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

- **Tipo de sistema:** Combinacional puro. No tiene reloj, reset ni registros: las salidas dependen únicamente del valor actual de las entradas.

- **Funcionamiento general:** El circuito forma dos operandos de 4 bits, `A` y `B`, y realiza en paralelo cuatro operaciones sobre ellos:
  1. `AND_result = A & B`
  2. `OR_result  = A | B`
  3. `XOR_result = A ^ B`
  4. `SUM_result = A + B` o `A - B`, según el botón `BTN4`.

  El resultado aritmético se muestra en binario en los 4 LEDs verdes de la Placa Zybo . Los resultados de las operaciones lógicas se resumen en el LED RGB mediante un operador OR (`|`), que enciende el canal correspondiente si el resultado contiene al menos un bit en `1`.


- **Construcción de los operandos:**

  | Operando | Construcción | Fuente física |
  |---|---|---|
  | `A` (4 bits) | `A = sw` | Switches `SW[3:0]` (`SW3` es el MSB) |
  | `B_raw` (4 bits) | `B_raw = btn[3:0]` | Botones `BTN3..BTN0` (`BTN3` es el MSB) |
  | `B` (4 bits) | `B = B_raw ^ {4{btn[5]}}` | `BTN5` invierte (complemento a 1) todos los bits de `B_raw` |

  Los botones son pulsadores, por lo que `B` solo vale lo que indican los botones mientras se mantienen presionados. `A` proviene de los switches y `B` de los botones, de modo que ambas fuentes de entrada intervienen en los operandos.

- **Botones de control:**

  | Botón | Función |
  |---|---|
  | `BTN4` | Selecciona la operación aritmética: `0` → suma (`A + B`), `1` → resta (`A - B`) |
  | `BTN5` | Invierte los 4 bits de `B` antes de operar (`B = ~B_raw`) |

- **Mapeo de salidas:**

  | Salida | Pin físico | Qué muestra |
  |---|---|---|
  | `led[3:0]` | LD3..LD0 (verdes) | Resultado aritmético de 4 bits `SUM_result` .|
  | `y` | LED RGB, canal **Rojo** | `\|AND_result`: se enciende si `A` y `B` tienen al menos un bit `1` en la misma posición |
  | `o` | LED RGB, canal **Verde** | `\|OR_result`: se enciende si `A` o `B` tienen al menos un bit en `1` (se apaga solo si ambos son `0000`) |
  | `xo` | LED RGB, canal **Azul** | `\|XOR_result`: se enciende si `A` y `B` difieren en al menos un bit (se apaga si `A == B`) |

  Como los canales se mezclan en un solo LED, el color observado permite leer las tres banderas a la vez (por ejemplo, rojo + verde = amarillo; rojo + verde + azul = blanco).

- **Asignación de pines (`Zybo-Z7.xdc`):**

  | Puerto | Pin FPGA | Señal en la tarjeta |
  |---|---|---|
  | `sw[0]` / `sw[1]` / `sw[2]` / `sw[3]` | G15 / P15 / W13 / T16 | SW0..SW3 |
  | `btn[0]` / `btn[1]` / `btn[2]` / `btn[3]` | K18 / P16 / K19 / Y16 | BTN0..BTN3 |
  | `btn[4]` / `btn[5]` | T14 / T15 | Botones externos en el conector JD |
  | `led[0]` / `led[1]` / `led[2]` / `led[3]` | M14 / M15 / G14 / D18 | LD0..LD3 |
  | `y` (rojo) / `o` (verde) / `xo` (azul) | V16 / F17 / M17 | LED RGB `led6_r` / `led6_g` / `led6_b` |

- **Diagrama de bloques:**

  ```
   sw[3:0] ──────────────────────────► A ──────┬──► A & B ──► |  ──► y  (R)
                                                │
   btn[3:0] ──► B_raw ──► XOR ─► B ─────────────┼──► A | B ──► |  ──► o  (G)
                           ▲                    │
   btn[5] ─────────────────┘ (invierte B)       ├──► A ^ B ──► |  ──► xo (B)
                                                │
   btn[4] ──► selector ───────────────────────► MUX ◄── A + B
              (0: suma, 1: resta)                    ◄── A - B ──► led[3:0]
  ```

---

### Simulaciones (2)

- **Descripción del testbench:** El archivo `tb_l_aritmetica.v` instancia el módulo `l_aritmetica` (UUT) y aplica 8 combinaciones de entradas con un paso de 10 ns cada una. Las entradas `sw` (4 bits) y `btn` (6 bits) se declaran como `reg`, y las salidas `led`, `y`, `o`, `xo` como `wire`. El vector `btn` se interpreta como `{BTN5, BTN4, BTN3..BTN0}`. Se generan el archivo `tb_l_aritmetica.vcd` (para GTKWave) y un `$monitor` que imprime las señales cada vez que cambian.

- **Señales observadas:** `sw[3:0]`, `btn[5:0]`, `led[3:0]`, `y`, `o` y `xo`.

- **Casos de prueba y resultados esperados:**

  | # | `sw` (A) | `btn` | `B` efectivo | Operación | `led` (4 bits) | `y` | `o` | `xo` |
  |---|---|---|---|---|---|---|---|---|
  | 1 | `0011` (3) | `00_0010` | `0010` (2) | 3 + 2 | `0101` (5) | 1 | 1 | 1 |
  | 2 | `0110` (6) | `00_0001` | `0001` (1) | 6 + 1 | `0111` (7) | 0 | 1 | 1 |
  | 3 | `0100` (4) | `00_0100` | `0100` (4) | 4 + 4 | `1000` (8) | 1 | 1 | 0 |
  | 4 | `0111` (7) | `01_0010` | `0010` (2) | 7 − 2 | `0101` (5) | 1 | 1 | 1 |
  | 5 | `0101` (5) | `01_0101` | `0101` (5) | 5 − 5 | `0000` (0) | 1 | 1 | 0 |
  | 6 | `0110` (6) | `10_0010` | `1101` (13, B invertido) | 6 + 13 | `0011` (3, desbordamiento) | 1 | 1 | 1 |
  | 7 | `0101` (5) | `00_0010` | `0010` (2) | 5 + 2 | `0111` (7) | 0 | 1 | 1 |
  | 8 | `1111` (15) | `00_0001` | `0001` (1) | 15 + 1 | `0000` (0, desbordamiento) | 1 | 1 | 1 |

- **Resultados obtenidos (verificación lógica):**
  - **Suma:** los casos 1, 2, 3 y 7 dan el resultado esperado.
  - **Resta:** los casos 4 y 5 (`BTN4 = 1`) confirman la resta; el caso 5 produce cero (`A == B`), con `xo = 0` coherente con `A ^ B = 0000`.
  - **Inversión de `B` con `BTN5`:** en el caso 6, `B_raw = 0010` pasa a `B = 1101`. Al ser una inversión bit a bit (complemento a 1) y no un complemento a 2, el resultado es `6 + 13 = 19`, que en 4 bits es `0011` (3); **no** equivale a `6 + (−2) = 4`.
  - **Desbordamiento:** en el caso 8 (`15 + 1 = 16`) el resultado se trunca a 4 bits (`0000`) porque el diseño no expone el acarreo.
  - **Banderas RGB:** coinciden con la reducción OR de cada operación lógica en todos los casos (por ejemplo, en el caso 2, `6 & 1 = 0000` apaga el rojo; en el caso 5, `5 ^ 5 = 0000` apaga el azul).

#### Evidencias de Simulación
*(Incluya capturas de pantalla de GTKWave).*

---

### Implementación (2)

- **Organización del código:** Un único módulo combinacional (`l_aritmetica`, en `src/l_aritmetica.v`) que actúa como módulo principal (top) de este ejercicio. Primero se construyen los operandos, luego se calculan las operaciones y finalmente se asignan las salidas. Las operaciones exigidas están presentes de forma explícita en el código:

  | Operación | Línea en el HDL |
  |---|---|
  | **AND** | `wire [3:0] AND_result = A & B;` |
  | **OR** | `wire [3:0] OR_result = A \| B;` |
  | **XOR** | `wire [3:0] XOR_result = A ^ B;` (además, `B_raw ^ {4{btn[5]}}` usa XOR para invertir `B`) |
  | **Suma / Resta** | `wire [3:0] SUM_result = btn[4] ? (A - B) : (A + B);` |

  Código completo:

  ```verilog
  module l_aritmetica (
      input  wire [3:0] sw,
      input  wire [5:0] btn,
      // LED SUMA O RESTA
      output wire [3:0] led,
      // LED RGB
      output wire       y,
      output wire       o,
      output wire       xo
  );

      wire [3:0] A     = sw;
      wire [3:0] B_raw = btn[3:0];
      wire [3:0] B = B_raw ^ {4{btn[5]}}; // invertir bits

      // operaciones lógicas
      wire [3:0] AND_result = A & B;
      wire [3:0] OR_result  = A | B;
      wire [3:0] XOR_result = A ^ B;

      wire [3:0] SUM_result = btn[4] ? (A - B) : (A + B); // se suma o se resta

      // Salidas
      assign led = SUM_result;
      assign y   = |AND_result;  // Rojo:  AND
      assign o   = |OR_result;   // Verde: OR
      assign xo  = |XOR_result;  // Azul:  XOR
  endmodule
  ```

- **Manejo de entradas y salidas:**
  - **Reloj y reset:** no se usan, ya que el diseño es puramente combinacional.
  - **Switches:** `sw[3:0]` forman directamente el operando `A`.
  - **Botones:** `btn[3:0]` forman el operando `B`; `btn[4]` selecciona suma/resta y `btn[5]` invierte `B`. Con esto se usan los 6 botones y los 4 switches.
  - **Salidas:** `led[3:0]` muestran el resultado aritmético; `y`, `o` y `xo` controlan los canales rojo, verde y azul del LED RGB. 

- **Comportamiento esperado del sistema:**
  - Con `BTN4` y `BTN5` sin presionar, los LEDs verdes muestran `A + B`, con `A` fijado en los switches y `B` dado por los botones `BTN0..BTN3` que se mantengan presionados.
  - Al mantener `BTN4`, los LEDs muestran `A − B`.
  - Al mantener `BTN5`, `B` se invierte bit a bit antes de operar.
  - Con todos los switches y botones de datos en cero, el LED RGB queda apagado (las tres reducciones valen `0`).
  - El color del LED RGB indica qué operaciones lógicas tienen resultado distinto de cero: rojo (AND), verde (OR) y azul (XOR), combinables entre sí.


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