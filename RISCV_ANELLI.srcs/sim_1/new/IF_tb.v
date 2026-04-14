`timescale 1ns / 1ps
`include "RISC-V.vh"

module IF_tb();

    // ========================================================================
    // Inputs (Registers)
    // ========================================================================
    reg clk;
    reg rst;
    reg  [`DATA_WIDTH-1:0] pc_start;
    reg                    ID_branch_taken;
    reg  [`DATA_WIDTH-1:0] EXE_pc_jump;
    reg                    stall;
    reg  [1:0]             pc_sel;

    // ========================================================================
    // Outputs (Wires)
    // ========================================================================
    wire [`DATA_WIDTH-1:0] pc_out;
    wire [`DATA_WIDTH-1:0] instruction;
    wire                   pc_jump_taken;

    // ========================================================================
    // Unit Under Test (UUT) Instantiation
    // ========================================================================
    IF uut (
        .clk(clk),
        .rst(rst),
        .pc_start(pc_start),
        .ID_branch_taken(ID_branch_taken),
        .EXE_pc_jump(EXE_pc_jump),
        .stall(stall),
        .pc_sel(pc_sel),
        .pc_out(pc_out),
        .instruction(instruction),
        .pc_jump_taken(pc_jump_taken)
    );

    // ========================================================================
    // Clock Generation
    // ========================================================================
    // Generates a 10ns period clock (100 MHz)
    always #5 clk = ~clk;

    // ========================================================================
    // Simulation Sequence
    // ========================================================================
    initial begin
        // 1. Initialize Inputs
        clk             = 0;
        rst             = 1;
        pc_start        = 32'h00000000;
        ID_branch_taken = 0;
        EXE_pc_jump     = 32'h00000000;
        stall           = 0;
        pc_sel          = 2'b00; // Default: next_pc = speculation_pc

        // Wait 20ns to ensure reset propagates
        #20;
        
        // Release reset
        rst = 0;

        // -----------------------------------------------------------
        // TEST CASE 1: Normal Execution (Sequential Fetch)
        // -----------------------------------------------------------
        // Let the CPU fetch sequential instructions for 4 clock cycles
        #40;

        // -----------------------------------------------------------
        // TEST CASE 2: Pipeline Stall
        // -----------------------------------------------------------
        // Assert stall signal. The pc_out should hold its current value.
        stall = 1;
        #20; // Hold stall for 2 clock cycles
        
        // Release stall. PC should resume advancing.
        stall = 0;
        #20;

        // -----------------------------------------------------------
        // TEST CASE 3: Branch Misprediction Correction (from ID)
        // -----------------------------------------------------------
        // Assuming pc_sel = 2'b01 selects in1 (id_pc) in MUX4_1
        pc_sel = 2'b01; 
        #10; // Hold for 1 clock cycle
        pc_sel = 2'b00; // Return to normal speculation fetch
        #20;

        // -----------------------------------------------------------
        // TEST CASE 4: Absolute Jump (from EXE)
        // -----------------------------------------------------------
        // Assuming pc_sel = 2'b10 selects in2 (EXE_pc_jump) in MUX4_1
        EXE_pc_jump = 32'h00000100; // Set an arbitrary jump address
        pc_sel      = 2'b10;
        #10; // Hold for 1 clock cycle
        pc_sel      = 2'b00; // Return to normal speculation fetch
        
        // Let it run for a few more cycles at the new jumped address
        #40;

        // End the simulation
        $finish;
    end

endmodule