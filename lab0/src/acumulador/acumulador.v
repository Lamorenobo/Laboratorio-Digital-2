`timescale 1ns / 1ps

module acumulador (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] x,
    output reg [5:0] acc,
    output reg done
);

    // Definición de estados usando localparam
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam ADD  = 2'b10;
    localparam DONE = 2'b11;

    // Registros internos
    reg [1:0] state;
    reg [1:0] count; // Contador para saber cuántas veces hemos sumado

    // Parámetro para la variante aca puede ser 3 o 4.
    localparam MAX_ADDS = 3; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            acc <= 6'd0;
            count <= 2'd0;
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
                    count <= 2'd0; // Reinicia el contador
                    state <= ADD;
                end
                
                ADD: begin
                    acc <= acc + x; // Acumula el valor de x
                    count <= count + 1;
                    
                    // Si ya sumamos la cantidad de veces deseada, pasamos a DONE
                    if (count == MAX_ADDS - 1) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1'b1; // Activa la señal done por un ciclo
                    state <= IDLE; // Retorna a IDLE en el siguiente ciclo
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule