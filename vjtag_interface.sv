module vjtag_interface (
    input wire tck,        // Clock
    input wire tdi,        // Serial data input
    input wire aclr,       // Asynchronous clear/reset
    input wire ir_in,      // Instruction register input
    input wire v_sdr,      // Shift-DR signal
    input wire udr,        // Update-DR signal
    output logic [7:0] data,        // Data output
    output logic tdo,               // Serial data output (TDO)
    output logic [15:0] sram_addr,  // Dirección de SRAM
    output logic [7:0] sram_data_out,  // Datos para escribir en SRAM
    input wire [7:0] sram_data_in,     // Datos leídos de la SRAM
    output logic sram_write_enable     // Señal de habilitación de escritura
    // No necesitamos read_enable temporalmente, así que lo eliminamos
);

    logic [7:0] DR1;  // Registro de datos
    logic [15:0] DR2; // Registro de dirección (para la SRAM)
    logic write_enable_internal; // Señal interna para escritura

    // Separamos la selección de DR1 (datos) y DR2 (dirección)
    wire select_DR1 = ir_in == 1'b1;   // Registro de datos
    wire select_DR2 = ir_in == 1'b0;   // Registro de dirección SRAM

    // Registro de desplazamiento de datos y direcciones
    always_ff @ (posedge tck or negedge aclr) begin
        if (~aclr) begin
            DR1 <= 8'b00000000;
            DR2 <= 16'b0000000000000000;
        end else begin
            if (v_sdr) begin
                if (select_DR1) begin
                    DR1 <= {tdi, DR1[7:1]};  // Desplazar los datos
                end else if (select_DR2) begin
                    DR2 <= {tdi, DR2[15:1]}; // Desplazar dirección
                end
            end
        end
    end
	 
	 // infiriendo latches por eso borré el de lectura

    // Control de escritura en el flanco positivo de udr
    always_ff @(posedge udr or negedge aclr) begin
        if (~aclr) begin
            write_enable_internal <= 1'b0; // Deshabilitar escritura en reset
        end else if (udr) begin
            // Escritura en SRAM
            data <= DR1;
            sram_addr <= DR2;
            sram_data_out <= DR1;
            write_enable_internal <= 1'b1;  // Habilitar escritura en SRAM
        end
    end

    // Asignación de las señales de control de SRAM
    always_comb begin
        sram_write_enable = write_enable_internal;
    end

    // Asignación de la salida TDO para la cadena JTAG sincronizada con tck
    always_ff @(posedge tck or negedge aclr) begin
        if (~aclr) begin
            tdo <= 1'b0;
        end else begin
            if (select_DR1) begin
                tdo <= DR1[0]; // Devuelve el bit menos significativo de DR1
            end else begin
                tdo <= 1'b0;
            end
        end
    end

endmodule
