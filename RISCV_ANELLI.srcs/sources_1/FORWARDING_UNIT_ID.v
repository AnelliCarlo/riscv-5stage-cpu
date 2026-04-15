`timescale 1ns / 1ps

`include "RISC-V.vh"

module FORWARDING_UNIT_ID(

    input wire [`REG_ADDR_WIDTH-1:0] rs1,
    input wire [`REG_ADDR_WIDTH-1:0] rs2,
    
    input wire [`REG_ADDR_WIDTH-1:0] MEM_rd,
    input wire MEM_mem_re,
    input wire MEM_wb_we,
    
    output reg COMPSel1, // Select COMPARATOR Input 1 (0: rs1_data, 1: EXE_MEMOut_DATA)
    output reg COMPSel2  // Select COMPARATOR Input 2 (0: rs2_data, 1: EXE_MEMOut_DATA)
    
    );
    
    always @(*) begin
        COMPSel1 = 0;
        COMPSel2 = 0;
    
        if (MEM_wb_we == 1 && MEM_mem_re == 0) begin
            if (MEM_rd == rs1) COMPSel1 = 1;
            if (MEM_rd == rs2) COMPSel2 = 1;
        end
    end
endmodule