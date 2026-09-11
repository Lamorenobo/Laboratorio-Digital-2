    module semaforo(
        input  wire clk,
        input  wire rst,
        output reg [1:0] verde,
        output reg [1:0] amarillo,
        output reg [1:0] rojo

        
    );

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    reg [3:0] contador;
    reg [1:0] estado;



    always @(posedge clk or posedge rst) begin
        if(rst)begin
            estado <= S0;
            contador <= 0;
            // para eliminar las xxx en la simu se inicializan los colores antes
            verde <= 2'b00;
            amarillo <= 2'b00;
            rojo <= 2'b00;
        end
        else begin
            if (estado == S0)begin
                verde = 2'b01;
                amarillo = 2'b00;
                rojo = 2'b00;
                if (contador == 4) begin
                    estado <= S1;
                    contador <= contador + 1;
                end
                    else begin
                        contador <= contador + 1;
                    end
            end

            if (estado == S1)begin
                verde = 2'b00;
                amarillo = 2'b01;
                rojo = 2'b00;
                if (contador == 6) begin
                    estado <= S2;
                    contador <= contador + 1;
                end
                else begin
                        contador <= contador + 1;
                    end
                if (contador ==  12) begin
                    estado <= S0;
                    contador <= contador + 1;
                end
            end
            
            if (estado == S2)begin
                verde = 2'b00;
                amarillo = 2'b00;
                rojo = 2'b01;
                if (contador == 10) begin
                    estado <= S1;
                    contador <= contador + 1;
                end
                    else begin
                        contador <= contador + 1;
                    end
            end
        end
    end

    endmodule