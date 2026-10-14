module alu (
    input  wire [3:0] a,        // Operand A (4 bits)
    input  wire [3:0] b,        // Operand B (4 bits)
    input  wire [2:0] op,       // Operation selection SW[2:0]
    output reg  [3:0] result    // ALU Result (4 bits)
);

    always @(*) begin
        case (op)
            3'b000: result = a + b;       // Addition
            3'b001: result = a - b;       // Subtraction
            3'b010: result = a & b;       // Bitwise AND
            3'b011: result = a | b;       // Bitwise OR
            3'b100: result = a ^ b;       // Bitwise XOR
            3'b101: result = ~a;          // Bitwise NOT A
            3'b110: result = a << 1;      // Logical Shift Left A
            3'b111: result = a >> 1;      // Logical Shift Right A
            default: result = 4'b0000;
        endcase
    end

endmodule