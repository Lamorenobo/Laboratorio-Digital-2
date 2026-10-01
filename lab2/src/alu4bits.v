`timescale 1ns / 1ps

module alu_4bits (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [1:0] option,
    output reg  [3:0] result
);

    always @(*) begin
        case (option)
            2'b00: result = A + B;       // add
            2'b01: result = A - B;       // sub
            2'b10: result = A & B;       // AND
            2'b11: result = A | B;       // OR
            default: result = 4'b0000;
        endcase
    end

endmodule