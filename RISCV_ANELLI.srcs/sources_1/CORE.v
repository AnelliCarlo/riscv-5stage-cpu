`timescale 1ns / 1ps
`include "RISC-V.vh"

module CORE (
    input wire clk,
    input wire rst,
    
    // Initial PC value
    input wire [`DATA_WIDTH-1:0] pc_start,
    
    // Debug outputs for registers
    output wire [`DATA_WIDTH-1:0] dbg_x1,
    output wire [`DATA_WIDTH-1:0] dbg_x2,
    output wire [`DATA_WIDTH-1:0] dbg_x3,
    output wire [`DATA_WIDTH-1:0] dbg_x4,
    output wire [`DATA_WIDTH-1:0] dbg_x5,
    output wire [`DATA_WIDTH-1:0] dbg_x6,
    output wire [`DATA_WIDTH-1:0] dbg_x7,
    output wire [`DATA_WIDTH-1:0] dbg_x8,
    
    output reg [`DATA_WIDTH-1:0] instruction_if_id,
    output reg [`DATA_WIDTH-1:0] pc_if_id,
    output wire                   id_branch_taken,
    output wire [`DATA_WIDTH-1:0] exe_pc_jump,
    output wire [1:0]             id_pc_sel,
    output reg [`DATA_WIDTH-1:0] immediate_id_exe,
    output reg [`DATA_WIDTH-1:0] pc_id_exe,
    output wire                   if_pc_jump_taken,
    output wire                   id_stall

);

    // ========================================================================
    // Pipeline Registers Declarations
    // ========================================================================

    // IF/ID Stage
    
    
    
    reg                   pc_jump_taken_if_id;

    // ID/EXE Stage
    //reg [`DATA_WIDTH-1:0] pc_id_exe;
    reg [4:0]             rd_id_exe;
    reg [`REG_ADDR_WIDTH-1:0] rs1_id_exe;
    reg [`REG_ADDR_WIDTH-1:0] rs2_id_exe;
    //reg [`DATA_WIDTH-1:0] immediate_id_exe;
    reg [`DATA_WIDTH-1:0] rs1_data_id_exe;
    reg [`DATA_WIDTH-1:0] rs2_data_id_exe;
    reg                   wb_we_id_exe;
    reg                   wb_sel_input_id_exe;
    reg                   mem_we_id_exe;
    reg                   mem_re_id_exe;
    reg [1:0]             mem_dim_id_exe;
    reg                   mem_sig_id_exe;
    reg [3:0]             ALUOp_id_exe;
    reg                   ALUIn1_id_exe;
    reg                   ALUIn2_id_exe;
    reg                   EXEOut_id_exe;

    // EXE/MEM Stage
    reg [4:0]             rd_exe_mem;
    reg [4:0]             rs2_exe_mem;
    reg [`DATA_WIDTH-1:0] rs2_data_exe_mem;
    reg                   wb_we_exe_mem;
    reg                   wb_sel_input_exe_mem;
    reg                   mem_we_exe_mem;
    reg                   mem_re_exe_mem;
    reg [1:0]             mem_dim_exe_mem;
    reg                   mem_sig_exe_mem;
    reg [`DATA_WIDTH-1:0] eo_data_exe_mem;

    // MEM/WB Stage
    reg [4:0]             rd_mem_wb;
    reg                   wb_we_mem_wb;
    reg                   wb_sel_input_mem_wb;
    reg [`DATA_WIDTH-1:0] eo_data_mem_wb;
    reg [`DATA_WIDTH-1:0] mem_data_mem_wb;

    // ========================================================================
    // Stage Wires Declarations
    // ========================================================================

    // IF Outputs
    wire [`DATA_WIDTH-1:0] if_pc_out;
    wire [`DATA_WIDTH-1:0] if_instruction;
    //wire                   if_pc_jump_taken;
    
    // ID Outputs
    wire [4:0]             id_rd;
    wire [4:0]             id_rs1;
    wire [4:0]             id_rs2;
    wire [`DATA_WIDTH-1:0] id_immediate;
    wire [`DATA_WIDTH-1:0] id_rs1_data;
    wire [`DATA_WIDTH-1:0] id_rs2_data;
    wire                   id_wb_we;
    wire                   id_wb_sel_input;
    wire                   id_mem_we;
    wire                   id_mem_re;
    wire [1:0]             id_mem_dim;
    wire                   id_mem_sig;
    wire [3:0]             id_ALUOp;
    wire                   id_ALUIn1;
    wire                   id_ALUIn2;
    wire                   id_EXEOut;
    
    // ID Control / Hazard Outputs
    
    //wire                   id_stall;
    //wire [1:0]             id_pc_sel;
    wire                   id_flush_if_id;
    wire                   id_flush_id_exe_branch;
    wire                   id_flush_id_exe_hazard;

    // EXE Outputs
    wire [`DATA_WIDTH-1:0] exe_rs2_data_out;
    wire [`DATA_WIDTH-1:0] exe_eo_data;
    

    // MEM Outputs
    wire [`DATA_WIDTH-1:0] mem_eo_data_out;
    wire [`DATA_WIDTH-1:0] mem_mem_data;

    // WB Outputs
    wire [`DATA_WIDTH-1:0] wb_data;

    // ========================================================================
    // Stages Instantiations
    // ========================================================================
    
    IF if_stage (
        // --- input ---
        .clk(clk),
        .rst(rst),
        .pc_start(pc_start),
        .ID_branch_taken(id_branch_taken),
        .EXE_pc_jump(exe_pc_jump),
        .stall(id_stall),
        .pc_sel(id_pc_sel),
        
        // --- output ---
        .pc_out(if_pc_out),
        .instruction(if_instruction),
        .pc_jump_taken(if_pc_jump_taken)
    );

    ID id_stage (
        // --- input ---
        .clk(clk),
        .rst(rst),
        .pc_in(pc_if_id),
        .instruction(instruction_if_id),
        .pc_jump_taken(pc_jump_taken_if_id),
        .EXE_pc_jump(exe_pc_jump),
        .EXE_rd(rd_id_exe),
        .MEM_rd(rd_exe_mem),
        .MEM_mem_re(mem_re_exe_mem),
        .MEM_wb_we(wb_we_exe_mem),
        .MEM_eo_data(eo_data_exe_mem),
        .WB_rd(rd_mem_wb),
        .WB_wb_we(wb_we_mem_wb),
        .WB_data(wb_data),
        
        // --- output ---
        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .immediate(id_immediate),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .wb_we(id_wb_we),
        .wb_sel_input(id_wb_sel_input),
        .mem_we(id_mem_we),
        .mem_re(id_mem_re),
        .mem_dim(id_mem_dim),
        .mem_sig(id_mem_sig),
        .ALUOp(id_ALUOp),
        .ALUIn1(id_ALUIn1),
        .ALUIn2(id_ALUIn2),
        .EXEOut(id_EXEOut),
    
        .flush_id_exe_hazard(id_flush_id_exe_hazard),
        .stall(id_stall),
        .flush_if_id(id_flush_if_id),
        .flush_id_exe_branch(id_flush_id_exe_branch),
        .pc_sel(id_pc_sel),
        .branch_taken(id_branch_taken),
    
        .dbg_x1(dbg_x1),
        .dbg_x2(dbg_x2),
        .dbg_x3(dbg_x3),
        .dbg_x4(dbg_x4),
        .dbg_x5(dbg_x5),
        .dbg_x6(dbg_x6),
        .dbg_x7(dbg_x7),
        .dbg_x8(dbg_x8)
    );
   
    EXE exe_stage (
        // --- input ---
        .pc_in(pc_id_exe),
        .rs1(rs1_id_exe),
        .rs2(rs2_id_exe),
        .immediate(immediate_id_exe),
        .rs1_data(rs1_data_id_exe),
        .rs2_data(rs2_data_id_exe),
   
        .ALUOp(ALUOp_id_exe),
        .ALUIn1(ALUIn1_id_exe),
        .ALUIn2(ALUIn2_id_exe),
        .EXEOut(EXEOut_id_exe),
   
        .MEM_rd(rd_exe_mem),
        .MEM_mem_re(mem_re_exe_mem),
        .MEM_wb_we(wb_we_exe_mem),
        .MEM_eo_data(eo_data_exe_mem),
        .WB_rd(rd_mem_wb),
        .WB_wb_we(wb_we_mem_wb),
        .WB_data(wb_data),
        
        // --- output ---
        .rs2_data_out(exe_rs2_data_out),
        .eo_data(exe_eo_data),
        .pc_jump(exe_pc_jump)
    );

    MEM mem_stage (
        // --- input ---
        .clk(clk),
        .rs2(rs2_exe_mem),
        .rs2_data(rs2_data_exe_mem),
        .mem_we(mem_we_exe_mem),
        .mem_re(mem_re_exe_mem),
        .mem_dim(mem_dim_exe_mem),
        .mem_sig(mem_sig_exe_mem),
        .eo_data(eo_data_exe_mem),
        
        .WB_rd(rd_mem_wb),
        .WB_wb_we(wb_we_mem_wb),
        .WB_data(wb_data),
        
        // --- output ---
        .eo_data_out(mem_eo_data_out),
        .mem_data(mem_mem_data)
    );

    WB wb_stage (
        // --- input ---
        .wb_sel_input(wb_sel_input_mem_wb),
        .eo_data(eo_data_mem_wb),
        .mem_data(mem_data_mem_wb),
        
        // --- output ---
        .data(wb_data)
    );

    // ========================================================================
    // Pipeline Registers Sequential Logic
    // ========================================================================


