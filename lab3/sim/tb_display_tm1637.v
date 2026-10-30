`timescale 1ns/1ps
`include "src\tm1637_driver.v"
module tb_tm1637_driver;


    reg  clk = 0;
    reg  rst = 1;
    wire tm_clk;
    wire dio;
    wire ack_err;


    always #5 clk = ~clk;


    pullup(dio);

    tm1637_driver #(
        .CLK_HZ (1_000_000),
        .TICK_HZ(250_000)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .seg0   (8'h06),   // '1'
        .seg1   (8'h5B),   // '2'
        .seg2   (8'h4F),   // '3'
        .seg3   (8'h66),   // '4'
        .brillo (3'd5),
        .tm_clk (tm_clk),
        .tm_dio (dio),
        .ack_err(ack_err)
    );


    reg       ack_low = 0;     
    reg [7:0] byte_rx = 0;     
    integer   bit_cnt = 0;     
    integer   n_stop  = 0;     

    assign dio = ack_low ? 1'b0 : 1'bz;

    // START: DIO baja mientras CLK está en 1
    always @(negedge dio) if (tm_clk === 1'b1) begin
        $display("%t  START", $time);
        bit_cnt = 0;
    end

    // STOP: DIO sube mientras CLK está en 1
    always @(posedge dio) if (tm_clk === 1'b1) begin
        $display("%t  STOP", $time);
        bit_cnt = 0;
        n_stop  = n_stop + 1;
    end


    always @(posedge tm_clk) if (bit_cnt < 8) begin
        byte_rx[bit_cnt] = dio;
        bit_cnt = bit_cnt + 1;
    end

    always @(negedge tm_clk) begin
        if (ack_low) begin
            ack_low = 0;
            bit_cnt = 0;
        end else if (bit_cnt == 8) begin
            $display("%t     byte recibido: 0x%h", $time, byte_rx);
            ack_low = 1;
        end
    end

    // ---------------- Secuencia de la prueba ----------------
    initial begin
        $timeformat(-9, 0, " ns", 9);
        $dumpfile("tb_tm1637_driver.vcd");
        $dumpvars(0, tb_tm1637_driver);

        #50 rst = 0;                 

        wait (n_stop == 3);      
        #100;

        if (ack_err) $display("FALLO: el driver no vio el ACK");
        else         $display("OK: refresco completo y todos los ACK correctos");
        $finish;
    end

    // Seguridad: si algo se cuelga, terminar igual
    initial begin
        #200_000;
        $display("TIMEOUT: no se completaron los 3 STOP");
        $finish;
    end

endmodule