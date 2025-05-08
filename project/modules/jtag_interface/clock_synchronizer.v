module clock_synchronizer #(
    parameter WIDTH = 8  // Change this to your desired bit width
)(
    input  wire              clockIn,
    input  wire              clockOut,
    input  wire              reset,
    input  wire [WIDTH-1:0]  D,
    output wire [WIDTH-1:0]  Q
);
  // 3-stage synchronization per bit
  reg [2:0] s_states [WIDTH-1:0];
  wire [2:0] s_d     [WIDTH-1:0];
  wire       s_reset0 [WIDTH-1:0];

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : sync_logic
      assign s_d[i]     = {s_states[i][1:0], s_states[i][0] | D[i]};
      assign s_reset0[i] = reset | s_states[i][1];

      // First stage (clockIn domain)
      always @(posedge clockIn or posedge s_reset0[i]) begin
        if (s_reset0[i])
          s_states[i][0] <= 1'b0;
        else
          s_states[i][0] <= s_d[i][0];
      end

      // Second and third stages (clockOut domain)
      always @(posedge clockOut or posedge reset) begin
        if (reset)
          s_states[i][2:1] <= 2'b00;
        else
          s_states[i][2:1] <= s_d[i][2:1];
      end

      assign Q[i] = s_states[i][2];
    end
  endgenerate

endmodule

// ../../../modules/jtag_interface/clock_synchronizer.v:42: ERROR: Found posedge/negedge event on a signal that is not 1 bit wide!
//     always @(posedge clk_in or negedge n_reset or posedge sync_reg_3) begin
//         if (!n_reset | sync_reg_3) begin
//             sync_reg_1 <= 0;
//         end else begin
//             sync_reg_1 <= to_sync | sync_reg_1;
//         end
//     end

//     always @(posedge clk_out or negedge n_reset or posedge sync_reg_3) begin
//         if (!n_reset | sync_reg_3) begin
//             sync_reg_2 <= 0;
//         end else begin
//             sync_reg_2 <= sync_reg_1;
//         end
//     end

//     always @(posedge clk_out or negedge n_reset) begin
//         if (!n_reset) begin
//             sync_reg_3 <= 0;
//         end else begin
//             sync_reg_3 <= sync_reg_2;
//         end
//     end


