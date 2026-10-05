`timescale 1ns / 1ps

module Semaforo(
    input clk,
    output reg [2:0] led
);

    integer counter = 0;

    // Incremento del contador
    always @(posedge clk) begin
        if (counter >= 400)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // Máquina de estados / Control de LEDs
    always @(posedge clk) begin
        if (counter == 0)
            led <= 3'b001;      // Rojo
        else if (counter == 100)
            led <= 3'b011;      // Amarillo
        else if (counter == 200)
            led <= 3'b010;      // Verde
        else if (counter == 300)
            led <= 3'b011;      // Amarillo
    end

endmodule