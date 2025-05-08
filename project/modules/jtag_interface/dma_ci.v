module dma_ci #(parameter [7:0] customInstructionId = 8'd0 )
                           ( input wire         start, clock, reset,
                             input wire [31:0]  valueA,
                                                valueB,
                             input wire [7:0]   iseId,
                             output wire        done,
                             output wire [31:0] result, 

                            //  Interface with the DMA controller

                            output wire s_dataReady,
                            output wire s_readReady,
                            output wire [3:0] s_byteEnable,
                            output wire [31:0] s_address_to_read,
                            input wire s_endTransaction,
                            input wire s_dataValid,
                            input wire s_address_data
                             );
    
    // DMA signals
    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;

    localparam [2:0] fsm_idle = 3'b000;
    localparam [2:0] fsm_wait_end = 3'b001;
    localparam [2:0] fsm_initiate_transaction = 3'b010;
    localparam [2:0] fsm_end_ci = 3'b011;

    reg [2:0] cur_state, nxt_state;
    reg [31:0] result_reg;
    reg [31:0] address_reg;
    reg is_read;    

    always @(*) begin
        case(cur_state)
            fsm_idle: nxt_state = (s_isMyIse) ? fsm_initiate_transaction : fsm_idle;
            fsm_initiate_transaction: nxt_state = fsm_wait_end;
            fsm_wait_end: nxt_state = (s_endTransaction) ? fsm_end_ci : fsm_wait_end;
            fsm_end_ci: nxt_state = fsm_idle;
            default: nxt_state = fsm_idle;
        endcase
    end 

    always @(posedge clock or negedge reset) begin
        if (reset) begin
            cur_state <= fsm_idle;
        end else begin
            cur_state <= nxt_state;
        end
    end

    always @(posedge clock or negedge reset) begin
        result_reg <= (reset == 1'b1) ? 32'b0 : (s_dataValid == 1'b1) ? s_address_data : result_reg;
        address_reg <= (reset == 1'b1) ? 32'b0 : (s_isMyIse) ? valueA : address_reg;
        is_read <= (reset == 1'b1) ? 1'b0 : (s_isMyIse) ? valueB[0] : is_read;
    end
    

    assign result = (cur_state == fsm_end_ci) ? result_reg : 32'b0;
    assign done = (cur_state == fsm_end_ci) ? 1'b1 : 1'b0;
    assign s_dataReady = (cur_state == fsm_initiate_transaction) ? is_read : 1'b0;
    assign s_readReady = (cur_state == fsm_initiate_transaction) ? ~is_read : 1'b0;
    assign s_byteEnable = (cur_state == fsm_initiate_transaction) ? 4'b1111 : 4'b0000;
    assign s_address_to_read = (cur_state == fsm_initiate_transaction) ? address_reg : 32'b0;

endmodule

                        