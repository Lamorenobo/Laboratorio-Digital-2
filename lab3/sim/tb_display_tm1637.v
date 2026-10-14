`timescale 1ns / 1ps

module tb_display_tm1637;

    reg        clk;
    reg        rst;
    reg  [3:0] data_in;
    reg        mode_sel;

    wire       clk_tm1637;
    wire       dio;

    // Instanciación del módulo
    display_tm1637 uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .mode_sel(mode_sel),
        .clk_tm1637(clk_tm1637),
        .dio(dio)
    );

    // Reloj principal de 100 MHz (10 ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("display_tm1637.vcd");
        $dumpvars(0, tb_display_tm1637);

        clk = 0;
        rst = 1;
        data_in = 4'b0000;
        mode_sel = 0; // Iniciar en modo Decimal

        #20;
        rst = 0;
        #20;

        // Probar Decimal con 13 (4'b1101) -> Esperado: Decena 1, Unidad 3
        data_in = 4'b1101; 
        #50000;

        // Cambiar a Modo Binario con 13 (4'b1101) -> Esperado: 1 1 0 1 en los 4 dígitos
        mode_sel = 1; 
        #50000;

        // Probar Modo Binario con 6 (4'b0110) -> Esperado: 0 1 1 0
        data_in = 4'b0110;
        #50000;

        $finish;
    end

endmodule