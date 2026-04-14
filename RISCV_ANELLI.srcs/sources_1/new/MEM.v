`timescale 1ns / 1ps

`include "RISC-V.vh"

module MEM(
    // Clock and Reset
    input wire clk,

    // --- Inputs from EXE/MEM pipeline register ---
    input wire [`REG_ADDR_WIDTH-1:0] rs2,
    input wire [`DATA_WIDTH-1:0] rs2_data,
    input wire mem_we,
    input wire mem_re,
    input wire [1:0] mem_dim,
    input wire mem_sig,
    input wire [`DATA_WIDTH-1:0] eo_data,

    // --- Forwarding Inputs from WB stage ---
    input wire [`REG_ADDR_WIDTH-1:0] WB_rd,
    input wire WB_wb_we,
    input wire [`DATA_WIDTH-1:0] WB_data,

    // --- Outputs to MEM/WB pipeline register ---
    output wire [`DATA_WIDTH-1:0] eo_data_out,
    output wire [`DATA_WIDTH-1:0] mem_data
);
    wire ForwardSel;
    wire [`DATA_WIDTH-1:0] ForwardedData;

    FORWARDING_UNIT_MEM forwarding_unit_mem_inst (
        .rs2(rs2),
        .WB_rd(WB_rd),
        .WB_data(WB_data),
        .WB_wb_we(WB_wb_we),
        .ForwardSel(ForwardSel),
        .ForwardedData(ForwardedData)
    );

    wire [`DATA_WIDTH-1:0] write_data;
    
    MUX2_1 mux_forward(
        .in0(rs2_data),
        .in1(ForwardedData),
        .sel(ForwardSel),
        .out(write_data)
    );
    
    wire [`DATA_WIDTH-1:0] mem_data_wire;

    
    DATA_MEMORY data_memory_inst(
        .clk(clk),
        .address(eo_data),
        .write_data(write_data),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_dim(mem_dim),
        .mem_sig(mem_sig),
        .mem_data(mem_data_wire)
    );
    
    assign eo_data_out      = eo_data;
    assign mem_data         = mem_data_wire;

endmodule