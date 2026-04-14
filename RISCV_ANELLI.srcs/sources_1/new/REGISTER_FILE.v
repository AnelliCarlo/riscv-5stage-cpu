`timescale 1ns / 1ps

`include "RISC-V.vh"

module REGISTER_FILE(

    input wire clk,
    input wire rst,

    // Register addresses to read 
    input wire [`REG_ADDR_WIDTH-1:0] rs1,
    input wire [`REG_ADDR_WIDTH-1:0] rs2,
    
    // Write-back inputs
    input wire [`REG_ADDR_WIDTH-1:0] wb_rd,
    input wire [`DATA_WIDTH-1:0] wb_data,
    input wire wb_we,
    
    // Register data outputs
    output reg [`DATA_WIDTH-1:0] rs1_data,
    output reg [`DATA_WIDTH-1:0] rs2_data,
    
    output wire [`DATA_WIDTH-1:0] dbg_x1,
    output wire [`DATA_WIDTH-1:0] dbg_x2,
    output wire [`DATA_WIDTH-1:0] dbg_x3,
    output wire [`DATA_WIDTH-1:0] dbg_x4,
    output wire [`DATA_WIDTH-1:0] dbg_x5,
    output wire [`DATA_WIDTH-1:0] dbg_x6,
    output wire [`DATA_WIDTH-1:0] dbg_x7,
    output wire [`DATA_WIDTH-1:0] dbg_x8
    );
    
    // Array defining the 32 registers (x0 to x31)
    reg [`DATA_WIDTH-1:0] regs [0:`DATA_WIDTH-1]; 
    
    integer i;
    
    // Asynchronous Read Logic (Combinational Look-up)
    // Data is available immediately when rs1/rs2 changes.
    always @(*) begin
        rs1_data = regs[rs1];
        rs2_data = regs[rs2];
    end
    
    // Synchronous Write Logic
    always @(negedge clk) begin
        if (rst) begin
            // Synchronous reset: clear all registers
            for(i = 0; i < `DATA_WIDTH; i = i + 1) begin
                regs[i] <= {`DATA_WIDTH{1'b0}}; 
            end
        end 
        // Write if write enable is active AND destination is not x0 (`ZEROREG`)
        else if (wb_we && (wb_rd != `ZEROREG)) begin
            regs[wb_rd] <= wb_data;
        end
    end
    
    assign dbg_x1 = regs[1];
    assign dbg_x2 = regs[2];
    assign dbg_x3 = regs[3];
    assign dbg_x4 = regs[4];
    assign dbg_x5 = regs[5];
    assign dbg_x6 = regs[6];
    assign dbg_x7 = regs[7];
    assign dbg_x8 = regs[8];
endmodule