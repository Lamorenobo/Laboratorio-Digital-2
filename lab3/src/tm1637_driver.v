module tm1637_driver #(
    parameter integer CLK_HZ  = 125_000_000, 
    parameter integer TICK_HZ = 200_000      
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] seg0,   
    input  wire [7:0] seg1,   
    input  wire [7:0] seg2,
    input  wire [7:0] seg3,   
    input  wire [2:0] brillo, 
    output reg        tm_clk,
    inout  wire       tm_dio,
    output reg        ack_err  
);

   
    // Divisor de frecuencia para generar un "tick" a 200 kHz (5 us)

    localparam integer DIV = CLK_HZ / TICK_HZ;
    reg [$clog2(DIV)-1:0] div_cnt = 0;
    reg                   tick    = 1'b0;

    always @(posedge clk) begin
        if (div_cnt == DIV-1) begin
            div_cnt <= 0;
            tick    <= 1'b1;
        end else begin
            div_cnt <= div_cnt + 1'b1;
            tick    <= 1'b0;
        end
    end


    // DIO en colector abierto: solo se fuerza a 0 o se suelta (Z).

    
    reg dio_low;
    assign tm_dio = dio_low ? 1'b0 : 1'bz;

    reg [1:0] dio_sync;                       // sincronizador para leer el ACK
    always @(posedge clk) dio_sync <= {dio_sync[0], tm_dio};
    wire dio_in = dio_sync[1];


    // 3. Lista de operaciones 

    localparam [1:0] OP_START = 2'd0,
                     OP_BYTE  = 2'd1,
                     OP_STOP  = 2'd2;
    localparam [3:0] LAST = 4'd12;

    reg [3:0] idx;          // operación actual (0..12)
    reg [5:0] step;         // fase dentro de la operación
    reg [7:0] d0, d1, d2, d3;
    reg [2:0] br;

    reg [1:0] op;
    reg [7:0] op_byte;

    always @(*) begin
        op_byte = 8'h00;
        case (idx)
            4'd0:  op = OP_START;
            4'd1:  begin op = OP_BYTE; op_byte = 8'h40; end           // comando de datos
            4'd2:  op = OP_STOP;
            4'd3:  op = OP_START;
            4'd4:  begin op = OP_BYTE; op_byte = 8'hC0; end           // dirección 0
            4'd5:  begin op = OP_BYTE; op_byte = d0;    end
            4'd6:  begin op = OP_BYTE; op_byte = d1;    end
            4'd7:  begin op = OP_BYTE; op_byte = d2;    end
            4'd8:  begin op = OP_BYTE; op_byte = d3;    end
            4'd9:  op = OP_STOP;
            4'd10: op = OP_START;
            4'd11: begin op = OP_BYTE; op_byte = {5'b10001, br}; end  // 0x88 | brillo
            default: op = OP_STOP;                                    // idx 12
        endcase
    end

    wire [3:0] idx_next = (idx == LAST) ? 4'd0 : idx + 1'b1;

    // Valores iniciales tras programar la FPGA (por si rst nunca se activa)
    initial begin
        idx     = 4'd0;
        step    = 6'd0;
        tm_clk  = 1'b1;
        dio_low = 1'b0;
        ack_err = 1'b0;
    end

    // ------------------------------------------------------------------
    // 4. Máquina de estados: avanza una fase en cada tick
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            idx     <= 4'd0;
            step    <= 6'd0;
            tm_clk  <= 1'b1;      // reposo: CLK = 1, DIO = 1
            dio_low <= 1'b0;
            ack_err <= 1'b0;
            d0 <= 8'h00; d1 <= 8'h00; d2 <= 8'h00; d3 <= 8'h00;
            br <= 3'd0;
        end else if (tick) begin
            case (op)

            // --- START: DIO baja mientras CLK está en alto ---------------
            OP_START: begin
                case (step)
                    6'd0: begin
                        if (idx == 4'd0) begin  // "foto" de las entradas en cada refresco
                            d0 <= seg0; d1 <= seg1; d2 <= seg2; d3 <= seg3;
                            br <= brillo;
                        end
                        step <= 6'd1;
                    end
                    6'd1: begin
                        dio_low <= 1'b1;        // DIO 1 -> 0 con CLK = 1
                        step    <= 6'd2;
                    end
                    default: begin
                        tm_clk <= 1'b0;
                        step   <= 6'd0;
                        idx    <= idx_next;
                    end
                endcase
            end

            // --- BYTE: 8 bits LSB primero + 9.º pulso de ACK -------------
            OP_BYTE: begin
                if (step < 6'd32) begin
                    // 4 fases por bit; bit actual = step[4:2]
                    case (step[1:0])
                        2'd0: tm_clk  <= 1'b0;                  // bajar CLK
                        2'd1: dio_low <= ~op_byte[step[4:2]];   // poner el dato
                        2'd2: tm_clk  <= 1'b1;                  // flanco de subida: TM1637 lee
                        default: ;                              // mantener CLK alto
                    endcase
                    step <= step + 1'b1;
                end else begin
                    case (step)
                        6'd32: tm_clk  <= 1'b0;
                        6'd33: dio_low <= 1'b0;                 // soltar DIO
                        6'd34: tm_clk  <= 1'b1;                 // 9.º pulso
                        default: ;
                    endcase
                    if (step == 6'd35) begin
                        ack_err <= dio_in;                      // ACK correcto = DIO en 0
                        tm_clk  <= 1'b0;
                        step    <= 6'd0;
                        idx     <= idx_next;
                    end else begin
                        step <= step + 1'b1;
                    end
                end
            end

            // --- STOP: DIO sube mientras CLK está en alto ----------------
            default: begin
                case (step)
                    6'd0: begin
                        dio_low <= 1'b1;        // DIO = 0 con CLK = 0
                        step    <= 6'd1;
                    end
                    6'd1: begin
                        tm_clk <= 1'b1;
                        step   <= 6'd2;
                    end
                    default: begin
                        dio_low <= 1'b0;        // DIO 0 -> 1 con CLK = 1
                        step    <= 6'd0;
                        idx     <= idx_next;
                    end
                endcase
            end

            endcase
        end
    end

endmodule