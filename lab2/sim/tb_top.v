
`timescale 1ns/1ps
`include  "../src/top.v"


module tb_top;

    // ============================================================
    // SEÑALES DEL TESTBENCH
    // ============================================================

    reg clk;
    reg [3:0] sw;
    reg [3:0] btn;

    wire [3:0] led;
    wire red;
    wire green;
    wire blue;


    // ============================================================
    // INSTANCIA DEL TOP
    // ============================================================

    top uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );


    // ============================================================
    // GENERADOR DE RELOJ
    // Periodo = 10 ns
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // PROCEDIMIENTO PARA PULSAR UN BOTÓN
    // ============================================================

    task press_button;
        input [3:0] button;
        begin
            btn = button;
            #20;
            btn = 4'b0000;
            #20;
        end
    endtask


    // ============================================================
    // PRUEBAS
    // ============================================================

    initial begin

        // Crear archivo para GTKWave
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        // Inicialización
        clk = 1'b0;
        sw  = 4'b0000;
        btn = 4'b0000;

        #20;


        // ========================================================
        // CARGAR OPERANDO A
        // A = 0011 = 3
        // ========================================================

        $display("-----------------------------------------");
        $display("Cargando A = 0011");

        sw = 4'b0011;
        press_button(4'b0001);

        #20;

        $display("A = %b", uut.reg_A);


        // ========================================================
        // CARGAR OPERANDO B
        // B = 0101 = 5
        // ========================================================

        $display("-----------------------------------------");
        $display("Cargando B = 0101");

        sw = 4'b0101;
        press_button(4'b0010);

        #20;

        $display("B = %b", uut.reg_B);


        // ========================================================
        // SUMA
        // option = 00
        // 3 + 5 = 8 = 1000
        // ========================================================

        $display("-----------------------------------------");
        $display("PRUEBA SUMA");

        #20;

        $display("A      = %b", uut.reg_A);
        $display("B      = %b", uut.reg_B);
        $display("OPTION = %b", uut.option_reg);
        $display("LED    = %b", led);
        $display("RGB    = R:%b G:%b B:%b", red, green, blue);


        // ========================================================
        // RESTA
        // option = 01
        // 3 - 5 = -2
        // En 4 bits: 1110
        // ========================================================

        $display("-----------------------------------------");
        $display("PRUEBA RESTA");

        press_button(4'b0100);

        #20;

        $display("A      = %b", uut.reg_A);
        $display("B      = %b", uut.reg_B);
        $display("OPTION = %b", uut.option_reg);
        $display("LED    = %b", led);
        $display("RGB    = R:%b G:%b B:%b", red, green, blue);


        // ========================================================
        // AND
        // option = 10
        // 0011 AND 0101 = 0001
        // ========================================================

        $display("-----------------------------------------");
        $display("PRUEBA AND");

        press_button(4'b0100);

        #20;

        $display("A      = %b", uut.reg_A);
        $display("B      = %b", uut.reg_B);
        $display("OPTION = %b", uut.option_reg);
        $display("LED    = %b", led);
        $display("RGB    = R:%b G:%b B:%b", red, green, blue);


        // ========================================================
        // OR
        // option = 11
        // 0011 OR 0101 = 0111
        // ========================================================

        $display("-----------------------------------------");
        $display("PRUEBA OR");

        press_button(4'b0100);

        #20;

        $display("A      = %b", uut.reg_A);
        $display("B      = %b", uut.reg_B);
        $display("OPTION = %b", uut.option_reg);
        $display("LED    = %b", led);
        $display("RGB    = R:%b G:%b B:%b", red, green, blue);


        // ========================================================
        // COMPROBAR QUE A Y B SIGUEN ALMACENADOS
        // ========================================================

        $display("-----------------------------------------");
        $display("COMPROBANDO ALMACENAMIENTO");

        sw = 4'b1111;

        #40;

        $display("SW     = %b", sw);
        $display("A      = %b", uut.reg_A);
        $display("B      = %b", uut.reg_B);
        $display("LED    = %b", led);


        // ========================================================
        // FIN
        // ========================================================

        $display("-----------------------------------------");
        $display("SIMULACION TERMINADA");

        #40;

        $finish;

    end

endmodule
