module test_module(
    output wire [3:0] RGB_Column,
    output reg [2:0] row1,
    output reg [2:0] row2,
    output reg [2:0] row3);

    wire jtdi, jtck, jshift, jupdate, jce1, jce2, jrstn, jrti1, jrti2;
	JTAGG jtag(
		.JTDI(jtdi),
		.JTCK(jtck),
		.JRTI2(jrti1), 
		.JTDO2(s_JTDO2),
        .JTDO1(s_JTDO1),
		.JRTI1(jrti2),
		.JSHIFT(jshift), 
		.JUPDATE(jupdate), 
		.JRSTN(jrstn),
		.JCE2(jce2),  
		.JCE1(jce1)
	);


	always @(posedge jtck or negedge jrstn) begin
		if (!jrstn) begin
			row1 <= 3'b111;
			row2 <= 3'b111;
			row3 <= 3'b111;
		end
		else begin
			if (jshift)
				row1 <= 3'b000;
			if (jce1)
				row2 <= 3'b000;
			if (jce2)
				row3 <= 3'b000;
		end
	end
    assign RGB_Column = {0, 0, jrti1, jrti2};
	// Read from the 0x38 instrction should return 0xff
	assign s_JTDO1 = 1;
	// Read from the 0x38 instrction should return 0x00
	assign s_JTDO2 = 0;

endmodule