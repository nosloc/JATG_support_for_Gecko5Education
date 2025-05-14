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
    output wire [3:0] dma_byte_enable,
    output wire dma_readReady,
    input wire switch_ready,

    // Visual Clues 
    output wire [5:0] status_reg_out
);


reg [7:0] remaining_size_reg;
reg [7:0] pp_address_reg;
wire is_operation_running;
wire s_ready_to_switch;
reg [31:0] read_data_from_buffer;
reg r_data_shifted_in;
reg r_launch_read;
reg r_data_shifted_out;

assign s_ready_to_switch = switch_ready;

assign n_reset = JRSTN;

reg [31:0] address_reg;
reg [3:0] byte_enable_reg;
reg [7:0] busrt_size_reg;

reg [35:0] shadow_reg;
reg [35:0] shift_reg;
reg [35:0] updated_data_reg;

reg update_reg;

reg [5:0] status_next;
reg [5:0] status_reg;

reg [31:0] data_reg;
reg [7:0] block_size_reg;
reg write_to_buffer;

localparam IDLE =                       0;
localparam write_FILL_BUFFER =          1;
localparam write_WAIT_FOR_SWITCH =      2;
localparam write_SWITCH_BUFFER =        3;
localparam write_LAUNCH_WRITE =         4;
localparam read_LAUNCH_READ =           5;
localparam read_WAIT_FOR_SWITCH =       6;
localparam read_DATA_READY_TO_READ =    7;
localparam read_SWITCH_BUFFER =         8;
localparam read_ASK_BUFFER =            9;
localparam read_STORE_BUFFER_ANSWER =   10;



reg [4:0] chain1_cur_state;
reg [4:0] chain1_nxt_state;
assign status_reg_out = block_size_reg[5:0];

// The status register is used to indicate the current state of the operation
assign is_operation_running = (status_reg[3] == 1'b1 | status_reg[4] == 1'b1) ? 1'b1 : 1'b0;


