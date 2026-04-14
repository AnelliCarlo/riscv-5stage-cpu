`timescale 1ns / 1ps

`include "RISC-V.vh"

module ID(
    input wire clk,
    input wire rst,

    // Pipeline inputs
    input wire [`DATA_WIDTH-1:0] pc_in,
    input wire [`DATA_WIDTH-1:0] instruction,
    input wire pc_jump_taken,

    // Inputs from other pipeline stages
    input wire [`DATA_WIDTH-1:0] EXE_pc_jump,
    input wire [`REG_ADDR_WIDTH-1:0] EXE_rd,
    input wire [`REG_ADDR_WIDTH-1:0] MEM_rd,
    input wire MEM_mem_re,
    input wire MEM_wb_we,
    input wire [`DATA_WIDTH-1:0] MEM_eo_data,
    input wire [`REG_ADDR_WIDTH-1:0] WB_rd,
    input wire [`DATA_WIDTH-1:0] WB_data,
    input wire WB_wb_we,

    output reg [`REG_ADDR_WIDTH-1:0] rd,
    output reg [`REG_ADDR_WIDTH-1:0] rs1,
    output reg [`REG_ADDR_WIDTH-1:0] rs2, 
    output reg [`DATA_WIDTH-1:0] immediate,    
    output reg [`DATA_WIDTH-1:0] rs1_data,
    output reg [`DATA_WIDTH-1:0] rs2_data,

    // EXE signals
    output wire [`ALU_CNTR_WIDTH-1:0] ALUOp,
    output wire ALUIn1,
    output wire ALUIn2,
    output wire EXEOut,

    // MEM signals
    output wire mem_we,
    output wire mem_re,
    output wire [1:0] mem_dim,
    output wire mem_sig,

    // WB signals
    output wire wb_we,
    output wire wb_sel_input,

    // Control signals (not pipeline)
    output wire flush_id_exe_hazard,
    output wire stall,
    output wire flush_if_id,
    output wire flush_id_exe_branch,
    output wire [1:0] pc_sel,
    
    output wire branch_taken,
    
    output wire [`DATA_WIDTH-1:0] dbg_x1,
    output wire [`DATA_WIDTH-1:0] dbg_x2,
    output wire [`DATA_WIDTH-1:0] dbg_x3,
    output wire [`DATA_WIDTH-1:0] dbg_x4,
    output wire [`DATA_WIDTH-1:0] dbg_x5,
    output wire [`DATA_WIDTH-1:0] dbg_x6,
    output wire [`DATA_WIDTH-1:0] dbg_x7,
    output wire [`DATA_WIDTH-1:0] dbg_x8


);

    // Instruction fields
    wire [`REG_ADDR_WIDTH-1:0] rs1_wire;
    wire [`REG_ADDR_WIDTH-1:0] rs2_wire;
    wire [`REG_ADDR_WIDTH-1:0] rd_wire;
    wire [`OPCODE_WIDTH-1:0] opcode;
    wire [`FUNCT3_WIDTH-1:0] funct3;
    wire [`FUNCT7_WIDTH-1:0] funct7;

    // Decode instruction
    instruction_decode instruction_decode_inst (
        .instruction(instruction),
        .rs1(rs1_wire),
        .rs2(rs2_wire),
        .rd(rd_wire),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );

    // Register File
    wire [`DATA_WIDTH-1:0] rs1_data_wire;
    wire [`DATA_WIDTH-1:0] rs2_data_wire;

    REGISTER_FILE register_file_inst (
        .clk(clk),
        .rst(rst),
        .rs1(rs1_wire),
        .rs2(rs2_wire),
        .wb_rd(WB_rd),
        .wb_data(WB_data),
        .wb_we(WB_wb_we),
        .rs1_data(rs1_data_wire),
        .rs2_data(rs2_data_wire),
        
        .dbg_x1(dbg_x1),
        .dbg_x2(dbg_x2),
        .dbg_x3(dbg_x3),
        .dbg_x4(dbg_x4),
        .dbg_x5(dbg_x5),
        .dbg_x6(dbg_x6),
        .dbg_x7(dbg_x7),
        .dbg_x8(dbg_x8)
    );

    // Immediate generator
    wire [`DATA_WIDTH-1:0] immediate_wire;
    IMMEDIATE_GENERATOR immediate_generator_inst (
        .inst(instruction),
        .immediate(immediate_wire)
    );

    // Forwarding Unit
    wire COMPSel1, COMPSel2;
    FORWARDING_UNIT_ID forwarding_unit_id_inst (
        .rs1(rs1_wire),
        .rs2(rs2_wire),
        .MEM_rd(MEM_rd),
        .MEM_mem_re(MEM_mem_re),
        .MEM_wb_we(MEM_wb_we),
        .COMPSel1(COMPSel1),
        .COMPSel2(COMPSel2)
    );

    // MUX to select comparator inputs
    wire [`DATA_WIDTH-1:0] mux_out1;
    wire [`DATA_WIDTH-1:0] mux_out2;

    MUX2_1 mux1_in_comparator (
        .in0(rs1_data_wire),
        .in1(MEM_eo_data),
        .sel(COMPSel1),
        .out(mux_out1)
    );

    MUX2_1 mux2_in_comparator (
        .in0(rs2_data_wire),
        .in1(MEM_eo_data),
        .sel(COMPSel2),
        .out(mux_out2)
    );

    // Comparator
    wire equal, signed_less, signed_greater, unsigned_less, unsigned_greater;
    COMPARATOR comparator_inst (
        .input1(mux_out1),
        .input2(mux_out2),
        .equal(equal),
        .signed_less(signed_less),
        .signed_greater(signed_greater),
        .unsigned_less(unsigned_less),
        .unsigned_greater(unsigned_greater)
    );

    // Control Unit
    //wire branch_taken;
    CONTROL_UNIT control_unit_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(instruction[30]),
        .equal(equal),
        .signed_less(signed_less),
        .signed_greater(signed_greater),
        .unsigned_less(unsigned_less),
        .unsigned_greater(unsigned_greater),
        .branch_taken(branch_taken),
        .ALUOp(ALUOp),
        .ALUIn1(ALUIn1),
        .ALUIn2(ALUIn2),
        .EXEOut(EXEOut),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_dim(mem_dim),
        .mem_sig(mem_sig),
        .wb_we(wb_we),
        .wb_sel_input(wb_sel_input)
    );

    // Hazard Control Unit
    HAZARD_CONTROL_UNIT hazard_control_unit_inst (
        .clk(clk),
        .opcode(opcode),
        .rs1(rs1_wire),
        .rs2(rs2_wire),
        .EXE_rd(EXE_rd),
        .MEM_rd(MEM_rd),
        .flush_id_exe_hazard(flush_id_exe_hazard),
        .stall(stall)
    );

    // Branch Control Unit
    BRANCH_CONTROL_UNIT branch_control_unit_inst (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .branch_taken(branch_taken),
        .pc_jump_taken(pc_jump_taken),
        .pc_id(pc_in),
        .EXE_pc_jump(EXE_pc_jump),
        .flush_if_id(flush_if_id),
        .flush_id_exe_branch(flush_id_exe_branch),
        .pc_sel(pc_sel)
    );

    // Drive outputs
    always @(*) begin
        rs1 = rs1_wire;
        rs2 = rs2_wire;
        rd = rd_wire;
        rs1_data  = mux_out1;
        rs2_data  = mux_out2;
        immediate = immediate_wire;
    end

endmodule
