`timescale 1ns / 1ps

`include "RISC-V.vh"

module WB(
    input wire wb_sel_input,
    input wire [`DATA_WIDTH-1:0] eo_data,
    input wire [`DATA_WIDTH-1:0] mem_data,
    
    output wire [`DATA_WIDTH-1:0] data
);

    MUX2_1 mux_wb (
        .in0(eo_data),
        .in1(mem_data),
        .sel(wb_sel_input),
        .out(data)
    );

endmodule