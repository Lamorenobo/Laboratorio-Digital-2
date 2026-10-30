`timescale 1ns / 1ps
`include "src/hex7seg.v"
`include "src/tm1637_driver.v"
`include "src/display_tm1637.v"
`include "src/btn_debounce.v"
`include "src/comb_selector.v"
`include "src/reg_bank.v"
`include "src/ALU.v"
`include "src/top.v"

module tb_top;

    reg        clk;
    reg  [3:0] sw;
    reg  [3:0] btn;

    // Salidas del UUT
    wire [3:0] led;
    wire [2:0] rgb_led;
    wire       clk_tm1637;
    wire       dio;


    pullup(dio);


    top uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led),
        .rgb_led(rgb_led),
        .clk_tm1637(clk_tm1637),
        .dio(dio)
    );


    defparam uut.deb0.COUNTER_MAX = 100;
    defparam uut.deb1.COUNTER_MAX = 100;
    defparam uut.deb2.COUNTER_MAX = 100;
    defparam uut.deb3.COUNTER_MAX = 100;
    defparam uut.display_inst.u_drv.TICK_HZ = 25_000_000;


    always #5 clk = ~clk;

    task press_button;
        input [1:0] btn_index;
        begin
            btn[btn_index] = 1'b1;
            #2000; 
            btn[btn_index] = 1'b0;
            #2000; 
        end
    endtask

    initial begin
        // Crear archivo .vcd para GTKWave
        $timeformat(-9, 0, " ns", 0);
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        // Inicializar señales
        clk = 0;
        sw  = 4'b0000;
        btn = 4'b0000;

        #100;


        $display("[%0t] Escribiendo 5 en R0...", $time);
        sw = 4'b0101;       // Valor 5 en SW[3:0]
        press_button(1);    // Presionar BTN1 (Escritura)


        $display("[%0t] Seleccionando R1 y escribiendo 3...", $time);
        press_button(0);    // Presionar BTN0 (Cambia write_addr a R1)
        sw = 4'b0011;       // Valor 3 en SW[3:0]
        press_button(1);    // Presionar BTN1 (Escritura)

        $display("[%0t] Avanzando combinaciones hasta A=R0, B=R1...", $time);
        press_button(2);    // BTN2: Selecciona combinacion (A=R0, B=R1)


        $display("[%0t] Ejecutando Operación Suma (5 + 3)...", $time);
        sw[2:0] = 3'b000;    // Operación 000 = Suma
        press_button(3);    // Presionar BTN3 (Ejecutar / Latch)
        #20000;
        $display("[%0t] latched_result = %0d  (display: %h %h %h %h)", $time, uut.latched_result, uut.display_inst.u_drv.d0, uut.display_inst.u_drv.d1, uut.display_inst.u_drv.d2, uut.display_inst.u_drv.d3);


        $display("[%0t] PRUEBA PERSISTENCIA: Cambiando operación a Resta sin BTN3...", $time);
        sw[2:0] = 3'b001;    // Cambiar a Resta
        press_button(2);    // Cambiar combinación de registros
        #2000;              // El resultado latcheado DEBE mantenerse en 8
        $display("[%0t] latched_result = %0d  (display: %h %h %h %h)", $time, uut.latched_result, uut.display_inst.u_drv.d0, uut.display_inst.u_drv.d1, uut.display_inst.u_drv.d2, uut.display_inst.u_drv.d3);


        $display("[%0t] Ejecutando nueva operación con BTN3...", $time);
        press_button(3);    // Ahora sí debe actualizar el resultado en el latch
        #20000;
        $display("[%0t] latched_result = %0d  (display: %h %h %h %h)", $time, uut.latched_result, uut.display_inst.u_drv.d0, uut.display_inst.u_drv.d1, uut.display_inst.u_drv.d2, uut.display_inst.u_drv.d3);

        $display("Simulación del sistema completo finalizada con éxito.");
        $finish;
    end

endmodule