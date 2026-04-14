`timescale 1ns / 1ps

`include "RISC-V.vh"

module BRANCH_CONTROL_UNIT(
    input wire clk,
    input wire rst,
    input wire stall,

    // --- Inputs from IF/ID and EXE ---
    input wire branch_taken,         // final branch decision in ID
    input wire pc_jump_taken,        // prediction used in IF
    input wire [`DATA_WIDTH-1:0] pc_id,          // PC of current instruction in ID
    input wire [`DATA_WIDTH-1:0] EXE_pc_jump,    // target calculated in EXE

    // --- Outputs to control pipeline and PC mux ---
    output reg flush_if_id,          // NOP IF/ID
    output reg flush_id_exe_branch,  // NOP ID/EXE
    output reg [1:0] pc_sel          // 00=pc_predicted, 01=pc_id+4, 10=EXE_pc_jump
);

    // --- Internal registers for EXE stage resolution ---
    reg branch_valid;
    reg prediction_was_taken; // Remembers the prediction made in IF

    // --- Update state at rising clock ---
    always @(posedge clk) begin
        if (rst) begin
            branch_valid         <= 1'b0;
            prediction_was_taken <= 1'b0;
        end else if (stall) begin           
            branch_valid         <= 1'b0;  
            prediction_was_taken <= 1'b0;     
        end else begin
            // If ID decides the instruction MUST branch (Cases 01 and 11)
            // set the flag for the next clock cycle in EXE.
            if (branch_taken) begin
                branch_valid         <= 1'b1;
                prediction_was_taken <= pc_jump_taken;
            end else begin
                branch_valid         <= 1'b0;
                prediction_was_taken <= 1'b0;
            end
        end
    end

    // --- Combinatorial logic for branch control ---
    always @(*) begin
        // Default values: pipeline flows normally
        flush_if_id         = 1'b0;
        flush_id_exe_branch = 1'b0;
        pc_sel              = 2'b00;

        // ====================================================================
        // PHASE 2: RESOLUTION IN EXE (The cycle AFTER the Branch was in ID)
        // ====================================================================
        if (branch_valid) begin
            
            if (prediction_was_taken == 1'b0) begin
                // RESOLVING CASE 01:
                // ID knew a branch was required, but we waited for the target address.
                // Now the address is ready in EXE!
                pc_sel              = 2'b10; // Jump to the calculated target
                flush_if_id         = 1'b1;  // Flush the garbage instruction in IF
                flush_id_exe_branch = 1'b1;  // Flush the bubble that was in ID
            end 
            else if (pc_id != EXE_pc_jump) begin
                // RESOLVING CASE 11:
                // We branched, but here in EXE we discover that the address (pc_id)
                // we landed on is NOT equal to the calculated target! Target mismatch!
                pc_sel              = 2'b10; // Correct the path with the right target!
                flush_if_id         = 1'b1;  // Flush the pipeline
                flush_id_exe_branch = 1'b1;
            end
            
        end 
        
        // ====================================================================
        // PHASE 1: DECODE IN ID (The cycle where we read the instruction)
        // ====================================================================
        else begin
            if (stall) begin               
                pc_sel      = 2'b00;
                flush_if_id = 1'b0;
            end         
            case ({pc_jump_taken, branch_taken})
                2'b00: begin
                    // CASE 00: Not predicted, not taken. Everything is fine.
                    pc_sel = 2'b00;
                end

                2'b01: begin
                    // CASE 01: Not predicted, BUT MUST BRANCH.
                    // The target address will only be available next cycle in EXE.
                    // For now, stall the fetch of new instructions.
                    flush_if_id = 1'b1; 
                    pc_sel      = 2'b00; // Wait for the next cycle to change the PC
                end

                2'b10: begin
                    // CASE 10: Predicted taken, BUT SHOULD NOT BRANCH.
                    // We can fix this immediately by returning to PC+4 (pc_sel = 01).
                    flush_if_id = 1'b1;  // Kill the wrongly fetched instruction
                    pc_sel      = 2'b01; // Return to the instruction after the Branch
                end

                2'b11: begin
                    // CASE 11: Predicted taken and MUST BRANCH.
                    // Looks good, let it flow. The target address verification
                    // will happen in the next cycle during "PHASE 2".
                    pc_sel = 2'b00;
                end
            endcase
        end
    end

endmodule