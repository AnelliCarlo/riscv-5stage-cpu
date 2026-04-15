`timescale 1ns / 1ps

`include "RISC-V.vh"

module DATA_MEMORY #(
    parameter RAM_SIZE = 1024
)(
    input wire clk,

    input wire [`DATA_WIDTH-1:0] address,
    input wire [`DATA_WIDTH-1:0] write_data,

    input wire mem_we,
    input wire mem_re,
    input wire [1:0] mem_dim,
    input wire mem_sig,

    output reg [`DATA_WIDTH-1:0] mem_data
);

    // Memory array: RAM_SIZE locations of 8 bits (1 Byte) each
    reg [7:0] ram [0:RAM_SIZE-1];

    // Helper wire to limit the address to the physical size of the RAM
    wire [31:0] eff_addr;
    assign eff_addr = address % RAM_SIZE;

    // -----------------------------------------------------------------
    // WRITE LOGIC (Synchronous)
    // -----------------------------------------------------------------
    always @(posedge clk) begin
        if (mem_we) begin
            // 2'b00 = Byte (8 bits), 2'b01 = Half-Word (16 bits), 2'b10 = Word (32 bits)
            if (mem_dim == 2'b00) begin
                ram[eff_addr] <= write_data[7:0];
            end
            else if (mem_dim == 2'b01) begin
                ram[eff_addr]     <= write_data[7:0];
                ram[eff_addr + 1] <= write_data[15:8];
            end
            else if (mem_dim == 2'b10) begin
                ram[eff_addr]     <= write_data[7:0];
                ram[eff_addr + 1] <= write_data[15:8];
                ram[eff_addr + 2] <= write_data[23:16];
                ram[eff_addr + 3] <= write_data[31:24];
            end
        end
    end

    // -----------------------------------------------------------------
    // READ LOGIC (Asynchronous / Combinational)
    // -----------------------------------------------------------------
    always @(*) begin
        mem_data = 32'b0; // Default value to avoid latches

        if (mem_re) begin
            case (mem_dim)
                2'b00: begin // Byte
                    if (mem_sig) // Sign-extended (LB)
                        mem_data = {{24{ram[eff_addr][7]}}, ram[eff_addr]};
                    else         // Zero-extended (LBU)
                        mem_data = {24'b0, ram[eff_addr]};
                end
                
                2'b01: begin // Half-Word
                    if (mem_sig) // Sign-extended (LH)
                        mem_data = {{16{ram[eff_addr + 1][7]}}, ram[eff_addr + 1], ram[eff_addr]};
                    else         // Zero-extended (LHU)
                        mem_data = {16'b0, ram[eff_addr + 1], ram[eff_addr]};
                end
                
                2'b10: begin // Word (LW)
                    mem_data = {ram[eff_addr + 3], ram[eff_addr + 2], ram[eff_addr + 1], ram[eff_addr]};
                end
                
                default: mem_data = 32'b0;
            endcase
        end
    end

endmodule