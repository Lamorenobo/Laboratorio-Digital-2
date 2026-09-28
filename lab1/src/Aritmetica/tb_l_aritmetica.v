`timescale 1ns / 1ps
`include "l_aritmetica.v"

module tb_l_aritmetica;

    reg [3:0] sw;
    reg [5:0] btn;
    wire [3:0] led;
    wire y;
    wire o;
    wire xo;

    l_aritmetica uut (  
        .sw(sw),
        .btn(btn),
        .led(led),
        .y(y),
        .o(o),
        .xo(xo)
    );


    initial begin
        // btn = {BTN5, BTN4, B[3:0]}
 
        sw = 4'b0011; btn = 6'b00_0010; #10;  // 3 + 2 = 5
        sw = 4'b0110; btn = 6'b00_0001; #10;  // 6 + 1 = 7
        sw = 4'b0100; btn = 6'b00_0100; #10;  // 4 + 4 = 8
        sw = 4'b0111; btn = 6'b01_0010; #10;  // 7 - 2 = 5
        sw = 4'b0101; btn = 6'b01_0101; #10;  // 5 - 5 = 0
        sw = 4'b0110; btn = 6'b10_0010; #10;  // 6 + (-2) = 4
        sw = 4'b0101; btn = 6'b00_0010; #10;  // 5 + 2 = 7
        sw = 4'b1111; btn = 6'b00_0001; #10;  // 15z + 1 = 16
 
        $finish;
    end


    initial begin
        $dumpfile("tb_l_aritmetica.vcd");
        $dumpvars(0, tb_l_aritmetica);

        $monitor("Time: %0dns, SW: %b, BTN: %b, LED: %b, Y: %b, O: %b, XO: %b", 
                  $time, sw, btn, led, y, o, xo);
    end

endmodule