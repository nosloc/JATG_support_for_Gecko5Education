module chain1(
    input wire JTCK,
    input wire JTDI,
    input wire JRTI1,
    input wire JSHIFT,
    input wire JUPDATE,
    input wire JRSTN,
    input wire JCE1,
    output reg JTD1,
    output reg [8:0] LEDS
);

// always @(posedge JTCK) begin
//     if (JRTI1) begin
//         LEDS <= LEDS + 1;
//     end
// end

reg [8:0] shift_reg;
reg [8:0] data_reg;
always @(posedge JTCK or negedge JRSTN) begin
    if (JRSTN == 0) begin
        shift_reg <= 9'b0;
        data_reg <= 9'b0;
        JTD1 <= 1'b0;
    end
    else  begin
            if (JCE1) begin
            // Shifting data in
            if (JSHIFT) begin
                shift_reg <= {JTDI, shift_reg[8:1]};
                JTD1 <= shift_reg[0];
            end
            // Capture mode
            else begin
                shift_reg <= data_reg;
            end 
        end
        // Update data register
        if (JUPDATE) begin
            data_reg <= shift_reg;
        end
    end
end

always @(data_reg) begin
     LEDS <= data_reg;
end

endmodule
