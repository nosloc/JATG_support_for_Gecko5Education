module pingpongbuffer (
            input wire clock,
            input wire reset, // Added reset signal
            input wire [6:0] pushAddress, // $clog2(64) = 6
            input wire [6:0] popAddress,
            input wire [31:0] pushData,   // bitwidth = 32
            input wire push,
            input wire switch,
            output wire [31:0] popData
        );

    // Internal signals
    localparam offset = 32; // nrOfEntries / 2 = 64 / 2
    wire [6:0] s_addressA, s_addressB;
    reg switch_reg;

    semiDualPortSSRAM ssram (
        .clockA(clock),
        .clockB(clock),
        .writeEnable(push),
        .addressA(s_addressA),
        .addressB(s_addressB),
        .dataInA(pushData),
        .dataOutB(popData) // Correctly connected to popData
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            switch_reg <= 1'b0; // Initialize to 0 during reset
        end else if (switch) begin
            switch_reg <= ~switch_reg; // Toggle on switch
        end
    end

    assign s_addressA = (switch_reg == 1'b0) ? pushAddress : pushAddress + offset;
    assign s_addressB = (switch_reg == 1'b1) ? popAddress : popAddress + offset;

endmodule



