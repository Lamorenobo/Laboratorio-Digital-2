`timescale 1ns / 1ps

module tb_reg_bank;

    // Entradas del UUT
    reg        clk;
    reg        rst;
    reg        write_enable;
    reg  [1:0] write_addr;
    reg  [3:0] write_data;
    reg  [1:0] read_addr_a;
    reg  [1:0] read_addr_b;

    // Salidas del UUT
    wire [3:0] read_data_a;
    wire [3:0] read_data_b;

    // Instanciación del módulo
    reg_bank uut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .read_data_a(read_data_a),
        .read_data_b(read_data_b)
    );

    // Generador de Reloj (Período de 10ns -> 100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Archivo de ondas para GTKWave
        $dumpfile("reg_bank.vcd");
        $dumpvars(0, tb_reg_bank);

        // Estado inicial
        clk = 0;
        rst = 1;
        write_enable = 0;
        write_addr = 2'b00;
        write_data = 4'b0000;
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;

        #10;
        rst = 0; // Liberar reset
        #10;

        // 1. Escribir 5 (4'b0101) en R0
        write_addr = 2'b00;
        write_data = 4'b0101;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // 2. Escribir 10 (4'b1010) en R1
        write_addr = 2'b01;
        write_data = 4'b1010;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // 3. Escribir 15 (4'b1111) en R2
        write_addr = 2'b10;
        write_data = 4'b1111;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;

        // 4. Probar lectura simultánea (Puerto A = R0, Puerto B = R1)
        read_addr_a = 2'b00; // Esperado: 0101
        read_addr_b = 2'b01; // Esperado: 1010
        #10;

        // 5. Cambiar direcciones de lectura (Puerto A = R2, Puerto B = R0)
        read_addr_a = 2'b10; // Esperado: 1111
        read_addr_b = 2'b00; // Esperado: 0101
        #10;

        // 6. Probar intento de escritura con write_enable = 0 (El dato no debe cambiar)
        write_addr = 2'b11;
        write_data = 4'b0011;
        write_enable = 0;
        #10;

        $finish;
    end

endmodule