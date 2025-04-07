`timescale 1ps/1ps

module tb_DMA;

    // Testbench signals
    reg clock, reset, dataReady;
    reg [31:0] address_dataIN;
    reg end_transactionIN, data_validIN, busyIN, errorIN;
    reg granted;
    wire [31:0] address_dataOUT, pushAddress, popAddress, pushData;
    wire [3:0] byte_enableOUT;
    wire [7:0] busrt_sizeOUT;
    wire read_n_writeOUT, begin_transactionOUT, end_transactionOUT, data_validOUT, busyOUT, push, switch, request;
    reg [31:0] popData;
    reg readReady;
    reg [31:0] address_to_read;

    // Instantiate the DUT (Device Under Test)
    DMA dut (
        .clock(clock),
        .reset(reset),
        .dataReady(dataReady),
        .readReady(readReady),
        .address_to_read(address_to_read),
        .pushAddress(pushAddress),
        .popAddress(popAddress),
        .pushData(pushData),
        .push(push),
        .switch(switch),
        .popData(popData), // Not used in this testbench
        .address_dataIN(address_dataIN),
        .end_transactionIN(end_transactionIN),
        .data_validIN(data_validIN),
        .busyIN(busyIN),
        .errorIN(errorIN),
        .address_dataOUT(address_dataOUT),
        .byte_enableOUT(byte_enableOUT),
        .busrt_sizeOUT(busrt_sizeOUT),
        .read_n_writeOUT(read_n_writeOUT),
        .begin_transactionOUT(begin_transactionOUT),
        .end_transactionOUT(end_transactionOUT),
        .data_validOUT(data_validOUT),
        .busyOUT(busyOUT),
        .request(request),
        .granted(granted)
    );

    // Clock generation
    always #2 clock = ~clock;

    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        dataReady = 0;
        address_dataIN = 32'h0;
        end_transactionIN = 0;
        data_validIN = 0;
        busyIN = 0;
        errorIN = 0;
        granted = 0;
        popData = 32'h0;
        readReady = 0;
        address_to_read = 32'h0;

        // Reset sequence
        #4 reset = 0;

        // Test case: Write operation
        #4 dataReady = 1; // Indicate data is ready
        #4 popData = 32'hA5A5A5A5; 
        #4 dataReady = 0; 
        #4;
        #4 granted = 1;
        #4 granted = 0;
        busyIN = 1;
        popData = 32'h0;
        #20 busyIN = 0;

        //Try to read from address 0x0A0A0A0A
        #12

        #4 address_to_read = 32'h0A0A0A0A;
        readReady = 1;
        #4 address_to_read = 32'h0;
        readReady = 0;
        #4 granted = 1;
        #2; //Handshake
        #4 address_dataIN = 32'h12345678;
        granted = 0;
        data_validIN = 1;
        end_transactionIN = 1;
        #4 data_validIN = 0;
        end_transactionIN = 0;

        
        #20$finish;
    end

    // Monitor signals
    initial begin
        $dumpfile("test_dma.vcd");
        $dumpvars(0, tb_DMA);
    end

endmodule
