`timescale 1ns / 1ps

module tb_comb_selector;

    reg        clk;
    reg        rst;
    reg        btn_next;

    wire [1:0] read_addr_a;
    wire [1:0] read_addr_b;
    wire [3:0] active_leds;

    // Instanciación del UUT
    comb_selector uut (
        .clk(clk),
        .rst(rst),
        .btn_next(btn_next),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .active_leds(active_leds)
    );

    // Reloj de 100 MHz (10 ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("comb_selector.vcd");
        $dumpvars(0, tb_comb_selector);

        clk = 0;
        rst = 1;
        btn_next = 0;

        #10;
        rst = 0;
        #10;

        // Simular 16 pulsaciones de BTN2 para verificar la vuelta completa de combinaciones
        repeat (16) begin
            btn_next = 1; #10; // Pulso de 1 ciclo
            btn_next = 0; #20; // Espera
        end

        $finish;
    end

endmodule