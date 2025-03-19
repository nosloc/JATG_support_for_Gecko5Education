`timescale 1ps / 1ps

module tb_top;
    reg TCK, TMS, TDI;
    wire TDO;
    wire [8:0] LEDS;
    wire [3:0] LEDS_colums;

    initial begin
        TCK = 1'b0;
        forever #2 TCK = ~TCK;
    end

    wire s_JTDI, s_JTCK, s_JRTI2, s_JRTI1, s_JSHIFT, s_JUPDATE, s_JRSTN, s_JCE2, s_JCE1;

    top top(
        .TCK(TCK),
        .TMS(TMS),
        .TDI(TDI),
        .TDO(TDO),
        .LEDS(LEDS),
        .LEDS_colums(LEDS_colums)
    );

     task write_IR (input [7:0] ir);
        integer i;
        begin
            TMS = 1'b1;
            #4;
            // DR-SCAN
            TMS = 1'b1;
            #4;
            // IR-SCAN
            TMS = 1'b0;
            #4;
            // CAPTURE-IR
            TMS = 1'b0;
            // SHIFT-IR
            for (i = 0; i < 8; i = i + 1) begin
                TDI = ir[i];
                if (i != 7) begin
                    #4;
                end
            end

            TMS = 1'b1;
            TDI = 1'b0;
            #4;
            //EXIT1-IR
            TMS = 1'b1;
            #4;
            //UPDATE-IR
            TMS=1'b0;
            #4;
            //RUN-TEST/IDLE
        end
    endtask

    task write_DR (input [8:0] dr);
        integer i;
        begin
            TMS = 1'b1;
            #4;
            // DR-SCAN
            TMS = 1'b0;
            #4;
            // CAPTURE-DR
            TMS = 1'b0;
            // SHIFT-DR
            for (i = 0; i < 9; i = i + 1) begin
                TDI = dr[i];
                #4;
            end

            TMS = 1'b1;
            TDI = 1'b0;
            #4;
            //EXIT1-DR
            TMS = 1'b1;
            #4;
            //UPDATE-DR
            TMS=1'b0;
            #4;
            //RUN-TEST/IDLE
        end
    endtask

    initial begin
        $dumpfile("test_top.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        TDI = 1'b0;
        TMS = 1'b1;
        #20;
        // TEST-LOGIC-RESET
        TMS = 1'b0;
        #4; 
        // RUN-TEST/IDLE
        #4;
        write_IR(8'h32);
        write_DR(9'b011001101);
        #10
        $display("LEDS = %b", LEDS);
        $display("LEDS_colums = %b", LEDS_colums);
        write_IR(8'h38);
        write_DR(9'b001100000);
        #10
        $display("LEDS = %b", LEDS);
        $display("LEDS_colums = %b", LEDS_colums);
        $finish;
    end


endmodule
