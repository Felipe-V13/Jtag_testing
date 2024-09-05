module top (
    input logic tck, tdi, aclr, ir_in, v_sdr, udr, clk,
    output logic tdo
);
    logic [7:0] data_from_jtag;
    logic [7:0] sram_data_in, sram_data_out;
    logic [15:0] sram_address;
    logic sram_write_enable, sram_read_enable;

    // Instancia del módulo JTAG
    vjtag_interface jtag_inst (
        .tck(tck),
        .tdi(tdi),
        .aclr(aclr),
        .ir_in(ir_in),
        .v_sdr(v_sdr),
        .udr(udr),
        .data(data_from_jtag),
        .tdo(tdo),
        .sram_addr(sram_address),
        .sram_data_out(sram_data_in),  // Conectado para escritura
        .sram_data_in(sram_data_out),  // Conectado para lectura
        .sram_write_enable(sram_write_enable),
        //.sram_read_enable(sram_read_enable)
    );

    // Instancia del módulo SRAM
    sram sram_inst (
        .address(sram_address),
        .data_in(sram_data_in),
        .data_out(sram_data_out),
        .write_enable(sram_write_enable),
        //.read_enable(sram_read_enable),
        .clk(clk)
    );

endmodule
