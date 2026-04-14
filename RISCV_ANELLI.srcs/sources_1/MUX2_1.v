`timescale 1ns / 1ps

`include "RISC-V.vh"

module MUX2_1(
    input wire [`DATA_WIDTH-1:0] in0,
    input wire [`DATA_WIDTH-1:0] in1,
    input wire sel,
    
    output wire [`DATA_WIDTH-1:0] out
);

    assign out = sel ? in1 : in0;

endmodule
