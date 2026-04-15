`timescale 1ns / 1ps

`include "RISC-V.vh"

module HAZARD_CONTROL_UNIT(
    input wire clk,
    input wire rst,

    input wire [`OPCODE_WIDTH-1:0] opcode,
    input wire [`REG_ADDR_WIDTH-1:0] rs1,
    input wire [`REG_ADDR_WIDTH-1:0] rs2,

    input wire [`REG_ADDR_WIDTH-1:0] EXE_rd,
    input wire [`REG_ADDR_WIDTH-1:0] MEM_rd,

    output reg flush_id_exe_hazard, // Reset ID/EXE register (insert NOP/bubble)
    output reg stall                // Stall PC and IF/ID registers
);

    // ------------------------------------------------------------
    // Pipeline registers for opcode tracking
    // ------------------------------------------------------------
    reg [`OPCODE_WIDTH-1:0] opcode_exe; 
    reg [`OPCODE_WIDTH-1:0] opcode_mem; 

    wire id_reads_rs1;
    wire id_reads_rs2;

    assign id_reads_rs1 =
        (opcode == `RTYPE)  ||
        (opcode == `ITYPE1) ||
        (opcode == `ITYPE2) ||
        (opcode == `ITYPE3) ||
        (opcode == `STYPE)  ||
        (opcode == `BTYPE);

    assign id_reads_rs2 =
        (opcode == `RTYPE)  ||
        (opcode == `STYPE)  ||
        (opcode == `BTYPE);

    wire exe_writes_rd;
    wire mem_writes_rd;

    assign exe_writes_rd =
        (opcode_exe == `RTYPE)  ||
        (opcode_exe == `ITYPE1) ||
        (opcode_exe == `ITYPE2) ||
        (opcode_exe == `ITYPE3) ||
        (opcode_exe == `UTYPE1) ||
        (opcode_exe == `UTYPE2) ||
        (opcode_exe == `JTYPE);

    assign mem_writes_rd =
        (opcode_mem == `RTYPE)  ||
        (opcode_mem == `ITYPE1) ||
        (opcode_mem == `ITYPE2) ||
        (opcode_mem == `ITYPE3) ||
        (opcode_mem == `UTYPE1) ||
        (opcode_mem == `UTYPE2) ||
        (opcode_mem == `JTYPE);

    // ------------------------------------------------------------
    // 1. Load-Use Hazard Detection
    // Occurs when an instruction attempts to read a register 
    // that is currently being loaded from memory by the previous instruction.
    // ------------------------------------------------------------
    wire exe_is_load;
    assign exe_is_load = (opcode_exe == `ITYPE2);
    
    wire mem_is_load;
    assign mem_is_load = (opcode_mem == `ITYPE2);
    
    wire id_is_branch;
    assign id_is_branch = (opcode == `BTYPE);

    wire hazard_load_use;
    assign hazard_load_use =
        exe_is_load &&
        (EXE_rd != `ZEROREG) &&
        (
            (id_reads_rs1 && (rs1 == EXE_rd)) ||
            (id_reads_rs2 && (rs2 == EXE_rd))
        ) ||
        (
            mem_is_load && 
            id_is_branch && 
            (MEM_rd != `ZEROREG) && 
            ((rs1 == MEM_rd) || (rs2 == MEM_rd))
        );

    // ------------------------------------------------------------
    // 2. Branch Hazard Detection (Data Dependency)
    // If there is a branch instruction in ID, and the instruction in
    // EXE is writing to the registers the branch needs to compare,
    // we must stall to allow the write-back to complete or forward.
    // ------------------------------------------------------------

    wire hazard_branch;
    assign hazard_branch = 
        id_is_branch && (
            (exe_writes_rd && (EXE_rd != `ZEROREG) && ((rs1 == EXE_rd) || (rs2 == EXE_rd)))
        );

    // ------------------------------------------------------------
    // Global Hazard Flag (Union of all stall conditions)
    // ------------------------------------------------------------
    wire hazard_detected;
    assign hazard_detected = hazard_load_use || hazard_branch;

    // ------------------------------------------------------------
    // Control outputs logic
    // ------------------------------------------------------------
    always @(*) begin
        if (hazard_detected) begin
            stall               = 1'b1;
            flush_id_exe_hazard = 1'b1;
        end else begin
            stall               = 1'b0;
            flush_id_exe_hazard = 1'b0;
        end
    end

    // ------------------------------------------------------------
    // Opcode pipeline update
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            // Reset state: fill pipeline tracking with NOPs (ADDI x0, x0, 0)
            opcode_exe <= `ITYPE1; 
            opcode_mem <= `ITYPE1;  
        end else if (hazard_detected) begin
            // Stall condition: hold MEM, insert bubble into EXE
            opcode_mem <= opcode_exe;
            opcode_exe <= `ITYPE1; // Insert NOP to resolve hazard
        end else begin
            // Normal execution: shift opcodes down the pipeline
            opcode_mem <= opcode_exe;
            opcode_exe <= opcode;
        end
    end

endmodule