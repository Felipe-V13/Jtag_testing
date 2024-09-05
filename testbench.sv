module testbench;
    logic tck, tdi, aclr, ir_in, v_sdr, udr, clk;
    logic tdo;

    // Instancia del módulo top
    top uut (
        .tck(tck),
        .tdi(tdi),
        .aclr(aclr),
        .ir_in(ir_in),
        .v_sdr(v_sdr),
        .udr(udr),
        .clk(clk),
        .tdo(tdo)
    );

    // Generación de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Reloj de 10 unidades de tiempo
    end

    // Proceso de testeo
    initial begin
        // Inicialización de señales
        aclr = 1;
        tck = 0;
        tdi = 0;
        ir_in = 0;
        v_sdr = 0;
        udr = 0;

        // Reseteo
        #10 aclr = 0;
        #10 aclr = 1;

        // Simular escritura en SRAM a través de JTAG
        #20 ir_in = 1'b1;  // Seleccionar DR1 (registro de datos)
        v_sdr = 1'b1;
        tdi = 1'b1;  // Escribir un valor (0xAA) en DR1
        #10 tdi = 1'b0;
        #10 tdi = 1'b1;
        #10 tdi = 1'b0;
        #10 tdi = 1'b1;
        #10 tdi = 1'b0;
        #10 tdi = 1'b1;
        #10 tdi = 1'b0;
        v_sdr = 1'b0;
        #10 udr = 1'b1;  // Transferir datos a SRAM

        // Escribir dirección en DR2 (0x0010)
        ir_in = 1'b0;  // Seleccionar DR2 (registro de dirección)
        v_sdr = 1'b1;
        tdi = 1'b0;  // Escribir dirección (0x0010)
        #10 tdi = 1'b0;
        #10 tdi = 1'b0;
        #10 tdi = 1'b0;
        #10 tdi = 1'b1;
        #10 tdi = 1'b0;
        #10 tdi = 1'b0;
        #10 tdi = 1'b0;
        #10 tdi = 1'b0;
        v_sdr = 1'b0;
        #10 udr = 1'b1;  // Transferir dirección a SRAM

        // Leer datos de la SRAM
        #50 udr = 1'b0;
        ir_in = 1'b1;  // Seleccionar DR1 para lectura
        #50;

        $finish;
    end
endmodule
