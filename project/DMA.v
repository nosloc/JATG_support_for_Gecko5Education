module DMA #(
    parameter [31:0] Base = 32'h40000000)
    ( 
    input wire                    clock, reset,
    input wire                    ipcore_dataReady,
    input wire                    ipcore_readReady,
    input wire [3:0]              ipcore_byteEnable,
    input wire [31:0]             ipcore_address_to_read,
    output wire                   ipcore_switch_ready,


    // Buffer interface
    output wire [8:0]             bufferAddress,
    output wire [31:0]            dataIn,
    output wire                   writeEnable,
    input wire [31:0]             dataOut,

    // here the bus interface is defined
    input wire [31:0] address_dataIN,
    input wire end_transactionIN, 
    input wire data_validIN, 
    input wire busyIN,
    input wire errorIN,

    output wire [31:0] address_dataOUT,
    output wire [3:0] byte_enableOUT,
    output wire [7:0] busrt_sizeOUT,
    output wire read_n_writeOUT,
    output wire begin_transactionOUT,
    output wire end_transactionOUT,
    output wire data_validOUT,
    output wire busyOUT,



    // here the interface with the arbitrer
    output wire        request,
    input wire         granted

    );


    // Write states
    localparam fsm_idle = 0;
    localparam fsm_write_request = 1;
    localparam fsm_write_sending_handshake = 2;
    localparam fsm_sending_data = 3;
    localparam fsm_end_transaction = 4;
    localparam fsm_reading_from_buffer = 5;
    localparam fsm_asking_for_buffer = 6;
    localparam fsm_read_request = 7;
    localparam fsm_read_sending_handshake = 8;
    localparam fsm_reading_data = 9;
    localparam fsm_writting_buffer = 10;

    reg [3:0] cur_state, nxt_state;
    reg [31:0] buffer_data;
    wire s_reading_from_buffer_done;
    reg [31:0] s_address;
    reg [3:0] s_byte_enable;



    // always @(posedge clock or negedge reset) begin
    //     if (~reset) begin
    //         cur_state <= fsm_idle;
    //     end else begin
    //         cur_state <= nxt_state;
    //     end
    // end


    always @(*) begin
        if (errorIN) begin
            nxt_state = fsm_idle;
        end else begin
            case(cur_state)
                fsm_idle: nxt_state = (ipcore_dataReady) ? fsm_asking_for_buffer : (ipcore_readReady) ? fsm_read_request : fsm_idle;
                fsm_asking_for_buffer: nxt_state = fsm_reading_from_buffer;
                fsm_reading_from_buffer: nxt_state = (s_reading_from_buffer_done) ? fsm_write_request : fsm_reading_from_buffer;
                fsm_write_request: nxt_state = (granted) ? fsm_write_sending_handshake : fsm_write_request;
                fsm_write_sending_handshake: nxt_state = fsm_sending_data;
                fsm_sending_data: nxt_state = (busyIN)? fsm_sending_data : fsm_end_transaction; 
                fsm_end_transaction: nxt_state = fsm_idle;

                fsm_read_request: nxt_state = (granted) ? fsm_read_sending_handshake : fsm_read_request;
                fsm_read_sending_handshake: nxt_state = fsm_reading_data;
                fsm_reading_data: nxt_state = (end_transactionIN) ? fsm_writting_buffer : fsm_reading_data;
                fsm_writting_buffer: nxt_state = fsm_end_transaction;
                // default: nxt_state = fsm_idle;
            endcase
        end
    end

    always @(posedge clock or negedge reset) begin 
        if (~reset) begin
            buffer_data <= 32'h0;
            s_address <= 32'h0;
            s_byte_enable <= 4'h0;
            cur_state <= fsm_idle;
        end
        else begin 
            cur_state <= nxt_state;
            if (cur_state == fsm_reading_from_buffer) begin
                buffer_data <= dataOut;
            end else if (cur_state == fsm_reading_data && data_validIN == 1'b1) begin
                buffer_data <= address_dataIN;
            end else if (cur_state == fsm_end_transaction || errorIN == 1'b1) begin
                buffer_data <= 32'h0;
            end
            if (cur_state == fsm_idle && (ipcore_readReady || ipcore_dataReady)) begin
                s_byte_enable <= ipcore_byteEnable;
                s_address <= ipcore_address_to_read;
            end else if (cur_state == fsm_end_transaction) begin
                s_address <= 32'h0;
                s_byte_enable <= 4'h0;
            end
        end
    end

    // assign buffer_data = (cur_state == fsm_reading_from_buffer) ? dataOut : 
    //                      (cur_state == fsm_reading_data && data_validIN == 1'b1) ? address_dataIN :
    //                      (cur_state == fsm_end_transaction || errorIN == 1'b1 || reset == 1'b0) ? 32'h0 : buffer_data;


    // Buffer interface set to read at the same location
    assign bufferAddress = 32'h0;
    assign dataIn = (cur_state == fsm_writting_buffer) ? buffer_data : 32'h0;
    assign writeEnable = (cur_state == fsm_writting_buffer) ? 1'b1 : 1'b0;
    assign s_reading_from_buffer_done = 1'b1;
    // assign s_address = (cur_state == fsm_idle && (ipcore_readReady || ipcore_dataReady)) ? ipcore_address_to_read : 
    //                            (reset == 1'b0 || cur_state == fsm_end_transaction) ? 32'h0 : s_address;
    // assign s_byte_enable = (cur_state == fsm_idle && (ipcore_readReady || ipcore_dataReady)) ? ipcore_byteEnable : 
    //                            (reset == 1'b0 || cur_state == fsm_end_transaction) ? 4'h0 : s_byte_enable;

    assign address_dataOUT = (cur_state == fsm_write_sending_handshake ) ? s_address: 
                             (cur_state == fsm_read_sending_handshake) ? s_address:
                             (cur_state == fsm_sending_data) ? buffer_data : 32'h0; //for now only 1 byte
    assign byte_enableOUT = (cur_state == fsm_write_sending_handshake || cur_state == fsm_read_sending_handshake) ? s_byte_enable : 4'h0; 
    assign busrt_sizeOUT = (cur_state == fsm_write_sending_handshake) ? 8'h0 : 8'h0; //for now only 1 word
    assign read_n_writeOUT = (cur_state == fsm_read_sending_handshake) ? 1'b1 : 1'b0; 
    assign begin_transactionOUT = (cur_state == fsm_write_sending_handshake || cur_state == fsm_read_sending_handshake) ? 1'b1 : 1'b0;

    assign end_transactionOUT = ((cur_state == fsm_sending_data && busyIN == 1'b0) || errorIN == 1'b1) ? 1'b1 : 1'b0;

    assign data_validOUT = (cur_state == fsm_sending_data) ? 1'b1 : 1'b0;

    assign busyOUT = (cur_state == fsm_sending_data) ? 1'b0 : 1'b0; //for now always 0

    assign request = (cur_state == fsm_write_request || cur_state == fsm_read_request) ? 1'b1 : 1'b0;

    assign ipcore_switch_ready = (cur_state == fsm_idle |
                                    // cur_state == fsm_write_request |
                                    // cur_state == fsm_write_sending_handshake |
                                    // cur_state == fsm_sending_data |
                                    cur_state == fsm_end_transaction) ? 1'b1 : 1'b0;
endmodule