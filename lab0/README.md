# Lab00: Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)

**Grupo:** G4
**Integrantes:**
- Jana Rubbiano Hurtado
- Alina Idaly Ortiz Martinez
- Johana
- Laura Alejandra Moreno

---

## 1. Objetivos del Laboratorio
- Diseñar e implementar Máquinas de Estados Finitos (FSM) sencillas en Verilog.
- Validar el comportamiento de los diseños mediante testbench y visualización de señales en GTKWave.

---

## 2. Estructura del Repositorio
La carpeta `src/` contiene todos los archivos fuente en Verilog y sus respectivos testbenches para los ejercicios desarrollados:

* `semaforo1.v` / `tb_semaforo1.v` (Ejercicio 1)
* `acumulador.v` / `tb_acumulador.v` (Ejercicio 2, variante 1)
* `acumulador.v` / `tb_acumulador.v` (Ejercicio 2, variante con limite de acumulación)


---

## 3. Desarrollo de los Ejercicios

### Ejercicio 1: FSM de control – Semáforo simple
**Descripción:** 
Se diseñó un semáforo vehicular controlado por una FSM de tres estados (`Verde: S0`, `Amarillo: S1`, `Rojo: S2`). 
* .

![Maquina de estados semáforo](Imagenes/Maquina_de_estados1.jpeg)

El semáforo se implementó como una máquina de estados finitos de tipo Moore con tres estados. Se apoya en un contador (C) que marca la duración de cada luz y que también permite decidir la siguiente transición. El sistema es síncrono con el flanco de subida del reloj (clk) y tiene un reset asíncrono activo en alto (rst). Al activarse el reset, la máquina va al estado S0, el contador toma el valor 0 y se reinicia.

Se implementaron tres estados, S0=verde, S1=amarillo, S2=rojo, los cuales funcionaban a 5, 2 y 4 ciclos respectivamente, reiniciando el contador a 0 tras pasar por todos los ciclos y así evitar que el contador se desborde. 

**Codigo elaborado:** 
En cuanto al codigo se definieron las entradas que en este caso serian el *rst* y el *clk*, se crearon ademas las salidas para cada color, y se definieron los parametros locales y registros necesarios para manejar los cambios entre  estados todo con el fin del correcto funcionamiento del diseño.

```verilog
    module semaforo(
        input  wire clk,
        input  wire rst,
        output reg [1:0] verde,
        output reg [1:0] amarillo,
        output reg [1:0] rojo

        
    );

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    reg [3:0] contador;
    reg [1:0] estado;
```

Toda la lógica está en un único bloque always que se ejecuta en el flanco de subida del reloj o del reset. Como rst aparece en la lista de sensibilidad, el reset es asíncrono: actúa en cuanto se activa, sin esperar al reloj. Al activarse, la máquina pasa a S0, el contador vuelve a 0 y todas las luces se apagan.

```verilog
always @(posedge clk or posedge rst) begin
    if(rst)begin
        estado <= S0;
        contador <= 0;
        verde <= 2'b00;
        amarillo <= 2'b00;
        rojo <= 2'b00;
    end
```

A continuación se describen los tres estados, utilizando el operador no bloqueante <= para que todos los registros fueran actualizados al mismo timpo que el flanco, modelando asi correctamente el comportamiento de los flip-flops.

```verilog
            if (estado == S1)begin
                verde = 2'b00;
                amarillo <= 2'b01;
                rojo <= 2'b00;
                if (contador == 6) begin
                    estado <= S2;
                    contador <= contador + 1;
                end
                else begin
                        contador <= contador + 1;
                    end
                if (contador ==  12) begin
                    estado <= S0;
                    contador <= 0;
                end
            end

```

Según la máquina de estados, cuando el contador alcanza el valor 10 en el estado S2, la máquina regresa al estado S1 para la segunda fase de amarillo, con el contador en 11. Cuando el contador llega a 12, la máquina pasa a S0 y el contador se reinicia a 0 mediante la asignación contador <= 0. Este reinicio es importante porque hace que el verde vuelva a durar 5 ciclos y que el proceso del semáforo se repita siempre con los mismos tiempos. Sin él, el contador se desbordaría de 15 a 0 y el verde duraría 8 ciclos.

#### Simulaciones 


![Simulación semaforo](Imagenes/Sim1.png)

El testbench genera un reloj de 10 ns de periodo y mantiene el reset activo durante los primeros ns. En ese intervalo las tres luces permanecen en 00, porque el bloque de reset las inicializa y así se evita que aparezcan valores indefinidos.

La secuencia de luces es verde, amarillo, rojo, amarillo y de nuevo verde, que coincide con la máquina de estados diseñada. En ningún instante hay dos luces encendidas a la vez: cada vez que una luz se apaga, la siguiente se enciende en el mismo flanco de reloj.
