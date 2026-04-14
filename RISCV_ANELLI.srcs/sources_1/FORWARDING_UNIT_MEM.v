`timescale 1ns / 1ps

`include "RISC-V.vh"

module FORWARDING_UNIT_MEM(
    input wire [`REG_ADDR_WIDTH-1:0] rs2,
    
    input wire [`REG_ADDR_WIDTH-1:0] WB_rd,
    input wire [`DATA_WIDTH-1:0] WB_data,
    input wire WB_wb_we,

    output reg ForwardSel,
    output reg [`DATA_WIDTH-1:0] ForwardedData
);


    always @(*) begin
        ForwardSel     = 1'b0;
        ForwardedData = 32'b0;

        if (WB_wb_we && (WB_rd != 0) && (WB_rd == rs2)) begin
            ForwardSel     = 1'b1;
            ForwardedData = WB_data;
        end
    end

endmodule
