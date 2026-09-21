
module l_aritmetica (
    input  wire [3:0] sw,
    input  wire [5:0] btn,
    output wire [3:0] led,
    output wire       y,
    output wire       o,
    output wire       xo
);

    wire [3:0] A     = sw;
    wire [3:0] B_raw = btn[3:0];


    wire [3:0] B = B_raw ^ {4{btn[5]}}; //invertir bits

    // operaciones lógicas
    wire [3:0] AND_result = A & B;
    wire [3:0] OR_result  = A | B;
    wire [3:0] XOR_result = A ^ B;

    wire [3:0] SUM_result = btn[4] ? (A - B) : (A + B); // se suma o se resta

    // Salidas
    assign led   = SUM_result;
    assign y = |AND_result;   // Rojo:  AND
    assign o = |OR_result;    // Verde: OR 
    assign xo = |XOR_result;   // Azul:  XOR 

endmodule