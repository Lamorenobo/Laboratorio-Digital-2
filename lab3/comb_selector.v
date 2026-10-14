module comb_selector (
    input  wire       clk,          // Reloj principal
    input  wire       rst,          // Reset general
    input  wire       btn_next,     // Pulso al presionar BTN2
    output wire [1:0] read_addr_a,  // Dirección seleccionada para Operando A (0 a 3)
    output wire [1:0] read_addr_b,  // Dirección seleccionada para Operando B (0 a 3)
    output wire [3:0] active_leds   // Salida directa hacia LED[3:0]
);

    // Índice interno de 4 bits (16 estados posibles)
    reg [3:0] index;

    // Transición de estados mediante el botón BTN2
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            index <= 4'b0000;
        end else if (btn_next) begin
            index <= index + 1'b1;
        end
    end

    // Asignación de direcciones
    assign read_addr_a = index[3:2];
    assign read_addr_b = index[1:0];

    // Generación de la máscara de LEDs activos (OR entre decodificadores one-hot)
    assign active_leds = (4'b0001 << read_addr_a) | (4'b0001 << read_addr_b);

endmodule