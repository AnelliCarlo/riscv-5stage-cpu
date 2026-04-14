`timescale 1ns / 1ps
`include "RISC-V.vh"

module ID_tb;

    // Clock and Reset
    reg clk;
    reg rst;

    // Inputs
    reg [`DATA_WIDTH-1:0] pc_in;
    reg [`DATA_WIDTH-1:0] instruction;
    reg pc_jump_taken;
    reg [`DATA_WIDTH-1:0] EXE_pc_jump;
    reg [`REG_ADDR_WIDTH-1:0] EXE_rd;
    reg [`REG_ADDR_WIDTH-1:0] MEM_rd;
    reg MEM_mem_re;
    reg MEM_wb_we;
    reg [`DATA_WIDTH-1:0] MEM_eo_data;
    reg [`REG_ADDR_WIDTH-1:0] WB_rd;
    reg [`DATA_WIDTH-1:0] WB_data;
    reg WB_wb_we;

    // Outputs
    wire [`DATA_WIDTH-1:0] pc_out;
    wire [`DATA_WIDTH-1:0] rs1_data;
    wire [`DATA_WIDTH-1:0] rs2_data;
    wire [`DATA_WIDTH-1:0] immediate;
    wire [`REG_ADDR_WIDTH-1:0] rd;
    wire [`REG_ADDR_WIDTH-1:0] rs1;
    wire [`REG_ADDR_WIDTH-1:0] rs2;
    wire [`ALU_CNTR_WIDTH-1:0] ALUOp;
    wire ALUIn1, ALUIn2, EXEOut;
    wire mem_we, mem_re;
    wire [1:0] mem_dim;
    wire mem_sig;
    wire wb_we, wb_sel_input;
    wire flush_id_exe_hazard, stall, flush_if_id, flush_id_exe_branch;
    wire [1:0] pc_sel;

    // Instantiate ID module
    ID uut (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .instruction(instruction),
        .pc_jump_taken(pc_jump_taken),
        .EXE_pc_jump(EXE_pc_jump),
        .EXE_rd(EXE_rd),
        .MEM_rd(MEM_rd),
        .MEM_mem_re(MEM_mem_re),
        .MEM_wb_we(MEM_wb_we),
        .MEM_eo_data(MEM_eo_data),
        .WB_rd(WB_rd),
        .WB_data(WB_data),
        .WB_wb_we(WB_wb_we),
        .pc_out(pc_out),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .ALUOp(ALUOp),
        .ALUIn1(ALUIn1),
        .ALUIn2(ALUIn2),
        .EXEOut(EXEOut),
        .mem_we(mem_we),
        .mem_re(mem_re),
        .mem_dim(mem_dim),
        .mem_sig(mem_sig),
        .wb_we(wb_we),
        .wb_sel_input(wb_sel_input),
        .flush_id_exe_hazard(flush_id_exe_hazard),
        .stall(stall),
        .flush_if_id(flush_if_id),
        .flush_id_exe_branch(flush_id_exe_branch),
        .pc_sel(pc_sel)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns period

    // Test procedure
    initial begin
        rst = 1;
        pc_in = 0;
        instruction = 32'b0;
        pc_jump_taken = 0;
        EXE_pc_jump = 0;
        EXE_rd = 0;
        MEM_rd = 0;
        MEM_mem_re = 0;
        MEM_wb_we = 0;
        MEM_eo_data = 0;
        WB_rd = 0;
        WB_data = 0;
        WB_wb_we = 0;

        #20;
        rst = 0;
        
        @(posedge clk);
        #1;

        // Read input file
        $display("Loading test vectors from file...");
        $readmemb("ID_input_vectors.txt", test_vectors);
        $display("VECTOR_COUNT = %0d", VECTOR_COUNT);

        // Apply each vector
        for (integer i = 0; i < VECTOR_COUNT; i = i + 1) begin
            {pc_in, instruction, pc_jump_taken, EXE_pc_jump,
             EXE_rd, MEM_rd, MEM_mem_re, MEM_wb_we, MEM_eo_data, WB_rd, WB_data, WB_wb_we} = test_vectors[i];

            @(posedge clk);
            #1;
            $display("=======================================");
            $display("CICLO %0d | Istruzione: %h", i, instruction);
            $display("pc = %d", pc_in);
            //$display("-> ALU Opcode : %b", ALUOp);
            $display("-> Registri   : rs1 %d = %d | rs2 %d = %d", rs1, rs1_data, rs2, rs2_data);
            //$display("-> Hazard/Stall: Stall = %b | Flush = %b", stall, flush_id_exe_hazard);
            $display("=======================================\n");
        end

        #50 $finish;
    end

    // Parameters for file-driven simulation
    parameter VECTOR_COUNT = 4; // Number of test vectors
    reg [178:0] test_vectors [0:VECTOR_COUNT-1]; // adjust width according to inputs

endmodule