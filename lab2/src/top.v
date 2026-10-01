`timescale 1ns/1ps  

modulo top_alu ( 
    input wire clk,
    input wire [3:0]sw, 
    input wire [3:0]btn,
    output wire [3:0]led,
    output reg red,
    output reg green,
    output reg blue
);

    reg [3:0] reg_A= 4'b0000;
    reg [3:0] reg_B= 4'b0000;
    reg [1:0] option_reg =2'b00;
op

// para que la operacion cambie solo una vez por cada pulso lo que hacemos es poner un detector de flanco, asi solo tomamos un solo pulso de reloj
    reg[3:0] btn_reg0 = 4'b0000; //toma el estado del boton actual
    reg[3:0] btn_reg1 = 4'b0000; // toma el estado del boton en el ciclo anterior

always @(posedge clk)begin
  btn_reg0 <= btn;
  btn_reg1 <= btn_reg0
end
assign bnt_pulse= btn_r0 & ~btn_r1;

//cargamos los datos y las seleccion del option_reg 
always @(posedge clk) begin 
    if (bnt_pulse[0]) reg_A <= sw; //boton0 para cargar el primer dato regA
    if (bnt_pulse[1]) reg_B <= sw;// boton1 cargar el segundo dato regb
    if (bnt_pulse[0]) option_reg[0] <= ~option_reg[0]; // boton2 valor bit 0 de option_reg (para escoger una de las 4 variantes mantengo el valor amenos que lo quiera cambiar)
    if (bnt_pulse[0]) option_reg[1] <= ~option_reg[1]; //boton3 valor bit 1 de option_reg 
end
alu_4bits alu_inst (
    .A(reg_A),
    .B(reg_B),
    .option(option_reg),
    result(led)
)


always @(*)begin
    case (option_reg)
        2'b00:begin // para suma rojo
            red= 1'b1
            green= 1'b0
            blue= 1'b0
        end 
        2'b00:begin//para resta verde
            red= 1'b0
            green= 1'b0
            blue= 1'b1
        end 
        2'b00:begin// para and azul
            red= 1'b1
            green= 1'b0
            blue= 1'b0
        end 
        2'b00:begin// para OR rojo+azul
            red= 1'b1
            green= 1'b0
            blue= 1'b1
        end 
        default: 
    endcase

    
end