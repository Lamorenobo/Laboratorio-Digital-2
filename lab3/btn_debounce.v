module btn_debounce #(
    parameter COUNTER_MAX = 20'd100 // Límite reducido para simulación (en síntesis Vivado usará 1_000_000)
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_pulse
);

    reg [19:0] counter;
    reg        btn_state;
    reg        btn_sync_0, btn_sync_1;

    // Sincronización de la entrada
    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;
    end

    // Filtro anti-rebote (~10 ms a 100 MHz)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter   <= 0;
            btn_state <= 0;
            btn_pulse <= 0;
        end else begin
            btn_pulse <= 0;
            if (btn_sync_1 != btn_state) begin
                counter <= counter + 1'b1;
                if (counter == 20'd100) begin // para implementacion cambiar por 20'd1_000_000
                    btn_state <= btn_sync_1;
                    counter   <= 0;
                    if (btn_sync_1 == 1'b1) begin
                        btn_pulse <= 1'b1; // Genera un único pulso de 1 ciclo de reloj
                    end
                end
            end else begin
                counter <= 0;
            end
        end
    end

endmodule