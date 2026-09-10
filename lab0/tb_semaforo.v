`timescale 1ns/1ps
`include "semaforo1.v"

module tb_semaforo;

    // Señales del testbench
    reg clk;
    reg rst;

    wire [1:0] verde;
    wire [1:0] amarillo;
    wire [1:0] rojo;

    // Instancia del módulo a probar
    semaforo uut (
        .clk(clk),
        .rst(rst),
        .verde(verde),
        .amarillo(amarillo),
        .rojo(rojo)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Secuencia de prueba
    initial begin

        // Inicialización
        clk = 0;
        rst = 1;

        // Mantener reset durante 20 ns
        #20;
        rst = 0;

        // Dejar correr la simulación
        #200;

        // Finalizar
        $finish;
    end

    // Mostrar valores en consola
    initial begin
    // Generación del archivo de ondas
    $dumpfile("semaforo1.vcd");
    $dumpvars(0, tb_semaforo);

        $monitor("Tiempo = %0t | rst = %b | estado = %b | contador = %d | verde = %b | amarillo = %b | rojo = %b",
                 $time,
                 rst,
                 uut.estado,
                 uut.contador,
                 verde,
                 amarillo,
                 rojo);
    end

endmodule
