module dma_ci #(parameter [7:0] customInstructionId = 8'd0 )
                           ( input wire         start, clock, reset,
                             input wire [31:0]  valueA,
                                                valueB,
                             input wire [7:0]   iseId,
                             output wire        done,
                             output wire [31:0] result);
    
    // DMA signals
    wire s_isMyIse = (iseId == customInstructionId) ? start : 1'b0;

    wire s_dataReady;
    wire s_readReady;
    wire [3:0] s_byteEnable;
    wire [31:0] s_address_to_read;
    wire [31:0] s_address_data;
    wire s_endTransactionIN;
    wire s_dataValidIN;
    wire s_busyIN;
    wire s_errorIN;

    wire [8:0] bufferAddress;
    wire [31:0] dataIn;
    wire writeEnable;
    wire [31:0] dataOut;

    wire [31:0] address_dataOUT;
    wire [3:0] byte_enableOUT;
    wire [7:0] busrt_sizeOUT;
    wire read_n_writeOUT;
    wire begin_transactionOUT;
    wire end_transactionOUT;
    wire data_validOUT;
    wire busyOUT;

    wire request;
    wire granted; // Assuming always granted for simplicity
    wire [3:0] s_dma_cur_state;

    wire s_endTransaction = (s_dma_cur_state == 4'b0) ? 1'b1 : 1'b0;

    DMA #(
        .Base(32'h40000000)
    ) dma_inst (
        .clock(clock),
        .reset(~reset),
        .ipcore_dataReady(s_dataReady),
        .ipcore_readReady(s_readReady),
        .ipcore_byteEnable(s_byteEnable),
        .ipcore_address_to_read(s_address_to_read),
        .ipcore_switch_ready(),

        .bufferAddress(bufferAddress),
        .dataIn(dataIn),
        .writeEnable(writeEnable),
        .dataOut(dataOut),

        .address_dataIN(s_address_data),
        .end_transactionIN(s_endTransactionIN),
        .data_validIN(s_dataValidIN),
        .busyIN(s_busyIN),
        .errorIN(s_errorIN),

        .address_dataOUT(address_dataOUT),
        .byte_enableOUT(byte_enableOUT),
        .busrt_sizeOUT(busrt_sizeOUT),
        .read_n_writeOUT(read_n_writeOUT),
        .begin_transactionOUT(begin_transactionOUT),
        .end_transactionOUT(end_transactionOUT),
        .data_validOUT(data_validOUT),
        .busyOUT(busyOUT),

        .request(request),
        .granted(granted),

        .s_dma_cur_state(s_dma_cur_state)
    );

    localparam [2:0] fsm_idle = 3'b000;
    localparam [2:0] fsm_wait_end = 3'b001;
    localparam [2:0] fsm_initiate_transaction = 3'b010;
    localparam [2:0] fsm_end_ci = 3'b011;

    reg [2:0] cur_state, nxt_state;
    reg [31:0] result_reg;
    reg [31:0] address_reg;
    reg [31:0] data_reg;
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

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            cur_state <= fsm_idle;
        end else begin
            cur_state <= nxt_state;
        end
    end

    always @(posedge clock) begin
        result_reg <= (reset == 1'b1) ? 32'b0 : 
                        (is_read ==1 && writeEnable == 1'b1) ? dataOut :
                        (is_read == 1'b0 && data_validOUT == 1'b1) ? address_dataOUT : result_reg;
        address_reg <= (reset == 1'b1) ? 32'b0 : (s_isMyIse) ? valueA : address_reg;
        is_read <= (reset == 1'b1) ? 1'b0 : (s_isMyIse) ? valueB[0] : is_read;
        data_reg <= (reset == 1'b1) ? 32'b0 : (s_isMyIse) ? valueB : data_reg;
    end
    

    assign result = (cur_state == fsm_end_ci) ? result_reg : 32'b0;
    assign done = (cur_state == fsm_end_ci) ? 1'b1 : 1'b0;
    assign s_dataReady = (cur_state == fsm_initiate_transaction) ? ~is_read : 1'b0;
    assign s_readReady = (cur_state == fsm_initiate_transaction) ? is_read : 1'b0;
    assign s_byteEnable = (cur_state == fsm_initiate_transaction) ? 4'b1111 : 4'b0000;
    assign s_address_to_read = (cur_state == fsm_initiate_transaction) ? address_reg : 32'b0;
    assign granted = 1'b1; // Assuming always granted for simplicity
    assign dataOut = (cur_state == fsm_wait_end) ? data_reg : 32'b0;
    assign address_dataIN = (is_read == 1'b1 && cur_state == fsm_wait_end) ? data_reg : 32'b0;
    assign s_endTransactionIN = (is_read == 1'b1 && cur_state == fsm_wait_end) ? 1'b1 : 1'b0;
    assign data_validIN = (is_read == 1'b1 && cur_state == fsm_wait_end) ? 1'b1 : 1'b0;
    assign s_busyIN = 0;
    assign s_errorIN = 0;




endmodule

                        