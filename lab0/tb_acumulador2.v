`timescale 1ns / 1ps
`include "acumulador2.v"
module tb_acumulador2;

    // Entradas del DUT
    reg clk;
    reg rst;
    reg start;
    reg [3:0] x;

    // Salidas del DUT
    wire [5:0] acc;
    wire done;

    // Instanciación del módulo
    acumulador2 uut (
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
        $dumpfile("acumulador2.vcd");
        $dumpvars(0, tb_acumulador2);

        // Inicialización de señales
        clk = 0;
        rst = 1;
        start = 0;
        x = 4'd0;

        // Liberar reset después de 15ns
        #15 rst = 0;
        
        // ----------------------------------------------------
        // Prueba 1: Sumar x = 6 (Acumulará 6, 12, 18, 24)
        // ----------------------------------------------------
        #10;
        x = 4'd6;
        start = 1;
        #10 start = 0; // Pulso de inicio
        
        wait(done == 1'b1);
        $display("Prueba 1 Terminada. Resultado acc = %d (Esperado: 24)", acc);
        
        #20;

        // ----------------------------------------------------
        // Prueba 2: Sumar x = 5 (Acumulará 5, 10, 15, 20)
        // ----------------------------------------------------
        x = 4'd5;
        start = 1;
        #10 start = 0;
        
        wait(done == 1'b1);
        $display("Prueba 2 Terminada. Resultado acc = %d (Esperado: 20)", acc);
        
        #30;
        
        // Finalizar simulación
        $finish;
    end

endmodule