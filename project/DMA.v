module DMA #(
    parameter [31:0] Base = 32'h40000000)
    ( 
    input wire                    clock, reset,
    input wire                    dataReady,
    input wire                    readReady,
    input wire [31:0]             address_to_read,


    // Buffer interface
    output wire [31:0]            pushAddress,
    output wire [31:0]            popAddress,
    output wire [31:0]            pushData,
    output wire                   push,
    output wire                   switch,
    input wire [31:0]          popData,

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
    wire [31:0] buffer_data;
    wire s_reading_from_buffer_done;
    wire [31:0] s_address_to_read;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            cur_state <= fsm_idle;
        end else begin
            cur_state <= nxt_state;
        end
    end


    always @(*) begin
        if (errorIN) begin
            nxt_state = fsm_idle;
        end else begin
            case(cur_state)
                fsm_idle: nxt_state = (dataReady) ? fsm_asking_for_buffer : (readReady) ? fsm_read_request : fsm_idle;
                fsm_asking_for_buffer: nxt_state = fsm_reading_from_buffer;
                fsm_reading_from_buffer: nxt_state = (s_reading_from_buffer_done) ? fsm_write_request : fsm_reading_from_buffer;
                fsm_write_request: nxt_state = (granted) ? fsm_write_sending_handshake : fsm_write_request;
                fsm_write_sending_handshake: nxt_state = fsm_sending_data;
                fsm_sending_data: nxt_state = (busyIN)? fsm_sending_data : fsm_end_transaction; 
                fsm_end_transaction: nxt_state = fsm_idle;

                fsm_read_request: nxt_state = (granted) ? fsm_read_sending_handshake : fsm_read_request;
                fsm_read_sending_handshake: nxt_state = fsm_reading_data;
                fsm_reading_data: nxt_state = (end_transactionIN) ? fsm_reading_data : fsm_writting_buffer;
                fsm_writting_buffer: nxt_state = fsm_end_transaction;
                // default: nxt_state = fsm_idle;
            endcase
        end
    end

    assign buffer_data = (cur_state == fsm_reading_from_buffer) ? popData : 
                         (cur_state == fsm_reading_data) ? address_dataIN :
                         (cur_state == fsm_end_transaction || errorIN == 1'b1 || reset == 1'b1) ? 32'h0 : buffer_data;


    // Buffer interface set to read at the same location
    assign pushAddress = 32'h0;
    assign popAddress = (cur_state == fsm_asking_for_buffer) ? 32'h0 : 32'h0; 
    assign pushData = (cur_state == fsm_writting_buffer) ? buffer_data : 32'h0;
    assign push = (cur_state == fsm_writting_buffer) ? 1'b1 : 1'b0;
    assign switch = 1'b0;
    assign s_reading_from_buffer_done = 1'b1;
    assign s_address_to_read = (cur_state == fsm_idle && readReady) ? address_to_read : 
                               (reset == 1'b1 || cur_state == fsm_end_transaction) ? 32'h0 : s_address_to_read;

    assign address_dataOUT = (cur_state == fsm_write_sending_handshake ) ? 32'h1 : 
                             (cur_state == fsm_read_sending_handshake) ? s_address_to_read :
                             (cur_state == fsm_sending_data) ? buffer_data : 32'h0; //for now only 1 byte
    assign byte_enableOUT = (cur_state == fsm_write_sending_handshake || cur_state == fsm_read_sending_handshake) ? 4'hF : 4'h0; 
    assign busrt_sizeOUT = (cur_state == fsm_write_sending_handshake) ? 8'h0 : 8'h0; //for now only 1 word
    assign read_n_writeOUT = (cur_state == fsm_write_sending_handshake) ? 1'b0 : 1'b1; 
    assign begin_transactionOUT = (cur_state == fsm_write_sending_handshake || cur_state == fsm_read_sending_handshake) ? 1'b1 : 1'b0;

    assign end_transactionOUT = ((cur_state == fsm_sending_data && busyIN == 1'b0) || errorIN == 1'b1) ? 1'b1 : 1'b0;

    assign data_validOUT = (cur_state == fsm_sending_data) ? 1'b1 : 1'b0;

    assign busyOUT = (cur_state == fsm_sending_data) ? 1'b0 : 1'b0; //for now always 0

    assign request = (cur_state == fsm_write_request || cur_state == fsm_read_request) ? 1'b1 : 1'b0;
endmodule