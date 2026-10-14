`timescale 1ns / 1ps

module tb_top;

    // Entradas del UUT
    reg        clk;
    reg  [3:0] sw;
    reg  [3:0] btn;

    // Salidas del UUT
    wire [3:0] led;
    wire [2:0] rgb_led;
    wire       clk_tm1637;
    wire       dio;

    // Instanciación del módulo Superior
    top uut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led),
        .rgb_led(rgb_led),
        .clk_tm1637(clk_tm1637),
        .dio(dio)
    );

    // Reloj principal de 100 MHz (Período = 10 ns)
    always #5 clk = ~clk;

    // Tarea auxiliar para presionar un botón
    task press_button;
        input [1:0] btn_index;
        begin
            btn[btn_index] = 1'b1;
            #2000; // Mantener presionado suficiente tiempo para el debouncer
            btn[btn_index] = 1'b0;
            #2000; // Tiempo de descanso
        end
    endtask

    initial begin
        // Crear archivo .vcd para GTKWave
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        // Inicializar señales
        clk = 0;
        sw  = 4'b0000;
        btn = 4'b0000;

        #100;

        // ---------------------------------------------------------------------
        // PASO 1: Escribir el valor 5 (4'b0101) en R0
        // ---------------------------------------------------------------------
        $display("[%0dt] Escribiendo 5 en R0...", $time);
        sw = 4'b0101;       // Valor 5 en SW[3:0]
        press_button(1);    // Presionar BTN1 (Escritura)

        // ---------------------------------------------------------------------
        // PASO 2: Seleccionar R1 y escribir el valor 3 (4'b0011)
        // ---------------------------------------------------------------------
        $display("[%0dt] Seleccionando R1 y escribiendo 3...", $time);
        press_button(0);    // Presionar BTN0 (Cambia write_addr a R1)
        sw = 4'b0011;       // Valor 3 en SW[3:0]
        press_button(1);    // Presionar BTN1 (Escritura)

        // ---------------------------------------------------------------------
        // PASO 3: Cambiar combinaciones para seleccionar A = R0 y B = R1
        // ---------------------------------------------------------------------
        $display("[%0dt] Avanzando combinaciones hasta A=R0, B=R1...", $time);
        press_button(2);    // BTN2: Selecciona combinacion (A=R0, B=R1)

        // ---------------------------------------------------------------------
        // PASO 4: Seleccionar Suma en ALU (SW[2:0] = 000) y ejecutar con BTN3
        // ---------------------------------------------------------------------
        $display("[%0dt] Ejecutando Operación Suma (5 + 3)...", $time);
        sw[2:0] = 3'b000;    // Operación 000 = Suma
        press_button(3);    // Presionar BTN3 (Ejecutar / Latch)
        #1000;

        // ---------------------------------------------------------------------
        // PASO 5: PRUEBA DE PERSISTENCIA
        // Cambiar operandos/switches SIN presionar BTN3. El display NO debe cambiar.
        // ---------------------------------------------------------------------
        $display("[%0dt] PRUEBA PERSISTENCIA: Cambiando operación a Resta sin BTN3...", $time);
        sw[2:0] = 3'b001;    // Cambiar a Resta
        press_button(2);    // Cambiar combinación de registros
        #2000;              // El resultado latcheado DEBE mantenerse en 8

        // ---------------------------------------------------------------------
        // PASO 6: Ejecutar la nueva operación con BTN3
        // ---------------------------------------------------------------------
        $display("[%0dt] Ejecutando nueva operación con BTN3...", $time);
        press_button(3);    // Ahora sí debe actualizar el resultado en el latch
        #2000;

        $display("Simulación del sistema completo finalizada con éxito.");
        $finish;
    end

endmodule