

module top (
    input  wire       clk,        // Reloj principal de la Zybo Z7 (125 MHz, pin K17)
    input  wire [3:0] sw,         // SW[3:0]: Dato de entrada / Opcode de la ALU
    input  wire [3:0] btn,        // BTN0=Sel_Write, BTN1=Write, BTN2=Next_Comb, BTN3=Execute
    output wire [3:0] led,        // LED[3:0]: Registros activos en la operación actual
    output reg  [2:0] rgb_led,    // RGB LED: Muestra el registro seleccionado para escritura
    output wire       clk_tm1637, // Salida de reloj hacia el display TM1637
    inout  wire       dio         // Línea de datos bidireccional hacia el display TM1637
);
 
    // Reset automático al encender (activo los primeros 4 ciclos)
    reg [3:0] por = 4'b1111;
    always @(posedge clk) por <= {por[2:0], 1'b0};
    wire rst = por[3];

    wire btn0_pulse; // Cambiar registro de escritura
    wire btn1_pulse; // Escribir dato
    wire btn2_pulse; // Siguiente combinación
    wire btn3_pulse; // Ejecutar operación ALU
 
    btn_debounce deb0 (.clk(clk), .rst(rst), .btn_in(btn[0]), .btn_pulse(btn0_pulse));
    btn_debounce deb1 (.clk(clk), .rst(rst), .btn_in(btn[1]), .btn_pulse(btn1_pulse));
    btn_debounce deb2 (.clk(clk), .rst(rst), .btn_in(btn[2]), .btn_pulse(btn2_pulse));
    btn_debounce deb3 (.clk(clk), .rst(rst), .btn_in(btn[3]), .btn_pulse(btn3_pulse));

    // Selección del Registro de Escritura (BTN0)

    reg [1:0] write_addr;
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_addr <= 2'b00;
        end else if (btn0_pulse) begin
            write_addr <= write_addr + 1'b1; // Recorre R0 -> R1 -> R2 -> R3
        end
    end
 
    // Registros
    always @(*) begin
        case (write_addr)
            2'b00:   rgb_led = 3'b001; // R0 -> Azul
            2'b01:   rgb_led = 3'b010; // R1 -> Verde
            2'b10:   rgb_led = 3'b100; // R2 -> Rojo
            2'b11:   rgb_led = 3'b011; // R3 -> Cían / Blanco
            default: rgb_led = 3'b000;
        endcase
    end

    //  Operandos

    wire [1:0] read_addr_a;
    wire [1:0] read_addr_b;
 
    comb_selector selector_inst (
        .clk(clk),
        .rst(rst),
        .btn_next(btn2_pulse),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .active_leds(led)
    );
 

    // Banco de Registros

    wire [3:0] operand_a;
    wire [3:0] operand_b;
 
    reg_bank reg_bank_inst (
        .clk(clk),
        .rst(rst),
        .write_enable(btn1_pulse),
        .write_addr(write_addr),
        .write_data(sw[3:0]),
        .read_addr_a(read_addr_a),
        .read_addr_b(read_addr_b),
        .read_data_a(operand_a),
        .read_data_b(operand_b)
    );
 

    //  Unidad Aritmético-Lógica (ALU)
 
    wire [3:0] alu_raw_result;
 
    alu alu_inst (
        .a(operand_a),
        .b(operand_b),
        .op(sw[2:0]),
        .result(alu_raw_result)
    );
 

    // BTN3

    reg [3:0] latched_result;
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            latched_result <= 4'b0000;
        end else if (btn3_pulse) begin
            latched_result <= alu_raw_result; // Conserva el resultado hasta un nuevo BTN3
        end
    end
 

    // Display TM1637

    wire mode_sel = 1'b1; // Selector decimal o binario (1 = Binario, 0 = Decimal)
 
    display_tm1637 #(.CLK_HZ(125_000_000)) display_inst (
        .clk(clk),
        .rst(rst),
        .data_in(latched_result),
        .mode_sel(mode_sel),
        .clk_tm1637(clk_tm1637),
        .dio(dio)
    );
 
endmodule