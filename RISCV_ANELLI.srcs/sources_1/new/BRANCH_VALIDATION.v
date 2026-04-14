`timescale 1ns / 1ps

`include "RISC-V.vh"

module BRANCH_VALIDATION(
    input wire branch_en, // Enable signal for B-type instructions (from CONTROL_UNIT)
    input wire [`FUNCT3_WIDTH-1:0] funct3, // Instruction Funct3 field
    
    // Comparison signals from COMPARATOR.v
    input wire equal,
    input wire signed_less,
    input wire signed_greater,
    input wire unsigned_less,
    input wire unsigned_greater,
    
    output reg branch_taken // Output: 1 if the branch condition is met
);

    always @(*) begin
        // Default: If the instruction is not a B-type, the branch is not taken
        if (!branch_en) begin
            branch_taken = 1'b0;
        end else begin
            case (funct3)
                `FN3_BEQ:  branch_taken = equal;                           // Branch if Equal (rs1 == rs2)
                `FN3_BNE:  branch_taken = ~equal;                          // Branch if Not Equal (rs1 != rs2)
                
                // Signed Branch Logic
                `FN3_BLT:  branch_taken = signed_less;                     // Branch if Less Than (rs1 < rs2, signed)
                `FN3_BGE:  branch_taken = signed_greater | equal;          // Branch if Greater or Equal (rs1 >= rs2, signed)
                
                // Unsigned Branch Logic
                `FN3_BLTU: branch_taken = unsigned_less;                   // Branch if Less Than Unsigned (rs1 < rs2, unsigned)
                `FN3_BGEU: branch_taken = unsigned_greater | equal;        // Branch if Greater or Equal Unsigned (rs1 >= rs2, unsigned)
                
                default: branch_taken = 1'b0; // Default: Not taken for undefined Funct3
            endcase
        end
    end
endmodule