always @(posedge clk) begin
        if (rst) begin
            // Reset IF/ID
            pc_if_id            <= 0;
            instruction_if_id   <= 0;
            pc_jump_taken_if_id <= 0;

            // Reset ID/EXE
            pc_id_exe           <= 0;
            rd_id_exe           <= 0;
            rs1_id_exe          <= 0;
            rs2_id_exe          <= 0;
            immediate_id_exe    <= 0;
            rs1_data_id_exe     <= 0;
            rs2_data_id_exe     <= 0;
            wb_we_id_exe        <= 0;
            wb_sel_input_id_exe <= 0;
            mem_we_id_exe       <= 0;
            mem_re_id_exe       <= 0;
            mem_dim_id_exe      <= 0;
            mem_sig_id_exe      <= 0;
            ALUOp_id_exe        <= 0;
            ALUIn1_id_exe       <= 0;
            ALUIn2_id_exe       <= 0;
            EXEOut_id_exe       <= 0;

            // Reset EXE/MEM
            rd_exe_mem           <= 0;
            rs2_exe_mem          <= 0;
            rs2_data_exe_mem     <= 0;
            wb_we_exe_mem        <= 0;
            wb_sel_input_exe_mem <= 0;
            mem_we_exe_mem       <= 0;
            mem_re_exe_mem       <= 0;
            mem_dim_exe_mem      <= 0;
            mem_sig_exe_mem      <= 0;
            eo_data_exe_mem      <= 0;

            // Reset MEM/WB
            rd_mem_wb            <= 0;
            wb_we_mem_wb         <= 0;
            wb_sel_input_mem_wb  <= 0;
            eo_data_mem_wb       <= 0;
            mem_data_mem_wb      <= 0;
        end else begin
            // --- IF/ID Register ---
            if (id_stall) begin
                // Highest priority: Stall. Hold current values (do nothing).
            end else if (id_flush_if_id) begin
                // Medium priority: Flush. Insert NOP.
                pc_if_id            <= 0;
                instruction_if_id   <= 32'h00000013; // NOP (addi x0, x0, 0)
                pc_jump_taken_if_id <= 0;
            end else begin
                // Lowest priority: Normal pipeline flow.
                pc_if_id            <= if_pc_out;
                instruction_if_id   <= if_instruction;
                pc_jump_taken_if_id <= if_pc_jump_taken;
            end
            
            // --- ID/EXE Register ---
            // If there is a stall (hazard) or a branch was taken, we must flush the instruction
            // moving into EXE to prevent it from executing. We insert a "bubble" (all zeros/inactive).
            if (id_flush_id_exe_hazard || id_flush_id_exe_branch) begin
                pc_id_exe           <= 0;
                rd_id_exe           <= 0;
                rs1_id_exe          <= 0;
                rs2_id_exe          <= 0;
                immediate_id_exe    <= 0;
                rs1_data_id_exe     <= 0;
                rs2_data_id_exe     <= 0;
                wb_we_id_exe        <= 0; // Disable write-back
                wb_sel_input_id_exe <= 0;
                mem_we_id_exe       <= 0; // Disable memory write
                mem_re_id_exe       <= 0; // Disable memory read
                mem_dim_id_exe      <= 0;
                mem_sig_id_exe      <= 0;
                ALUOp_id_exe        <= 0;
                ALUIn1_id_exe       <= 0;
                ALUIn2_id_exe       <= 0;
                EXEOut_id_exe       <= 0;
            end else begin
                pc_id_exe           <= pc_if_id;
                rd_id_exe           <= id_rd;
                rs1_id_exe          <= id_rs1;
                rs2_id_exe          <= id_rs2;
                immediate_id_exe    <= id_immediate;
                rs1_data_id_exe     <= id_rs1_data;
                rs2_data_id_exe     <= id_rs2_data;
                wb_we_id_exe        <= id_wb_we;
                wb_sel_input_id_exe <= id_wb_sel_input;
                mem_we_id_exe       <= id_mem_we;
                mem_re_id_exe       <= id_mem_re;
                mem_dim_id_exe      <= id_mem_dim;
                mem_sig_id_exe      <= id_mem_sig;
                ALUOp_id_exe        <= id_ALUOp;
                ALUIn1_id_exe       <= id_ALUIn1;
                ALUIn2_id_exe       <= id_ALUIn2;
                EXEOut_id_exe       <= id_EXEOut;
            end

            // --- EXE/MEM Register (Never stalls, just passes data) ---
            rd_exe_mem           <= rd_id_exe;
            rs2_exe_mem          <= rs2_id_exe;
            rs2_data_exe_mem     <= exe_rs2_data_out;
            wb_we_exe_mem        <= wb_we_id_exe;
            wb_sel_input_exe_mem <= wb_sel_input_id_exe;
            mem_we_exe_mem       <= mem_we_id_exe;
            mem_re_exe_mem       <= mem_re_id_exe;
            mem_dim_exe_mem      <= mem_dim_id_exe;
            mem_sig_exe_mem      <= mem_sig_id_exe;
            eo_data_exe_mem      <= exe_eo_data;

            // --- MEM/WB Register (Never stalls, just passes data) ---
            rd_mem_wb            <= rd_exe_mem;
            wb_we_mem_wb         <= wb_we_exe_mem;
            wb_sel_input_mem_wb  <= wb_sel_input_exe_mem;
            eo_data_mem_wb       <= mem_eo_data_out;
            mem_data_mem_wb      <= mem_mem_data;
        end
    end
endmodule