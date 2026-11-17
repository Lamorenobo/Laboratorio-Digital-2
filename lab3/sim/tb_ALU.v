`timescale 1ns / 1ps

module tb_ALU;

    // Testbench signals
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [2:0] op;
    wire [3:0] result;

    // Instantiate Unit Under Test (UUT)
    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    initial begin
        // Generate VCD wave file for GTKWave inspection
        $dumpfile("ALU.vcd");
        $dumpvars(0, tb_ALU);

        // Print header to terminal
        $display("Time\t Op\t A\t B\t Result");
        $monitor("%0dt\t %b\t %b\t %b\t %b", $time, op, a, b, result);

        // Initial state
        a = 4'b0000; b = 4'b0000; op = 3'b000; #10;

        // Op 000: Addition (4 + 3 = 7 -> 0111)
        a = 4'b0100; b = 4'b0011; op = 3'b000; #10;

        // Op 001: Subtraction (9 - 4 = 5 -> 0101)
        a = 4'b1001; b = 4'b0100; op = 3'b001; #10;

        // Op 010: Bitwise AND (1100 & 1010 = 1000)
        a = 4'b1100; b = 4'b1010; op = 3'b010; #10;

        // Op 011: Bitwise OR (1100 | 1010 = 1110)
        a = 4'b1100; b = 4'b1010; op = 3'b011; #10;

        // Op 100: Bitwise XOR (1100 ^ 1010 = 0110)
        a = 4'b1100; b = 4'b1010; op = 3'b100; #10; // Corregido espacio

        // Op 101: Bitwise NOT A (~1100 = 0011)
        a = 4'b1100; b = 4'b0000; op = 3'b101; #10;

        // Op 110: Shift Left A (0011 << 1 = 0110)
        a = 4'b0011; b = 4'b0000; op = 3'b110; #10;

        // Op 111: Shift Right A (1100 >> 1 = 0110)
        a = 4'b1100; b = 4'b0000; op = 3'b111; #10;

        $finish;
    end

endmodule