`timescale 1ns / 1ps

`include "RISC-V.vh"

module CORE_tb();

    reg clk;
    reg rst;
    reg [`DATA_WIDTH-1:0] pc_start;

    wire [`DATA_WIDTH-1:0] dbg_x1;
    wire [`DATA_WIDTH-1:0] dbg_x2;
    wire [`DATA_WIDTH-1:0] dbg_x3;
    wire [`DATA_WIDTH-1:0] dbg_x4;
    wire [`DATA_WIDTH-1:0] dbg_x5;
    wire [`DATA_WIDTH-1:0] dbg_x6;
    wire [`DATA_WIDTH-1:0] dbg_x7; 
    wire [`DATA_WIDTH-1:0] dbg_x8;
    
    wire [`DATA_WIDTH-1:0] instruction;
    wire [`DATA_WIDTH-1:0] PC;
    
    wire                   id_branch_taken;
    wire [`DATA_WIDTH-1:0] exe_pc_jump;
    wire [1:0]             id_pc_sel;
    wire [`DATA_WIDTH-1:0] immediate_id_exe;
    wire [`DATA_WIDTH-1:0] pc_id_exe;
    wire                   if_pc_jump_taken;
    wire                   id_stall;

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
        .dbg_x8(dbg_x8),
        
        .instruction_if_id(instruction),
        .pc_if_id(PC),
        .id_branch_taken(id_branch_taken),
        .exe_pc_jump(exe_pc_jump),
        .id_pc_sel(id_pc_sel),
        .immediate_id_exe(immediate_id_exe),
        .pc_id_exe(pc_id_exe),
        .if_pc_jump_taken(if_pc_jump_taken),
        .id_stall(id_stall)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
        $display("inst: %b", instruction);
    end

    initial begin
        rst = 1;
        //pc_start = 32'b0;
        pc_start = 32'b00000000000000000000000000011100;
        
        #20;
        rst = 0;
        
        
        @(posedge clk);
        #1;
        
        #500;
        
        $display("\n====================================================");
        $display("          STATO FINALE DEI REGISTRI (RISC-V)        ");
        $display("====================================================");
        $display("x0: 0x00000000"); // x0 è sempre 0
        $display("x1: 0x%08h  (%0d)", dbg_x1, $signed(dbg_x1));
        $display("x2: 0x%08h  (%0d)", dbg_x2, $signed(dbg_x2));
        $display("x3: 0x%08h  (%0d)", dbg_x3, $signed(dbg_x3));
        $display("x4: 0x%08h  (%0d)", dbg_x4, $signed(dbg_x4));
        $display("x5: 0x%08h  (%0d)", dbg_x5, $signed(dbg_x5));
        $display("x6: 0x%08h  (%0d)", dbg_x6, $signed(dbg_x6));
        $display("x7: 0x%08h  (%0d)", dbg_x7, $signed(dbg_x7));
        $display("x8: 0x%08h  (%0d)", dbg_x8, $signed(dbg_x8));  
        $display("====================================================\n");
        
        
        $finish;
    end

endmodule