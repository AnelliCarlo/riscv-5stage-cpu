`timescale 1ns / 1ps

`include "RISC-V.vh"

module INSTRUCTION_MEMORY #(
    parameter MEM_SIZE = 1024,
    parameter FILE_NAME = "program.mem"
)(
    input wire [`DATA_WIDTH-1:0] address,
    output wire [`DATA_WIDTH-1:0] instruction
);

    reg [31:0] rom [0:MEM_SIZE-1];

    initial begin
        $readmemb(FILE_NAME, rom);
    end

    wire [29:0] word_index;
    assign word_index = address[31:2];

    assign instruction = rom[word_index];

endmodule