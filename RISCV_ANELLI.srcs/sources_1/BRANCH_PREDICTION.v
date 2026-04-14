`timescale 1ns / 1ps

`include "RISC-V.vh"

module BRANCH_PREDICTION #(
    parameter INDEX_BITS = 8
)(
    input wire clk,

    input wire [`DATA_WIDTH-1:0] pc,
    input wire [`DATA_WIDTH-1:0] id_pc,
    input wire [`DATA_WIDTH-1:0] exe_pc,
    input wire ID_branch_taken,
    input wire [`DATA_WIDTH-1:0] EXE_pc_jump,
    
    output wire [`DATA_WIDTH-1:0] pc_target,
    output wire jump_speculation
);

    localparam ENTRIES = 1 << INDEX_BITS;

    reg [`DATA_WIDTH-1:0] target_table [0:ENTRIES-1];
    reg [1:0] history_table [0:ENTRIES-1];
    
    integer i;
    initial begin
        for (i = 0; i < ENTRIES; i = i + 1) begin
            target_table[i]  = 32'b0;
            history_table[i] = 2'b00; // 00 = Strongly Not Taken
        end
    end

    wire [INDEX_BITS-1:0] fetch_idx;
    wire [INDEX_BITS-1:0] id_idx;
    wire [INDEX_BITS-1:0] exe_idx;

    assign fetch_idx = pc[INDEX_BITS+1:2];
    assign id_idx    = id_pc[INDEX_BITS+1:2];
    assign exe_idx   = exe_pc[INDEX_BITS+1:2];

    always @(posedge clk) begin
        target_table[exe_idx] <= EXE_pc_jump;
        if (ID_branch_taken) begin
            if (history_table[id_idx] != 2'b11)
                history_table[id_idx] <= history_table[id_idx] + 2'b01;
        end else begin
            if (history_table[id_idx] != 2'b00)
                history_table[id_idx] <= history_table[id_idx] - 2'b01;
        end
    end

    assign pc_target = target_table[fetch_idx];
    assign jump_speculation = history_table[fetch_idx][1];

endmodule