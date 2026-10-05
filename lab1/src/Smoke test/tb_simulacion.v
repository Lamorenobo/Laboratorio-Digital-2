`timescale 1ns / 1ps
`include "simulacion.v"

module tb_Semaforo;

    reg clk;
    wire [2:0] led;

    // Instancia del módulo
    Semaforo uut (
        .clk(clk),
        .led(led)
    );

    // Generador de reloj (Período de 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Control de la simulación
    initial begin
        $dumpfile("tb_simulacion.vcd");
        $dumpvars(0, tb_Semaforo);

        // Duración suficiente para ver más de un ciclo completo (5000 ns)
        #5000;
        $finish;
    end

endmodule