`ifndef RISCV_VH
`define RISCV_VH

// --------------------------------------------------------
// CORE WIDTHS (RV32I Standard)
// --------------------------------------------------------
`define DATA_WIDTH         32         // Data bus width (32 bit)
`define REG_ADDR_WIDTH     5          // Register address width (5 bits for 32 registers)
`define ALU_CNTR_WIDTH     4          // ALU Control bus width (4 bits)

`define OPCODE_WIDTH       7          // OpCode field width
`define FUNCT3_WIDTH       3          // Funct3 field width
`define FUNCT7_WIDTH       7          // Funct7 field width

`define ZEROREG            5'b00000   // Register x0 address (read-only zero)

// --------------------------------------------------------
// RISC-V OPCODES (Instruction[6:0])
// --------------------------------------------------------
`define RTYPE              7'b0110011 // R-Type (REG - REG)

`define ITYPE1             7'b0010011 // I-Type (ARITHMETIC REG - IMM)
`define ITYPE2             7'b0000011 // I-Type (LOAD)
`define ITYPE3             7'b1100111 // I-Type (JALR)

`define STYPE              7'b0100011 // S-Type (STORE)

`define BTYPE              7'b1100011 // B-Type (BRANCH)

`define JTYPE              7'b1101111 // J-Type (JAL)

`define UTYPE1             7'b0110111 // U-Type (LUI)
`define UTYPE2             7'b0010111 // U-Type (AUIPC)

// --------------------------------------------------------
// FUNCT3 FIELDS (Instruction[14:12]) - Explicit 3-bit names
// --------------------------------------------------------

// --- Aritmetic/Logic Funct3 (R-Type and I-Type1) ---
`define FN3_ADD_SUB    3'b000 // ADD, SUB, ADDI
`define FN3_SLL        3'b001 // SLL, SLLI
`define FN3_SLT        3'b010 // SLT, SLTI
`define FN3_SLTU       3'b011 // SLTU, SLTIU
`define FN3_XOR        3'b100 // XOR, XORI
`define FN3_SRL_SRA    3'b101 // SRL, SRA, SRLI, SRAI
`define FN3_OR         3'b110 // OR, ORI
`define FN3_AND        3'b111 // AND, ANDI

// Load/Store Funct3 (Values are shared, names are explicit for readability)
`define FN3_LB             3'b000 // Load Byte
`define FN3_SB             3'b000 // Store Byte
`define FN3_LH             3'b001 // Load Half-word
`define FN3_SH             3'b001 // Store Half-word
`define FN3_LW             3'b010 // Load Word
`define FN3_SW             3'b010 // Store Word
`define FN3_LBU            3'b100 // Load Byte Unsigned
`define FN3_LHU            3'b101 // Load Half-word Unsigned

// Branch Funct3
`define FN3_BEQ            3'b000
`define FN3_BNE            3'b001
`define FN3_BLT            3'b100
`define FN3_BGE            3'b101
`define FN3_BLTU           3'b110
`define FN3_BGEU           3'b111

// --------------------------------------------------------
// ALU OPERATION CODES (4 bit) - Final operations for ALU.v
// --------------------------------------------------------
`define ALU_ADD     4'b0001 // Addition (ADD, ADDI, Load/Store Address, AUIPC, JAL/JALR)
`define ALU_SUB     4'b0010 // Subtraction (SUB, Branch Comparison)
`define ALU_SLL     4'b0011 // Shift Left Logical (SLL, SLLI)
`define ALU_SRL     4'b0100 // Shift Right Logical (SRL, SRLI)
`define ALU_SRA     4'b0101 // Shift Right Arithmetic (SRA, SRAI)
`define ALU_AND     4'b0110 // AND (AND, ANDI)
`define ALU_OR      4'b0111 // OR (OR, ORI)
`define ALU_XOR     4'b1000 // XOR (XOR, XORI)
`define ALU_SLT     4'b1001 // Set Less Than (SLT, SLTI)
`define ALU_SLTU    4'b1010 // Set Less Than Unsigned (SLTU, SLTIU)
`define ALU_LUI     4'b1100 // Special: Pass ALUIn2 as result (for LUI)
`define ALU_NOP     4'b0000 // No Operation (Default)

`endif