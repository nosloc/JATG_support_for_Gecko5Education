`timescale 1ps/1ps

module tb_pingpongbuffer;

    // Parameters
    parameter bitwidth = 32;
    parameter nrOfEntries = 128;

    // Testbench signals
    reg clock;
    reg [$clog2(nrOfEntries)-1:0] pushAddress;
    reg [$clog2(nrOfEntries)-1:0] popAddress;
    reg [bitwidth-1:0] pushData;
    reg push;
    reg switch;
    reg reset;
    wire [bitwidth-1:0] popData;

    // Clock generation (4ps period)
    initial clock = 0;
    always #2 clock = ~clock;

    // DUT instantiation
    pingpongbuffer uut (
        .clock(clock),
        .reset(reset),
        .pushAddress(pushAddress),
        .popAddress(popAddress),
        .pushData(pushData),
        .push(push),
        .switch(switch),
        .popData(popData)
    );

    // Testbench logic
    initial begin
        // Initialize signals
        pushAddress = 0;
        popAddress = 0;
        pushData = 0;
        push = 0;
        switch = 0;
        reset = 1;

        // Wait for a few clock cycles
        #11;
        reset = 0; // Release reset

        //Write to the first half of the buffer
        pushData = 32'hFFFFFFF0;
        pushAddress = 0;
        push = 1;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF1;
        pushAddress = 1;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF2;
        pushAddress = 2;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF3;
        pushAddress = 3;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF4;
        pushAddress = 4;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF5;
        pushAddress = 5;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF6;
        pushAddress = 6;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF7;
        pushAddress = 7;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF8;
        pushAddress = 8;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFF9;
        pushAddress = 9;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFA;
        pushAddress = 10;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFB;
        pushAddress = 11;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFC;
        pushAddress = 12;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFD;
        pushAddress = 13;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFE;
        pushAddress = 14;
        #4; // Wait for one clock cycle
        pushData = 32'hFFFFFFFF;
        pushAddress = 15;
        #4; // Wait for one clock cycle
        push = 0; // Stop pushing data
        pushAddress = 0; // Reset push address
        pushData = 0; // Reset push data


        switch = 1; // Ensure switch is off
        #4; // Wait for one clock cycle
        switch = 0; // Switch back to the original half

        // Read the first half of the buffer
        popAddress = 0;
        #4; // Wait for one clock cycle
        popAddress = 1;
        #4; // Wait for one clock cycle
        popAddress = 2;
        #4; // Wait for one clock cycle
        popAddress = 3;
        #4; // Wait for one clock cycle
        popAddress = 4;










  
        #20;
        $finish;
    end

    // Monitor signals
    initial begin
        $dumpfile("test_pingpong.vcd");
        $dumpvars(0, tb_pingpongbuffer);
    end


endmodule