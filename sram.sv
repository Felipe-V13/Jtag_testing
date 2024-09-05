module sram (
    input logic [15:0] address,    // Dirección en la memoria
    input logic [7:0] data_in,     // Datos que se escribirán en la memoria
    output logic [7:0] data_out,   // Datos leídos de la memoria
    input logic write_enable,      // Señal de habilitación de escritura
    input logic read_enable,       // Señal de habilitación de lectura
    input logic clk
);

    // Definimos la memoria de 64k x 8 bits
    logic [7:0] memory [65535:0];

    // Operación de escritura
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in;
        end
    end

    // Operación de lectura
    always_ff @(posedge clk) begin
        if (read_enable) begin
            data_out <= memory[address];
        end else begin
            data_out <= 8'bz;  // Alta impedancia cuando no se lee
        end
    end

endmodule
