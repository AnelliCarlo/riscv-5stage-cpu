`timescale 1ns / 1ps

`include "RISC-V.vh"

module CONTROL_UNIT(
    input wire [`OPCODE_WIDTH-1:0] opcode,
    input wire [`FUNCT3_WIDTH-1:0] funct3,
    input wire funct7_5,           // Instruction bit [30] (for ADD/SUB, SRL/SRA distinction)
    
    // --- Branch Comparison Inputs ---
    input wire equal,             // rs1 == rs2
    input wire signed_less,       // input1 < input2 (Signed)
    input wire signed_greater,    // input1 > input2 (Signed)
    input wire unsigned_less,     // input1 < input2 (Unsigned)
    input wire unsigned_greater,  // input1 > input2 (Unsigned)
    
    // --- Branch Control ---
    output reg branch_taken,    // 1 if the instruction is J-type or B-type and taken
    
    // --- EXE ---
    output reg [`ALU_CNTR_WIDTH-1:0] ALUOp, // Direct 4-bit ALU Control Code
    output reg ALUIn1,          // Selects ALU Input 1 (0: rs1_data, 1: pc)
    output reg ALUIn2,          // Selects ALU Input 2 (0: rs2_data, 1: immediate)
    output reg EXEOut,          // Selects EXECUTION data out (0: ALUResult, 1: PC+4)
    
    // --- MEM Control Signals ---
    output reg mem_we,          // Memory Write Enable (Store)
    output reg mem_re,          // Memory Read Enable (Load)
    output reg [1:0] mem_dim,   // Memory access dimension
    output reg mem_sig,         // Memory sign bit
    
    // --- WB Control Signals ---
    output reg wb_we,           // Register File Write Enable
    output reg wb_sel_input     // MUX in WB: 0=EXE Result (ALU/PC+4), 1=Memory Data
);
    
    always @(*) begin
        ALUOp           = `ALU_NOP;     // Default: No Operation
        ALUIn1          = 1'b0;         // Default: rs1_data
        ALUIn2          = 1'b0;         // Default: rs2_data
        EXEOut          = 1'b0;         // Default: ALU Result
        
        mem_we          = 1'b0;         // Default: No memory write
        mem_re          = 1'b0;         // Default: No memory read
        mem_dim         = 2'b10;        // Default: Word access
        mem_sig         = 1'b1;         // Default: Signed
        
        wb_we           = 1'b0;         // Default: No Register File write
        wb_sel_input    = 1'b0;         // Default: Select ALU Result
        
        branch_taken    = 1'b0;         // Default: No branch/jump taken
        
        // OpCode Decoding
        case (opcode)
            
            // 1. R-Type (ADD, SUB, XOR, etc.)
            `RTYPE: begin
                ALUIn2          = 1'b0;     // Input 2 is rs2_data
                wb_we           = 1'b1;     // Write result to RegFile

                case (funct3)
                    `FN3_ADD_SUB:   ALUOp = funct7_5 ? `ALU_SUB : `ALU_ADD;
                    `FN3_SLL:        ALUOp = `ALU_SLL;
                    `FN3_SLT:        ALUOp = `ALU_SLT;
                    `FN3_SLTU:       ALUOp = `ALU_SLTU;
                    `FN3_XOR:        ALUOp = `ALU_XOR;
                    `FN3_SRL_SRA:    ALUOp = funct7_5 ? `ALU_SRA : `ALU_SRL;
                    `FN3_OR:         ALUOp = `ALU_OR;
                    `FN3_AND:        ALUOp = `ALU_AND;
                    default:         ALUOp = `ALU_NOP;
                endcase
            end
            
            // 2. I-Type Arithmetics (ADDI, SLLI, XORI, etc.)
            `ITYPE1: begin
                ALUIn2          = 1'b1;     // Input 2 is Immediate
                wb_we           = 1'b1;     // Write result to RegFile
                
                case (funct3)
                    `FN3_ADD_SUB:   ALUOp = `ALU_ADD;
                    `FN3_SLT:       ALUOp = `ALU_SLT;
                    `FN3_SLTU:      ALUOp = `ALU_SLTU;
                    `FN3_XOR:       ALUOp = `ALU_XOR;
                    `FN3_OR:        ALUOp = `ALU_OR;
                    `FN3_AND:       ALUOp = `ALU_AND;
                    `FN3_SLL:       ALUOp = `ALU_SLL;
                    `FN3_SRL_SRA:   ALUOp = funct7_5 ? `ALU_SRA : `ALU_SRL;
                    default:        ALUOp = `ALU_NOP;
                endcase
            end
            
            // 3. I-Type Load (LW, LB, LBU, etc.)
            `ITYPE2: begin 
                ALUOp           = `ALU_ADD;   // ALU: Calculate address (rs1 + imm)
                ALUIn2          = 1'b1;       // Input 2 is Immediate
                
                mem_re          = 1'b1;       // Read from memory
                wb_we           = 1'b1;       // Write result (data read)
                wb_sel_input    = 1'b1;       // MUX WB: Select Memory Data

                case (funct3)
                    `FN3_LB:    begin mem_dim = 2'b00; mem_sig = 1'b1; end // LB
                    `FN3_LH:    begin mem_dim = 2'b01; mem_sig = 1'b1; end // LH
                    `FN3_LW:    begin mem_dim = 2'b10; mem_sig = 1'b1; end // LW
                    `FN3_LBU:   begin mem_dim = 2'b00; mem_sig = 1'b0; end // LBU
                    `FN3_LHU:   begin mem_dim = 2'b01; mem_sig = 1'b0; end // LHU
                    default:    begin mem_dim = 2'b10; mem_sig = 1'b1; end
                endcase
            end

            // 4. S-Type Store (SW, SB, SH)
            `STYPE: begin 
                ALUOp           = `ALU_ADD;   // ALU: Calculate address (rs1 + imm)
                ALUIn2          = 1'b1;       // Input 2 is Immediate
                
                mem_we          = 1'b1;       // Write to memory
                wb_we           = 1'b0;       // Do not write to RegFile
                
                case (funct3)
                    `FN3_SB: mem_dim = 2'b00; // SB (Byte)
                    `FN3_SH: mem_dim = 2'b01; // SH (Half-Word)
                    `FN3_SW: mem_dim = 2'b10; // SW (Word)
                    default: mem_dim = 2'b10;
                endcase
            end

            // 5. U-Type (LUI, AUIPC)
            `UTYPE1: begin // LUI
                ALUOp           = `ALU_LUI;   // ALU: Special operation to pass immediate
                ALUIn2          = 1'b1;       // Immediate is input
                wb_we           = 1'b1;       // Write result to RegFile
            end
            
            `UTYPE2: begin // AUIPC
                ALUOp           = `ALU_ADD;   // ALU: PC + Imm (AUIPC)
                ALUIn1          = 1'b1;       // PC in ALU Input 1
                ALUIn2          = 1'b1;       // Immediate in ALU Input 2
                wb_we           = 1'b1;       // Write result to RegFile
            end
            
            // 6. J-Type (JAL)
            `JTYPE: begin 
                ALUOp           = `ALU_ADD;   // ALU: Calculate jump target (PC + Imm)
                ALUIn1          = 1'b1;       // PC in ALU Input 1
                ALUIn2          = 1'b1;       // Immediate in ALU Input 2
                
                wb_we           = 1'b1;       // Write PC + 4 (Return Address)
                EXEOut          = 1'b1;       // MUX EXE: Select PC + 4
                
                branch_taken    = 1'b1;       // Unconditional jump
            end
            
            // 7. I-Type JALR (Indirect Jump)
            `ITYPE3: begin 
                ALUOp           = `ALU_ADD;   // ALU: Calculate target (rs1 + imm)
                ALUIn1          = 1'b0;       // rs1_data in ALU Input 1
                ALUIn2          = 1'b1;       // Immediate in ALU Input 2
                
                wb_we           = 1'b1;       // Write PC + 4 (Return Address)
                EXEOut          = 1'b1;       // MUX EXE: Select PC + 4
                
                branch_taken    = 1'b1;       // Unconditional jump
            end
            
            // 8. B-Type (Conditional Branch)
            `BTYPE: begin 
                ALUOp  = `ALU_ADD;  
                ALUIn1 = 1'b1;                // PC in ALU Input 1
                ALUIn2 = 1'b1;                // Immediate in ALU Input 2
                wb_we           = 1'b0;       // Do not write to RegFile
                
                // Branch condition resolution:
                case (funct3)
                    `FN3_BEQ:  branch_taken = equal;
                    `FN3_BNE:  branch_taken = ~equal;
                    `FN3_BLT:  branch_taken = signed_less;
                    `FN3_BGE:  branch_taken = signed_greater || equal;
                    `FN3_BLTU: branch_taken = unsigned_less;
                    `FN3_BGEU: branch_taken = unsigned_greater || equal;
                    default:   branch_taken = 1'b0;
                endcase
            end

            default: begin
                // Default NOP logic applied
            end
        endcase
    end
    
endmodule