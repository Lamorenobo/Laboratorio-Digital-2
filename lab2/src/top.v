`timescale 1ns/1ps
`include  "../src/alu4bits.v"


module top (
    input wire clk,
    input wire [3:0] sw,
    input wire [3:0] btn,
    output wire [3:0] led,
    output wire red,
    output wire green,
    output wire blue
);

    // ============================================================
    // REGISTROS DE ALMACENAMIENTO
    // ============================================================
    
    // Almacenan los operandos A y B
    reg [3:0] reg_A = 4'b0000;
    reg [3:0] reg_B = 4'b0000;

    // Almacena el código de operación
    // 00 -> Suma
    // 01 -> Resta
    // 10 -> AND
    // 11 -> OR
    reg [1:0] option_reg = 2'b00;


    // ============================================================
    // DETECTOR DE FLANCO DE LOS BOTONES
    // ============================================================

    // Estado actual y anterior de los botones
    reg [3:0] btn_reg0 = 4'b0000;
    reg [3:0] btn_reg1 = 4'b0000;

    // Pulso de un ciclo cuando un botón pasa de 0 a 1
    wire [3:0] btn_pulse;

    wire [3:0] alu_result;
    // Registro de estados de los botones
    always @(posedge clk) begin
        btn_reg0 <= btn;
        btn_reg1 <= btn_reg0;
    end

    // Detección de flanco de subida
    assign btn_pulse = btn_reg0 & ~btn_reg1;


    // ============================================================
    // ALMACENAMIENTO DE OPERANDOS Y SELECCIÓN DE OPERACIÓN
    // ============================================================

    always @(posedge clk) begin

        // BTN0 -> cargar Operando A
        if (btn_pulse[0])
            reg_A <= sw;

        // BTN1 -> cargar Operando B
        if (btn_pulse[1])
            reg_B <= sw;

        // BTN2 -> modificar bit 0 del código de operación
        if (btn_pulse[2])
            option_reg[0] <= ~option_reg[0];

        // BTN3 -> modificar bit 1 del código de operación
        if (btn_pulse[3])
            option_reg[1] <= ~option_reg[1];

    end


    // ============================================================
    // ALU COMBINACIONAL
    // ============================================================

    alu4bits alu_inst (
        .A(reg_A),
        .B(reg_B),
        .option(option_reg),
        .result(alu_result)
    );


    assign led[0] = alu_result[0];
    assign led[1] = alu_result[1];
    assign led[2] = alu_result[2];
    assign led[3] = alu_result[3];
    // ============================================================
    // LED RGB
    // ============================================================
    //
    // 00 -> Suma -> Verde
    // 01 -> Resta -> Rojo
    // 10 -> AND   -> Azul
    // 11 -> OR    -> Amarillo
    //
    // Amarillo = Rojo + Verde
    // ============================================================

    assign red = (option_reg == 2'b01) ||
                 (option_reg == 2'b11);

    assign green = (option_reg == 2'b00) ||
                   (option_reg == 2'b11);

    assign blue = (option_reg == 2'b10);

endmodule