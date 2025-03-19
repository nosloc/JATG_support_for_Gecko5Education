
module chain2(
    input wire JTCK,
    input wire JTDI,
    input wire JRTI2,
    input wire JSHIFT,
    input wire JUPDATE,
    input wire JRSTN,
    input wire JCE2,
    output reg JTD2,
    output reg [3:0] LEDS_colums
);

reg [3:0] shift_reg;
reg [3:0] data_reg;
always @(negedge JRSTN) begin

    shift_reg <= 4'b0;
    data_reg <= 4'b0;
end
always @(posedge JTCK) begin
    if (JCE2) begin
        // Shifting data in
        if (JSHIFT) begin
            JTD2 <= shift_reg[0];
            shift_reg <= {JTDI, shift_reg[3:1]};
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

always @(data_reg) begin
    LEDS_colums = data_reg;
end

endmodule
