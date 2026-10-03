`timescale 1ns / 1ps

module alu4bits (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [1:0] option,
    output wire [3:0] result
);

    assign result = (option == 2'b00) ? (A + B) :
                    (option == 2'b01) ? (A - B) :
                    (option == 2'b10) ? (A & B) :
                    (option == 2'b11) ? (A | B) :
                    4'b0000;

endmodule