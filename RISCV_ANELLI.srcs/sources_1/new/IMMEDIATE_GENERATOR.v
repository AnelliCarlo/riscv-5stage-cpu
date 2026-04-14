`timescale 1ns / 1ps

`include "RISC-V.vh"

module IMMEDIATE_GENERATOR(
    input wire [`DATA_WIDTH-1:0] inst,
    
    output reg [`DATA_WIDTH-1:0] immediate
    );
    
    wire [`OPCODE_WIDTH-1:0] opcode;
    
    assign opcode = inst[6:0];
    
    always @(*) begin
        case(opcode)
            `ITYPE1, `ITYPE2: begin
                immediate = {{20{inst[31]}},inst[31:20]};
            end
            `STYPE: begin
                 immediate = {{20{inst[31]}},inst[31:25], inst[11:7]};
            end
            `BTYPE: begin
                immediate = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};                
            end
            `JTYPE: begin
                immediate = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
            end
            `UTYPE1, `UTYPE2: begin
                immediate = {inst[31:12],{12{1'b0}}};
            end
            `ITYPE3: begin // JALR
                immediate = {{12{inst[31]}},inst[31:12]};
            end  
            
            default: begin
                // Default to zero for undefined instructions
                immediate = {`DATA_WIDTH{1'b0}};
            end
        endcase
    end
endmodule