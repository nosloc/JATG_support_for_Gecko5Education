module test_module(
    output wire [3:0] RGB_Column,
    output wire [2:0] row1,
    output wire [2:0] row2,
    output wire [2:0] row3);

    wire jtdi, jtck, jshift, jupdate, jce1, jce2, jrstn, jrti1, jrti2;
	JTAGG jtag(
		.JTDI(jtdi),
		.JTCK(jtck),
		.JRTI2(jrti1), 
		.JRTI1(jrti2),
		.JSHIFT(jshift), 
		.JUPDATE(jupdate), 
		.JRSTN(jrstn),
		.JCE2(jce2),  
		.JCE1(jce1)
	);


    assign led_row1 = {jtck, jtck, jtck};
    assign led_row2 = {jtdi, jtdi, jtdi};
    assign led_row3 = {jshift, jshift, jshift};
    assign RGB_Column = 4'b0001;

endmodule