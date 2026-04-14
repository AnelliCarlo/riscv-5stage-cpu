`timescale 1ns / 1ps

`include "RISC-V.vh"

module FORWARDING_UNIT_EXE(
    input wire [`REG_ADDR_WIDTH-1:0] rs1,
    input wire [`REG_ADDR_WIDTH-1:0] rs2,

    input wire [`REG_ADDR_WIDTH-1:0] MEM_rd,
    input wire MEM_mem_re,
    input wire MEM_wb_we,
    input wire [`DATA_WIDTH-1:0] MEM_eo_data,
    
    input wire [`REG_ADDR_WIDTH-1:0] WB_rd,
    input wire [`DATA_WIDTH-1:0] WB_data,
    input wire WB_wb_we,

    output reg ForwardSel1,
    output reg ForwardSel2,
    output reg [`DATA_WIDTH-1:0] ForwardedData1,
    output reg [`DATA_WIDTH-1:0] ForwardedData2
);

    always @(*) begin
        ForwardSel1     = 1'b0;
        ForwardedData1 = 32'b0;
        
        ForwardSel2     = 1'b0;
        ForwardedData2 = 32'b0;

        if (MEM_wb_we && (MEM_rd != 0) && (MEM_rd == rs1) && !MEM_mem_re) begin
            ForwardSel1     = 1'b1;
            ForwardedData1 = MEM_eo_data;
        end
        else if (WB_wb_we && (WB_rd != 0) && (WB_rd == rs1)) begin
            ForwardSel1     = 1'b1;
            ForwardedData1 = WB_data;
        end

        if (MEM_wb_we && (MEM_rd != 0) && (MEM_rd == rs2) && !MEM_mem_re) begin
            ForwardSel2     = 1'b1;
            ForwardedData2 = MEM_eo_data;
        end
        else if (WB_wb_we && (WB_rd != 0) && (WB_rd == rs2)) begin
            ForwardSel2     = 1'b1;
            ForwardedData2 = WB_data;
        end
    end

endmodule