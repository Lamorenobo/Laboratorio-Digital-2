`timescale 1ns / 1ps
`include "acumulador.v"

module tb_acumulador;

    // Entradas del DUT (Device Under Test)
    reg clk;
    reg rst;
    reg start;
    reg [3:0] x;

    // Salidas del DUT
    wire [5:0] acc;
    wire done;

    // Instanciación del módulo
    acumulador uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x(x),
        .acc(acc),
        .done(done)
    );

    // Generación del reloj (Periodo de 10ns)
    always #5 clk = ~clk;

    initial begin
        // Generación de archivos para GTKWave
        $dumpfile("acumulador.vcd");
        $dumpvars(0, tb_acumulador);

        // Inicialización de señales
        clk = 0;
        rst = 1;
        start = 0;
        x = 4'd0;

        // Liberar reset después de 15ns
        #15 rst = 0;
        
        // ----------------------------------------------------
        // Prueba 1: Sumar x = 5 (El resultado debe ser 15)
        // ----------------------------------------------------
        #10;
        x = 4'd5;
        start = 1;
        #10 start = 0; // start debe ser un pulso de un ciclo
        
        // Esperar a que el módulo termine (done == 1)
        wait(done == 1'b1);
        $display("Prueba 1 Terminada. Resultado acc = %d (Esperado: 15)", acc);
        
        #20; // Esperar un poco antes de la siguiente prueba

        // ----------------------------------------------------
        // Prueba 2: Sumar x = 7 (El resultado debe ser 21)
        // ----------------------------------------------------
        x = 4'd7;
        start = 1;
        #10 start = 0;
        
        wait(done == 1'b1);
        $display("Prueba 2 Terminada. Resultado acc = %d (Esperado: 21)", acc);
        
        #30;
        
        // Finalizar simulación
        $finish;
    end

endmodule