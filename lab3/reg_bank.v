module reg_bank (
    input  wire       clk,          // Reloj del sistema
    input  wire       rst,          // Reset general
    input  wire       write_enable, // Habilitador de escritura (accionado por BTN1)
    input  wire [1:0] write_addr,   // Selección del registro a escribir (BTN0)
    input  wire [3:0] write_data,   // Dato a escribir proveniente de SW[3:0]
    input  wire [1:0] read_addr_a,  // Dirección del Registro A (generado por comb_selector)
    input  wire [1:0] read_addr_b,  // Dirección del Registro B (generado por comb_selector)
    output wire [3:0] read_data_a,  // Dato de salida del Operando A hacia la ALU
    output wire [3:0] read_data_b   // Dato de salida del Operando B hacia la ALU
);

    // Banco de 4 registros de 4 bits cada uno (R0, R1, R2, R3)
    reg [3:0] registers [0:3];

    integer i;

    // Proceso de Escritura (Sincrónico)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                registers[i] <= 4'b0000;
            end
        end else if (write_enable) begin
            registers[write_addr] <= write_data;
        end
    end

    // Proceso de Lectura (Asincrónico/Combinacional)
    assign read_data_a = registers[read_addr_a];
    assign read_data_b = registers[read_addr_b];

endmodule