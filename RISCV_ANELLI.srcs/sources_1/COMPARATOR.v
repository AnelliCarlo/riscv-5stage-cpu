`timescale 1ns / 1ps

`include "RISC-V.vh"

module COMPARATOR(
    input wire [`DATA_WIDTH-1:0] input1,
    input wire [`DATA_WIDTH-1:0] input2,

    output wire equal,
    output wire signed_less,        // input1 < input2 (Signed)
    output wire signed_greater,     // input1 > input2 (Signed)
    output wire unsigned_less,      // input1 < input2 (Unsigned)
    output wire unsigned_greater    // input1 > input2 (Unsigned)
);
    
    assign equal = (input1 == input2);
    
    assign signed_less    = ($signed(input1) < $signed(input2));
    assign signed_greater = ($signed(input1) > $signed(input2));
    
    assign unsigned_less    = (input1 < input2);
    assign unsigned_greater = (input1 > input2);
    
endmodule