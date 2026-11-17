
module display_tm1637 #(
    parameter integer CLK_HZ = 125_000_000   // reloj de la Zybo Z7
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] data_in,
    input  wire       mode_sel,
    output wire       clk_tm1637,
    inout  wire       dio
);
 
    localparam [7:0] UNO  = 8'h06,   // segmentos b, c
                     CERO = 8'h3F,
                     APAG = 8'h00;
 
    wire       hay_decena = (data_in >= 4'd10);
    wire [3:0] unidades   = hay_decena ? (data_in - 4'd10) : data_in;
    wire [6:0] s_uni;
 
    hex7seg h_uni (.hex(unidades), .seg(s_uni));
 

    reg [7:0] d0, d1, d2, d3;
 
    always @(*) begin
        if (mode_sel) begin
            d0 = data_in[3] ? UNO : CERO;
            d1 = data_in[2] ? UNO : CERO;
            d2 = data_in[1] ? UNO : CERO;
            d3 = data_in[0] ? UNO : CERO;
        end else begin
            d0 = APAG;
            d1 = APAG;
            d2 = hay_decena ? UNO : APAG;
            d3 = {1'b0, s_uni};
        end
    end
 
    // ---------------- Driver del protocolo ----------------
    tm1637_driver #(.CLK_HZ(CLK_HZ)) u_drv (
        .clk    (clk),
        .rst    (rst),
        .seg0   (d0),
        .seg1   (d1),
        .seg2   (d2),
        .seg3   (d3),
        .brillo (3'd5),
        .tm_clk (clk_tm1637),
        .tm_dio (dio),
        .ack_err()           
    );
 
endmodule