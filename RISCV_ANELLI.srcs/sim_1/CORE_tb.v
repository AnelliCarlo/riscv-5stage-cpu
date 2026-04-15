`timescale 1ns / 1ps

`include "RISC-V.vh"

module CORE_tb();

    reg clk;
    reg rst;
    reg [`DATA_WIDTH-1:0] pc_start;
    
    // Debug registers
    wire [`DATA_WIDTH-1:0] dbg_x1;
    wire [`DATA_WIDTH-1:0] dbg_x2;
    wire [`DATA_WIDTH-1:0] dbg_x3;
    wire [`DATA_WIDTH-1:0] dbg_x4;
    wire [`DATA_WIDTH-1:0] dbg_x5;
    wire [`DATA_WIDTH-1:0] dbg_x6;
    wire [`DATA_WIDTH-1:0] dbg_x7; 
    wire [`DATA_WIDTH-1:0] dbg_x8;

    CORE uut (
        .clk(clk),
        .rst(rst),
        .pc_start(pc_start),
        
        .dbg_x1(dbg_x1),
        .dbg_x2(dbg_x2),
        .dbg_x3(dbg_x3),
        .dbg_x4(dbg_x4),
        .dbg_x5(dbg_x5),
        .dbg_x6(dbg_x6),
        .dbg_x7(dbg_x7),
        .dbg_x8(dbg_x8)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        //pc_start = 32'b0;
        pc_start = 32'b00000000000000000000000000011100;
        
        #20;
        rst = 0;    
        
        @(posedge clk);
        #1;
        
        #400;
        $finish;              
    end

endmodule