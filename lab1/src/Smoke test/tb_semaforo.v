`timescale 1ns / 1ps
`include "semaforo.v"

module tb_Semaforo;

    reg clk;
    wire [2:0] led;

    Semaforo uut (
        .clk(clk),
        .led(led)
    );

    initial begin
        clk = 0;
        forever #4 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_Semaforo.vcd");
        $dumpvars(0, tb_Semaforo);

        #100000;
        $finish;
    end

endmodule