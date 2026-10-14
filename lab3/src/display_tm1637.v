module display_tm1637 (
    input  wire       clk,        // Reloj del sistema (100 MHz)
    input  wire       rst,        // Reset general
    input  wire [3:0] data_in,    // Resultado latcheado de la ALU (4 bits)
    input  wire       mode_sel,   // 0 = Decimal, 1 = Binario
    output reg        clk_tm1637, // Salida CLK hacia el display TM1637
    inout  wire       dio         // Salida/Entrada DIO hacia el display TM1637
);

    // -------------------------------------------------------------------------
    // 1. Decodificador de 7 Segmentos (A-G: bit 0=A, 1=B, 2=C, 3=D, 4=E, 5=F, 6=G)
    // -------------------------------------------------------------------------
    function [7:0] get_segment;
        input [3:0] digit;
        begin
            case (digit)
                4'h0: get_segment = 8'b0011_1111; // '0'
                4'h1: get_segment = 8'b0000_0101; // '1'
                4'h2: get_segment = 8'b0101_1011; // '2'
                4'h3: get_segment = 8'b0100_1111; // '3'
                4'h4: get_segment = 8'b0110_0110; // '4'
                4'h5: get_segment = 8'b0110_1101; // '5'
                4'h6: get_segment = 8'b0111_1101; // '6'
                4'h7: get_segment = 8'b0000_0111; // '7'
                4'h8: get_segment = 8'b0111_1111; // '8'
                4'h9: get_segment = 8'b0110_1111; // '9'
                default: get_segment = 8'b0000_0000; // Apagado
            endcase
        end
    endfunction

    // Pattern de los 4 dígitos a transmitir
    reg [7:0] digit0_pat, digit1_pat, digit2_pat, digit3_pat;

    always @(*) begin
        if (mode_sel) begin
            // --- MODO BINARIO: Muestra cada bit en un dígito ---
            digit3_pat = data_in[3] ? get_segment(4'h1) : get_segment(4'h0);
            digit2_pat = data_in[2] ? get_segment(4'h1) : get_segment(4'h0);
            digit1_pat = data_in[1] ? get_segment(4'h1) : get_segment(4'h0);
            digit0_pat = data_in[0] ? get_segment(4'h1) : get_segment(4'h0);
        end else begin
            // --- MODO DECIMAL: Decenas y Unidades ---
            digit3_pat = 8'b0000_0000; // Apagado
            digit2_pat = 8'b0000_0000; // Apagado
            
            if (data_in >= 4'd10) begin
                digit1_pat = get_segment(4'h1);            // Decena '1'
                digit0_pat = get_segment(data_in - 4'd10); // Unidad
            end else begin
                digit1_pat = 8'b0000_0000;                 // Apagado si es < 10
                digit0_pat = get_segment(data_in);         // Unidad
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2. Divisor de Reloj para TM1637 (~50 kHz a partir de 100 MHz)
    // -------------------------------------------------------------------------
    reg [10:0] clk_divider;
    reg        tick_tm1637;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_divider <= 0;
            tick_tm1637 <= 0;
        end else if (clk_divider == 11'd1000) begin
            clk_divider <= 0;
            tick_tm1637 <= 1;
        end else begin
            clk_divider <= clk_divider + 1'b1;
            tick_tm1637 <= 0;
        end
    end

    // -------------------------------------------------------------------------
    // 3. Máquina de Estados (FSM) de transmisión serie TM1637
    // -------------------------------------------------------------------------
    reg dio_out;
    reg dio_dir; // 1 = Salida, 0 = Alta impedancia (Entrada/ACK)
    assign dio = dio_dir ? dio_out : 1'bz;

    reg [7:0] state;
    reg [7:0] current_byte;
    reg [3:0] bit_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            clk_tm1637 <= 1;
            dio_out <= 1;
            dio_dir <= 1;
            bit_cnt <= 0;
        end else if (tick_tm1637) begin
            case (state)
                // --- Inicialización y START ---
                0: begin clk_tm1637 <= 1; dio_out <= 1; dio_dir <= 1; state <= 1; end
                1: begin dio_out <= 0; state <= 2; end // START cond. (DIO cae con CLK alto)
                2: begin clk_tm1637 <= 0; current_byte <= 8'h40; state <= 3; bit_cnt <= 0; end // Comando 0x40 (Auto-incremento)

                // --- Envío de byte genérico (8 bits + ACK) ---
                3: begin // Poner bit en DIO
                    dio_out <= current_byte[bit_cnt];
                    state <= 4;
                end
                4: begin clk_tm1637 <= 1; state <= 5; end // Subir CLK
                5: begin
                    clk_tm1637 <= 0;
                    if (bit_cnt == 7) begin
                        bit_cnt <= 0;
                        dio_dir <= 0; // Liberar DIO para ACK
                        state <= 6;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                        state <= 3;
                    end
                end
                6: begin clk_tm1637 <= 1; state <= 7; end // Pulso de reloj de ACK
                7: begin
                    clk_tm1637 <= 0;
                    dio_dir <= 1; // Retomar DIO
                    // Transiciones según la secuencia del protocolo
                    case (current_byte)
                        8'h40: begin dio_out <= 1; state <= 8; end // Fin de comando 1
                        8'hC0: begin current_byte <= digit0_pat; state <= 3; end
                        digit0_pat: begin current_byte <= digit1_pat; state <= 3; end
                        digit1_pat: begin current_byte <= digit2_pat; state <= 3; end
                        digit2_pat: begin current_byte <= digit3_pat; state <= 3; end
                        digit3_pat: begin dio_out <= 1; state <= 11; end // Fin de transmisión de datos
                        8'h88: begin dio_out <= 1; state <= 14; end // Fin de comando de display ON
                        default: state <= 0;
                    endcase
                end

                // --- STOP Condition 1 ---
                8: begin clk_tm1637 <= 1; state <= 9; end
                9: begin dio_out <= 1; state <= 10; end
                
                // --- Comando 2: Dirección base 0xC0 ---
                10: begin dio_out <= 0; state <= 2; current_byte <= 8'hC0; end

                // --- STOP Condition 2 ---
                11: begin clk_tm1637 <= 1; state <= 12; end
                12: begin dio_out <= 1; state <= 13; end

                // --- Comando 3: Encender Display (0x88 | Brillo) ---
                13: begin dio_out <= 0; state <= 2; current_byte <= 8'h88; end // 0x88 = Display ON

                // --- STOP Condition 3 / Bucle de Refresco ---
                14: begin clk_tm1637 <= 1; state <= 15; end
                15: begin dio_out <= 1; state <= 0; end // Reiniciar ciclo de envío

                default: state <= 0;
            endcase
        end
    end

endmodule