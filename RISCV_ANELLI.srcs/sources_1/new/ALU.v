`timescale 1ns / 1ps

`include "RISC-V.vh"

module ALU(
    input wire [`DATA_WIDTH-1:0] In1,
    input wire [`DATA_WIDTH-1:0] In2,
    input wire [`ALU_CNTR_WIDTH-1:0] ALUOp,
    
    output reg [`DATA_WIDTH-1:0] ALUOut
);

    always @(*) begin
        case (ALUOp)
            `ALU_ADD:  ALUOut = In1 + In2;
            `ALU_SUB:  ALUOut = In1 - In2;
            `ALU_SLL:  ALUOut = In1 << In2[4:0];
            `ALU_SRL:  ALUOut = In1 >> In2[4:0];
            `ALU_SRA:  ALUOut = $signed(In1) >>> In2[4:0];
            `ALU_AND:  ALUOut = In1 & In2;
            `ALU_OR:   ALUOut = In1 | In2;
            `ALU_XOR:  ALUOut = In1 ^ In2;
            `ALU_SLT:  ALUOut = ($signed(In1) < $signed(In2)) ? 32'b1 : 32'b0;
            `ALU_SLTU: ALUOut = (In1 < In2) ? 32'b1 : 32'b0;
            `ALU_LUI:  ALUOut = In2;
            `ALU_NOP:  ALUOut = 32'b0;
            default:   ALUOut = 32'b0;
        endcase
    end

endmodule