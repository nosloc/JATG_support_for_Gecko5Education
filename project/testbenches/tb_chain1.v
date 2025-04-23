`timescale 1ps/1ps;

module tb_chain1;
    
    reg JTCK;
    reg JTDI;
    reg JRTI1;
    reg JSHIFT;
    reg JUPDATE;
    reg JRSTN;
    reg JCE1;
    wire JTD1;

    // Instantiate the DUT (Device Under Test)
    chain1 dut (
        .JTCK(JTCK),
        .JTDI(JTDI),
        .JRTI1(JRTI1),
        .JSHIFT(JSHIFT),
        .JUPDATE(JUPDATE),
        .JRSTN(JRSTN),
        .JCE1(JCE1),
        .JTD1(JTD1),
        .pp_dataOut(32'hFFFFFFFF)
    );

    // Clock generation
    initial begin
        JTCK = 0; // Initialize JTCK
    end

    always #2 JTCK = ~JTCK;

    integer i;
    task sendInstruction(input [35:0] instruction);
        begin
            JRTI1 = 0;
            #8;
            JCE1 = 1;
            #4;
            for (i = 0; i < 36; i = i + 1) begin
                JTDI = instruction[i];
                JSHIFT = 1;
                #4;
            end
            JCE1 = 0;
            JSHIFT = 0;
            #8;
            JUPDATE = 1;
            #4;
            JUPDATE = 0;
            JRTI1 = 1;
            #4;
        end
    endtask

    initial begin
        // Initialize signals
        JTCK = 0;
        JTDI = 0;
        JRTI1 = 0;
        JSHIFT = 0;
        JUPDATE = 0;
        JRSTN = 1;
        JCE1 = 0;

        // Reset the DUT
        #8;
        JRSTN = 0;
        #8;
        JRSTN = 1;
        #8;
        JRTI1 = 1;
        #8;

        // Send an instruction to the DUT
        sendInstruction(36'b010101010101010101010101010101010001);
        $display("Value of address reg: %b", dut.address_reg);

        sendInstruction(36'b11110010);
        $display("Value of byte enable reg: %b", dut.byte_enable_reg);

        // sendInstruction(36'b10101010011);
        sendInstruction(36'b00011);
        $display("Value of busrt size reg: %b", dut.busrt_size_reg);

        $display("Value of status reg: %b", dut.status_reg);
        #4;
        sendInstruction(36'hF8);

        #80;

        // Send a read instruction
        sendInstruction(36'b1001);
        #20

        // Read the data from the buffer
        sendInstruction(36'b1010);
        #160;
        $finish;
    end

    initial begin
        $dumpfile("test_chain1.vcd");
        $dumpvars(0, tb_chain1);
    end

endmodule

    