assign JTD1 = shift_reg[0];
assign buffer_full = (block_size_reg == 8'b11111111) ? 1'b1 : 1'b0;


always @(posedge JTCK) begin
    if (n_reset == 0) begin
        shift_reg <= 36'b0;
    end
    // handle the JTAG signals
    else begin
         if (JCE1) begin
        // Shifting data in
            if (JSHIFT) begin
                shift_reg <= {JTDI, shift_reg[35:1]};
            end
            // capture the status register
            else begin
                shift_reg <= shadow_reg;
            end
        end 

    end
    update_reg <= (n_reset == 1'b0) ? 0 : JUPDATE;
    updated_data_reg <= (n_reset == 1'b0) ? 0 : (JUPDATE == 1'b1) ? shift_reg : updated_data_reg;
    // Precompute the status register
    if (JUPDATE == 1'b1) begin
        case (shift_reg[3:0])
            4'b0001: status_next = status_reg | 6'b000001;
            4'b0010: status_next = status_reg | 6'b000010;
            4'b0011: status_next = status_reg | 6'b000100;
            default: status_next = status_reg;
        endcase
    end
end

always @(posedge JTCK) begin
    if (n_reset == 0 || updated_data_reg[3:0] == 4'b1111) begin
        shadow_reg <= 36'b0;
        address_reg <= 32'b0;
        byte_enable_reg <= 4'b1111;
        busrt_size_reg <= 8'b0;
        remaining_size_reg <= 8'b0;
        status_reg <= 6'b0;
        block_size_reg <= 8'b0;
        data_reg <= 32'b0;
        write_to_buffer <= 1'b0;
    end
    else if (update_reg == 1'b1) begin

        status_reg <= status_next;
                        
        shadow_reg <=   (updated_data_reg[3:0] == 4'b0100) ? address_reg :
                        (updated_data_reg[3:0] == 4'b0101) ? byte_enable_reg :
                        (updated_data_reg[3:0] == 4'b0110) ? busrt_size_reg :
                        {30'b0, status_next}; 

        address_reg <= (updated_data_reg[3:0] == 4'b0001) ? updated_data_reg[35:4] : address_reg;

        byte_enable_reg <= (updated_data_reg[3:0] == 4'b0010) ? updated_data_reg[7:4] : byte_enable_reg;

        busrt_size_reg <= (updated_data_reg[3:0] == 4'b0011) ? updated_data_reg[11:4] : busrt_size_reg;

        block_size_reg <= (updated_data_reg[3:0] == 4'b1000 && buffer_full == 1'b0) ? block_size_reg + 1 : block_size_reg;

        write_to_buffer <= (updated_data_reg[3:0] == 4'b1000 && buffer_full == 1'b0) ? 1'b1 : 1'b0;

        data_reg <= (updated_data_reg[3:0] == 4'b1000 && buffer_full == 1'b0) ? updated_data_reg[35:4] : data_reg;
    end
end

assign pp_address = (write_to_buffer == 1'b1) ? {1'b0, block_size_reg}: 9'b0;
assign pp_writeEnable = (write_to_buffer == 1'b1) ? 1'b1 : 1'b0;
assign pp_dataIn = (write_to_buffer == 1'b1) ? data_reg : 32'b0;
//     assign pp_switch = (chain1_cur_state == write_SWITCH_BUFFER | chain1_cur_state == read_SWITCH_BUFFER) ? 1'b1 : 1'b0;
//     assign dma_address = (chain1_cur_state == write_LAUNCH_WRITE | chain1_cur_state == read_LAUNCH_READ) ? address_reg : 32'b0;
//     assign dma_data_ready = (chain1_cur_state == write_LAUNCH_WRITE) ? 1'b1 : 1'b0;
//     assign dma_byte_enable = (chain1_cur_state == write_LAUNCH_WRITE | chain1_cur_state == read_LAUNCH_READ) ? byte_enable_reg : 4'b0;
//     assign dma_readReady = (chain1_cur_state == read_LAUNCH_READ) ? 1'b1 : 1'b0;
// always @(posedge JTCK or negedge JRSTN) begin
//     if (JRSTN == 0) begin
//         shift_reg <= 34'b0;
//         status_reg <= 6'b0;
//         address_reg <= 32'b0;
//         byte_enable_reg <= 4'b0;
//         busrt_size_reg <= 8'b0;
//         remaining_size_reg <= 8'b0;
//         pp_address_reg <= 8'b0;
//         r_data_shifted_in <= 1'b0;
//         r_launch_read <= 1'b0;
//         r_data_shifted_out <= 1'b0;
//         read_data_from_buffer <= 32'b0;
//         chain1_cur_state <= IDLE;
//     end
//     else  begin
//         // Reset the registers
//         r_data_shifted_in <= 1'b0;
//         r_launch_read <= 1'b0;
//         r_data_shifted_out <= 1'b0;
        
//         // Move to the next state
//         chain1_cur_state <= chain1_nxt_state;

//         // Handle internal signals
//         case (chain1_cur_state)
//             write_FILL_BUFFER: begin 
//                 if (remaining_size_reg != 0) begin
//                     remaining_size_reg <= remaining_size_reg - 1;
//                 end
//             end 
//             write_LAUNCH_WRITE: begin
//                 if (remaining_size_reg == 0) begin
//                     status_reg <= status_reg & 6'b0111;
//                 end
//             end
//             read_STORE_BUFFER_ANSWER: begin
//                 read_data_from_buffer <= pp_dataOut;
//                 status_reg <= status_reg | 6'b100000;
//             end
//             read_DATA_READY_TO_READ: begin
//                 if (r_data_shifted_out) begin
//                     status_reg[5] <= 1'b0;
//                     if (remaining_size_reg == 0) begin
//                         status_reg[4] <= 1'b0;
//                     end
//                     else begin
//                         remaining_size_reg <= remaining_size_reg - 1;
//                     end
//                 end
//             end
//         endcase

//         // Update datas registers based on the instruction used
//         if (JUPDATE) begin
//             case (shift_reg[3:0])
//                 4'b0001: begin
//                     // Writting to address register
//                     if (~is_operation_running) begin
//                         address_reg <= shift_reg[35:4];
//                         status_reg <= status_reg | 6'b0001;
//                     end
//                 end
//                 4'b0010: begin
//                     // writting to byte enable register
//                     if (~is_operation_running) begin
//                         byte_enable_reg <= shift_reg[7:4];
//                         status_reg <= status_reg | 6'b0010;
//                     end
//                 end
//                 4'b0011: begin
//                     // writting the size reg
//                     if (~is_operation_running) begin
//                         busrt_size_reg <= shift_reg[11:4];
//                         remaining_size_reg <= shift_reg[11:4];
//                         status_reg <= status_reg | 6'b0100;
//                     end
//                 end
//                 4'b1000: begin
//                     // Send data
//                     data_reg <= shift_reg[35:4];
//                     status_reg <= status_reg | 6'b1000;
//                     r_data_shifted_in <= 1'b1;
//                 end
//                 4'b1001: begin
//                     // Start the read operation
//                     status_reg <= status_reg | 6'b10000;
//                     r_launch_read <= 1'b1;
//                 end
//                 4'b1010: begin 
//                     // Read operation and move to next word
//                     status_reg[5] <= 1'b0;
//                 end
//             endcase 
//         end
//     end
// end

// always @(posedge JTCK or negedge JRSTN) 
//     begin
//         if (JRSTN == 0) begin
//             // chain1_cur_state <= IDLE;
//             // read_data_from_buffer <= 32'b0;
//         end
//         else begin 
//         //     chain1_cur_state = chain1_nxt_state;
//         //     case (chain1_cur_state)
//         //         write_FILL_BUFFER: begin 
//         //             if (remaining_size_reg != 0) begin
//         //                 remaining_size_reg <= remaining_size_reg - 1;
//         //             end
//         //         end 
//         //         write_LAUNCH_WRITE: begin
//         //             if (remaining_size_reg == 0) begin
//         //                 status_reg <= status_reg & 6'b0111;
//         //             end
//         //         end
//         //         read_STORE_BUFFER_ANSWER: begin
//         //             read_data_from_buffer <= pp_dataOut;
//         //             status_reg <= status_reg | 6'b100000;
//         //         end
//         //         read_DATA_READY_TO_READ: begin
//         //             if (r_data_shifted_out) begin
//         //                 status_reg[5] <= 1'b0;
//         //                 if (remaining_size_reg == 0) begin
//         //                     status_reg[4] <= 1'b0;
//         //                 end
//         //                 else begin
//         //                     remaining_size_reg <= remaining_size_reg - 1;
//         //                 end
//         //             end
//         //         end
//         // endcase
//         end
//     end 

// always @(*) begin
//     case (chain1_cur_state)
//         IDLE: begin
//             if (r_data_shifted_in) begin
//                 chain1_nxt_state <= write_FILL_BUFFER;
//             end
//             else begin
//                 if (r_launch_read) begin
//                     chain1_nxt_state <= read_LAUNCH_READ;
//                 end
//                 else begin
//                     chain1_nxt_state <= IDLE;
//                 end
//             end
//         end
//         write_FILL_BUFFER: begin
//             if (remaining_size_reg == 0) begin
//                 chain1_nxt_state <= write_WAIT_FOR_SWITCH;
//             end
//             else begin
//                 chain1_nxt_state <= IDLE;
//             end
//         end

//         write_WAIT_FOR_SWITCH: begin
//             if (s_ready_to_switch) begin
//                 chain1_nxt_state <= write_SWITCH_BUFFER;
//             end
//             else begin
//                 chain1_nxt_state <= write_WAIT_FOR_SWITCH;
//             end
//         end

//         write_SWITCH_BUFFER: begin
//             chain1_nxt_state <= write_LAUNCH_WRITE;
//         end

//         write_LAUNCH_WRITE: begin
//             chain1_nxt_state <= IDLE;
//         end

//         read_LAUNCH_READ: begin
//             chain1_nxt_state <= read_WAIT_FOR_SWITCH;
//         end

//         read_WAIT_FOR_SWITCH: begin
//             if (s_ready_to_switch) begin
//                 chain1_nxt_state <= read_SWITCH_BUFFER;
//             end
//             else begin
//                 chain1_nxt_state <= read_WAIT_FOR_SWITCH;
//             end
//         end

//         read_SWITCH_BUFFER: begin
//             chain1_nxt_state <= read_ASK_BUFFER;
//         end

//         read_ASK_BUFFER: begin
//             chain1_nxt_state <= read_STORE_BUFFER_ANSWER;
//         end

//         read_STORE_BUFFER_ANSWER: begin
//             chain1_nxt_state <= read_DATA_READY_TO_READ;
//         end

//         read_DATA_READY_TO_READ: begin
//             if (r_data_shifted_out) begin
//                 // r_data_shifted_out <= 1'b0;
//                 if (remaining_size_reg == 0) begin
//                     chain1_nxt_state <= IDLE;
//                 end
//                 else begin
//                     chain1_nxt_state <= read_ASK_BUFFER;
//                 end
//             end
//             else begin
//                 chain1_nxt_state <= read_DATA_READY_TO_READ;
//             end
            
//         end
//         default: begin
//             chain1_nxt_state <= IDLE;
//         end

//     endcase 
// end

//     assign pp_address = (chain1_cur_state == write_FILL_BUFFER | chain1_cur_state == read_ASK_BUFFER) ? {1'b0, pp_address_reg}: 9'b0;
//     assign pp_writeEnable = (chain1_cur_state == write_FILL_BUFFER) ? 1'b1 : 1'b0;
//     assign pp_dataIn = (chain1_cur_state == write_FILL_BUFFER) ? data_reg : 32'b0;
//     assign pp_switch = (chain1_cur_state == write_SWITCH_BUFFER | chain1_cur_state == read_SWITCH_BUFFER) ? 1'b1 : 1'b0;
//     assign dma_address = (chain1_cur_state == write_LAUNCH_WRITE | chain1_cur_state == read_LAUNCH_READ) ? address_reg : 32'b0;
//     assign dma_data_ready = (chain1_cur_state == write_LAUNCH_WRITE) ? 1'b1 : 1'b0;
//     assign dma_byte_enable = (chain1_cur_state == write_LAUNCH_WRITE | chain1_cur_state == read_LAUNCH_READ) ? byte_enable_reg : 4'b0;
//     assign dma_readReady = (chain1_cur_state == read_LAUNCH_READ) ? 1'b1 : 1'b0;


endmodule
