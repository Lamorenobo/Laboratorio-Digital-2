`timescale 1ns / 1ps
`include  "../src/alu4bits.v"

module tb_alu;

    reg  [3:0] A;
    reg  [3:0] B;
    reg  [1:0] option;
    wire [3:0] result;

    alu4bits uut (
        .A(A),
        .B(B),
        .option(option),
        .result(result)
    );

    initial begin
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        A = 4'b0101; // 5
        B = 4'b0011; // 3

        // Operación 00: Suma (5 + 3 = 8)
        option = 2'b00; #10;
        
        // Operación 01: Resta (5 - 3 = 2)
        option = 2'b01; #10;

        // Operación 10: AND (0101 & 0011 = 0001)
        option = 2'b10; #10;

        // Operación 11: OR (0101 | 0011 = 0111)
        option = 2'b11; #10;

        // Nuevos operandos
        A = 4'b1100; // 12
        B = 4'b0101; // 5

        option = 2'b00; #10; // Suma (12 + 5 = 17 -> 4 bits: 1)
        option = 2'b01; #10; // Resta (12 - 5 = 7)
        option = 2'b10; #10; // AND (1100 & 0101 = 0100)
        option = 2'b11; #10; // OR (1100 | 0101 = 1101)

        $finish;
    end

endmodule