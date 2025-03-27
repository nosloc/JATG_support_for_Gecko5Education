module chain1(
    input wire JTCK,
    input wire JTDI,
    input wire JRTI1,
    input wire JSHIFT,
    input wire JUPDATE,
    input wire JRSTN,
    input wire JCE1,
    output wire JTD1,
    output reg [29:0] LEDS
);


reg [29:0] shift_reg_1;
reg [29:0] data_reg_1;
assign JTD1 = shift_reg_1[0];

always @(posedge JTCK or negedge JRSTN) begin
    if (JRSTN == 0) begin
        shift_reg_1 <= 30'b0;
        data_reg_1 <= 30'b0;
    end
    else  begin
        if (JCE1) begin
        // Shifting data in
            if (JSHIFT) begin
                shift_reg_1 <= {JTDI, shift_reg_1[29:1]};
            end
            // Capture mode
            else begin
                shift_reg_1 <= data_reg_1;
            end 
        end
        // Update data register
        if (JUPDATE) begin
            data_reg_1 <= shift_reg_1;

        end
    end
end

always @(data_reg_1) begin
    LEDS = data_reg_1;
end

endmodule
