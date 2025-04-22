module chain1(
    // JTAG signals
    input wire JTCK,
    input wire JTDI,
    input wire JRTI1,
    input wire JSHIFT,
    input wire JUPDATE,
    input wire JRSTN,
    input wire JCE1,
    output wire JTD1,

    // Connection to the ping-pong buffer
    output wire [8:0] pp_address,
    output wire pp_writeEnable,
    output wire [31:0] pp_dataIn,
    input wire [31:0] pp_dataOut,
    output wire pp_switch,

    // Connection with the DMA
    output wire [31:0] dma_address,
    output wire dma_data_ready,
    output wire [3:0] dma_byte_enable
);


reg [35:0] shift_reg;
reg [31:0] data_reg;
reg [3:0] status_reg;
reg [31:0] address_reg;
reg [3:0] byte_enable_reg;
reg [7:0] busrt_size_reg;
reg [7:0] remaining_size_reg;
reg [7:0] pp_address_reg;
wire is_operation_running;
wire s_ready_to_switch;
reg r_data_shifted_in;

assign s_ready_to_switch = 1;

localparam IDLE = 0;
localparam write_FILL_BUFFER = 1;
localparam write_WAIT_FOR_SWITCH = 2;
localparam write_SWITCH_BUFFER = 3;
localparam write_LAUNCH_WRITE = 4;


reg [2:0] chain1_cur_state;
reg [2:0] chain1_nxt_state;

assign is_operation_running = (status_reg[3] == 1'b1) ? 1'b1 : 1'b0;


assign JTD1 = shift_reg[0];
always @(posedge JTCK or negedge JRSTN) begin
    if (JRSTN == 0) begin
        shift_reg <= 34'b0;
        status_reg <= 4'b0;
        address_reg <= 32'b0;
        byte_enable_reg <= 4'b0;
        busrt_size_reg <= 8'b0;
        remaining_size_reg <= 8'b0;
        pp_address_reg <= 8'b0;
    end
    else  begin
        if (r_data_shifted_in) begin
            r_data_shifted_in <= 1'b0;
        end
        if (JCE1) begin
        // Shifting data in
            if (JSHIFT) begin
                shift_reg <= {JTDI, shift_reg[35:1]};
            end
            // capture the status register
            else begin
                shift_reg <= {31'b0, status_reg};
            end 
        end
        // Update datas registers based on the instruction used
        if (JUPDATE) begin
            case (shift_reg[3:0])
                4'b0001: begin
                    // Writting to address register
                    if (~is_operation_running) begin
                        address_reg <= shift_reg[35:4];
                        status_reg <= status_reg | 4'b0001;
                    end
                end
                4'b0010: begin
                    // writting to byte enable register
                    if (~is_operation_running) begin
                        byte_enable_reg <= shift_reg[7:4];
                        status_reg <= status_reg | 4'b0010;
                    end
                end
                4'b0011: begin
                    // writting the size reg
                    if (~is_operation_running) begin
                        busrt_size_reg <= shift_reg[11:4];
                        remaining_size_reg <= shift_reg[11:4];
                        status_reg <= status_reg | 4'b0100;
                    end
                end
                4'b1000: begin
                    // Send data
                    data_reg <= shift_reg[35:4];
                    status_reg <= status_reg | 4'b1000;
                    r_data_shifted_in <= 1'b1;
                end
                default: begin
                end
            endcase 
        end
    end
end

always @(posedge JTCK or negedge JRSTN) 
    begin
        if (JRSTN == 0) begin
            chain1_cur_state <= IDLE;
        end
        else begin 
            chain1_cur_state <= chain1_nxt_state;
        end
    end 

always @(*) begin
    case (chain1_cur_state)
        IDLE: begin
            if (r_data_shifted_in) begin
                chain1_nxt_state <= write_FILL_BUFFER;
            end
            else begin
                chain1_nxt_state <= IDLE;
            end
        end
        write_FILL_BUFFER: begin
            if (remaining_size_reg == 0) begin
                chain1_nxt_state <= write_WAIT_FOR_SWITCH;
            end
            else begin
                remaining_size_reg = remaining_size_reg - 1;
                chain1_nxt_state <= IDLE;
            end
        end

        write_WAIT_FOR_SWITCH: begin
            if (s_ready_to_switch) begin
                chain1_nxt_state <= write_SWITCH_BUFFER;
            end
            else begin
                chain1_nxt_state <= write_WAIT_FOR_SWITCH;
            end
        end

        write_SWITCH_BUFFER: begin
            chain1_nxt_state <= write_LAUNCH_WRITE;
        end

        write_LAUNCH_WRITE: begin
            if (remaining_size_reg ==0) begin
                status_reg <= status_reg & 4'b0111;
            end
            chain1_nxt_state <= IDLE;
        end

        default: begin
            chain1_nxt_state <= IDLE;
        end

    endcase 
end

    assign pp_address = (chain1_cur_state == write_FILL_BUFFER) ? {1'b0, pp_address_reg}: 9'b0;
    assign pp_writeEnable = (chain1_cur_state == write_FILL_BUFFER) ? 1'b1 : 1'b0;
    assign pp_dataIn = (chain1_cur_state == write_FILL_BUFFER) ? data_reg : 32'b0;
    assign pp_switch = (chain1_cur_state == write_SWITCH_BUFFER) ? 1'b1 : 1'b0;
    assign dma_address = (chain1_cur_state == write_LAUNCH_WRITE) ? address_reg : 32'b0;
    assign dma_data_ready = (chain1_cur_state == write_LAUNCH_WRITE) ? 1'b1 : 1'b0;
    assign dma_byte_enable = (chain1_cur_state == write_LAUNCH_WRITE) ? byte_enable_reg : 4'b0;


endmodule
