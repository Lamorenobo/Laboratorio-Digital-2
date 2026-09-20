`timescale 1ns / 1ps


//funciona igual que acumulador 1 lo que varia es la condicion para pasar del add al done
module acumulador2 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] x,
    output reg [5:0] acc,
    output reg done
);

    // Definición de estados
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam ADD  = 2'b10;
    localparam DONE = 2'b11;

    // Registro de estado
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            acc <= 6'd0;
            done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0; // Asegurar que done esté en 0
                    if (start) begin
                        state <= LOAD;
                    end
                end
                
                LOAD: begin
                    acc <= 6'd0;  // Inicializa el acumulador en cero
                    state <= ADD;
                end
                
                ADD: begin
                    acc <= acc + x; // Acumula el valor de x
                    
                    // Si el valor que se está guardando es mayor o igual a 20, terminamos
                    if ((acc + x) >= 6'd20) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1'b1;  // Activa la señal done por un ciclo
                    state <= IDLE; // Retorna a IDLE en el siguiente ciclo
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule