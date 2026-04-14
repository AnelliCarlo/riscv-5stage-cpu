`timescale 1ns / 1ps

`include "RISC-V.vh"

module instruction_decode(
    input wire [`DATA_WIDTH-1:0] instruction,
    output wire [`REG_ADDR_WIDTH-1:0] rs1,
    output wire [`REG_ADDR_WIDTH-1:0] rs2,
    output wire [`REG_ADDR_WIDTH-1:0] rd,
    output wire [`OPCODE_WIDTH-1:0] opcode,
    output wire [`FUNCT3_WIDTH-1:0] funct3,
    output wire [`FUNCT7_WIDTH-1:0] funct7
    );

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];
    
endmodule