`timescale 1ns / 1ps

module tb_dma_ci;

    // Parameters
    localparam [7:0] CUSTOM_INSTRUCTION_ID = 8'd49;

    // Inputs
    reg start;
    reg clock;
    reg reset;
    reg [31:0] valueA;
    reg [31:0] valueB;
    reg [7:0] iseId;
    reg s_endTransaction;
    reg s_dataValid;
    reg s_address_data;

    // Outputs
    wire done;
    wire [31:0] result;
    wire s_dataReady;
    wire s_readReady;
    wire [3:0] s_byteEnable;
    wire [31:0] s_address_to_read;

    // Instantiate the Unit Under Test (UUT)
    dma_ci #(.customInstructionId(CUSTOM_INSTRUCTION_ID)) uut (
        .start(start),
        .clock(clock),
        .reset(reset),
        .valueA(valueA),
        .valueB(valueB),
        .iseId(iseId),
        .done(done),
        .result(result),
        .s_dataReady(s_dataReady),
        .s_readReady(s_readReady),
        .s_byteEnable(s_byteEnable),
        .s_address_to_read(s_address_to_read),
        .s_endTransaction(s_endTransaction),
        .s_dataValid(s_dataValid),
        .s_address_data(s_address_data)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100 MHz clock
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        start = 0;
        reset = 0;
        valueA = 32'h0;
        valueB = 32'h0;
        iseId = 8'h0;
        s_endTransaction = 0;
        s_dataValid = 0;
        s_address_data = 0;

        // Reset the design
        #10 reset = 1;
        #10 reset = 0;

        // Test case 1: Start a transaction with matching ISE ID
        #10 iseId = CUSTOM_INSTRUCTION_ID;
        valueA = 32'h12345678;
        valueB = 32'h00000001; // is_read = 1
        start = 1;
        #10 start = 0;
        valueA = 32'h0; // Reset valueA after starting
        valueB = 32'h0; // Reset valueB after starting

        // Simulate end of transaction
        #50 s_endTransaction = 1;
        #10 s_endTransaction = 0;

        // Test case 2: Start a transaction with non-matching ISE ID
        #50 iseId = 8'hFF; // Non-matching ID
        valueA = 32'h87654321;
        valueB = 32'h00000000; // is_read = 0
        start = 1;
        #10 start = 0;
        valueA = 32'h0; // Reset valueA after starting
        valueB = 32'h0; // Reset valueB after starting

        // Simulate end of transaction
        #50 s_endTransaction = 1;
        #10 s_endTransaction = 0;

        // End simulation
        #100 $finish;
    end
    initial begin
        $dumpfile("test_dma_ci.vcd");
        $dumpvars(0, tb_dma_ci);
    end

endmodule