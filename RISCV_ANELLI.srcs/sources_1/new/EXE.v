`timescale 1ns / 1ps

`include "RISC-V.vh"

module EXE(
    // --- EXE Stage Inputs ---
    input wire [`DATA_WIDTH-1:0] pc_in,    
    input wire [`REG_ADDR_WIDTH-1:0] rs1,
    input wire [`REG_ADDR_WIDTH-1:0] rs2,
    input wire [`DATA_WIDTH-1:0] immediate,
    input wire [`DATA_WIDTH-1:0] rs1_data,
    input wire [`DATA_WIDTH-1:0] rs2_data,

    input wire [`ALU_CNTR_WIDTH-1:0] ALUOp,
    input wire ALUIn1,
    input wire ALUIn2,
    input wire EXEOut, // 0: EXE_OUT_DATA = ALU, 1: EXE_OUT_DATA = PC + 4

    
    // Inputs from other pipeline stages
    input wire [`REG_ADDR_WIDTH-1:0] MEM_rd,
    input wire MEM_mem_re,
    input wire MEM_wb_we,
    input wire [`DATA_WIDTH-1:0] MEM_eo_data,
    input wire [`REG_ADDR_WIDTH-1:0] WB_rd,
    input wire [`DATA_WIDTH-1:0] WB_data,
    input wire WB_wb_we,
    
    // Outputs
    output reg [`DATA_WIDTH-1:0] rs2_data_out,
    output reg [`DATA_WIDTH-1:0] eo_data, // EXE_OUT_DATA
    output reg [`DATA_WIDTH-1:0] pc_jump // ALUOut
);
    
    wire ForwardSel1;
    wire ForwardSel2;
    wire [`DATA_WIDTH-1:0] ForwardedData1;
    wire [`DATA_WIDTH-1:0] ForwardedData2;

    FORWARDING_UNIT_EXE forwarding_unit_exe_inst (
        .rs1(rs1),
        .rs2(rs2),
        .MEM_rd(MEM_rd),
        .MEM_mem_re(MEM_mem_re),
        .MEM_wb_we(MEM_wb_we),
        .MEM_eo_data(MEM_eo_data),
        .WB_rd(WB_rd),
        .WB_data(WB_data),
        .WB_wb_we(WB_wb_we),
        .ForwardSel1(ForwardSel1),
        .ForwardSel2(ForwardSel2),
        .ForwardedData1(ForwardedData1),
        .ForwardedData2(ForwardedData2)
    );
    
    wire [`DATA_WIDTH-1:0] rs1_data_fwd;
    wire [`DATA_WIDTH-1:0] rs2_data_fwd;
    
    MUX2_1 mux_forward1 (
        .in0(rs1_data),
        .in1(ForwardedData1),
        .sel(ForwardSel1),
        .out(rs1_data_fwd)
    );
    
    MUX2_1 mux_forward2 (
        .in0(rs2_data),
        .in1(ForwardedData2),
        .sel(ForwardSel2),
        .out(rs2_data_fwd)
    );
    
    wire [`DATA_WIDTH-1:0] Input1_ALU;
    wire [`DATA_WIDTH-1:0] Input2_ALU;
    
    MUX2_1 mux_ALUIn1 (
        .in0(rs1_data_fwd),
        .in1(pc_in),
        .sel(ALUIn1),
        .out(Input1_ALU)
    );
    
    MUX2_1 mux_ALUIn2 (
        .in0(rs2_data_fwd),
        .in1(immediate),
        .sel(ALUIn2),
        .out(Input2_ALU)
    );
    
    wire [`DATA_WIDTH-1:0] ALUOut;
    
    
    ALU alu_inst(
        .In1(Input1_ALU),
        .In2(Input2_ALU),
        .ALUOp(ALUOp),
        .ALUOut(ALUOut)
    );
    
    
    // PC + 4 logic
    wire [`DATA_WIDTH-1:0] pc_plus_4;
    assign pc_plus_4 = pc_in + 4;

    // Temporary wire for MUX output to connect to eo_data reg
    wire [`DATA_WIDTH-1:0] eo_data_wire;
    
    MUX2_1 mux_exe_out (
        .in0(ALUOut),
        .in1(pc_plus_4),
        .sel(EXEOut),
        .out(eo_data_wire)
    );

    // -----------------------------------------------------------------
    // Output Connections
    // -----------------------------------------------------------------
    
    // Assigning reg outputs inside an always block
    always @(*) begin
        rs2_data_out = rs2_data_fwd; // Send forwarded data, not the old one
        eo_data      = eo_data_wire;
        pc_jump = ALUOut;
    end


endmodule
