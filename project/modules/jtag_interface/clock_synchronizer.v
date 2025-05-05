module clock_synchronizer #(
    parameter integer SYNC_WIDTH = 1)
    (
        input wire clk_in,
        input wire clk_out,
        input wire[SYNC_WIDTH-1:0] to_sync,
        input wire n_reset,
        output wire[SYNC_WIDTH-1:0] sync_out
    );

    reg[SYNC_WIDTH-1:0] sync_reg_1, sync_reg_2, sync_reg_3;
    assign sync_out = sync_reg_3;

    always @(posedge clk_in or negedge n_reset) begin
        if (!n_reset) begin
            sync_reg_1 <= 0;
        end else begin
            if (sync_reg_3) begin
                sync_reg_1 <= 0;
            end else begin
                sync_reg_1 <= to_sync | sync_reg_2;
            end
        end
    end

    always @(posedge clk_out or negedge n_reset) begin
        if (!n_reset) begin
            sync_reg_2 <= 0;
            sync_reg_3 <= 0;
        end else begin
            if (sync_reg_3) begin
                sync_reg_2 <= 0;
                sync_reg_3 <= 0;
            end else begin
                sync_reg_2 <= sync_reg_1;
                sync_reg_3 <= sync_reg_2;
            end
        end
    end
endmodule
