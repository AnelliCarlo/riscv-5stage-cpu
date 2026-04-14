`timescale 1ns / 1ps

`include "RISC-V.vh"

module IF(
    input wire clk,
    input wire rst,
    
    input wire [`DATA_WIDTH-1:0] pc_start,

    input wire ID_branch_taken,
    input wire [`DATA_WIDTH-1:0] EXE_pc_jump,
    input wire stall,
    input wire [1:0] pc_sel,

    output wire [`DATA_WIDTH-1:0] pc_out,
    output wire [`DATA_WIDTH-1:0] instruction,
    output wire pc_jump_taken
);

    reg [`DATA_WIDTH-1:0] pc;
    reg [`DATA_WIDTH-1:0] id_pc;
    reg [`DATA_WIDTH-1:0] exe_pc;

    wire [`DATA_WIDTH-1:0] next_pc;
    wire [`DATA_WIDTH-1:0] pc_target;
    wire jump_speculation;
    wire [`DATA_WIDTH-1:0] speculation_pc;
    wire [`DATA_WIDTH-1:0] pc_plus;

    BRANCH_PREDICTION branch_prediction_inst(
        .clk(clk),
        .pc(pc),
        .id_pc(id_pc),
        .exe_pc(exe_pc),
        .ID_branch_taken(ID_branch_taken),
        .EXE_pc_jump(EXE_pc_jump),
        .pc_target(pc_target),
        .jump_speculation(jump_speculation)
    );
    
    
    assign pc_plus = pc + 4;
    
    MUX2_1 mux_prediction(
        .in0(pc_plus),
        .in1(pc_target),
        .sel(jump_speculation),
        .out(speculation_pc)
    );
    
    MUX4_1 mux_pc_new(
        .in0(speculation_pc),
        .in1(id_pc),
        .in2(EXE_pc_jump),
        .in3(32'b0),
        .sel(pc_sel),
        .out(next_pc)
    );
    
    always @(posedge clk) begin
        if (rst) begin
            pc     <= pc_start;
            id_pc  <= 32'b0;
            exe_pc <= 32'b0;
        end
        else if (!stall) begin
            pc     <= next_pc;
            id_pc  <= pc;
            exe_pc <= id_pc;
        end
    end

    INSTRUCTION_MEMORY #(
        .MEM_SIZE(1024),
        .FILE_NAME("program.mem")
    ) instruction_memory_inst (
        .address(pc),
        .instruction(instruction)
    );

    assign pc_out = pc;
    assign pc_jump_taken = jump_speculation;

endmodule