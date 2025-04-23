module jtag_support(
    // JTAG signals
    input wire JTCK, 
    input wire  JTDI, 
    input wire JSHIFT, 
    input wire JUPDATE, 
    input wire  JRSTN,
    input wire JCE1, 
    input wire JCE2, 
    input wire JRTI1, 
    input wire JRTI2, 
    output  wire JTDO1, 
    output  wire JTDO2,

    // Bus architecture signals
    output wire [31:0] address_dataOUT,
    output wire [3:0] byte_enableOUT,
    output wire [7:0] busrt_sizeOUT,
    output wire read_n_writeOUT,
    output wire begin_transactionOUT,
    output wire end_transactionOUT,
    output wire data_validOUT,
    output wire busyOUT,
    input wire [31:0] address_dataIN,
    input wire end_transactionIN,
    input wire data_validIN,
    input wire busyIN,
    input wire errorIN,

    // arbitrer signals
    output wire request,
    input wire granted
);

wire [8:0] s_pp_address_ipcore;
wire s_pp_writeEnable_ipcore;
wire [31:0] s_pp_dataIn_ipcore;
wire [31:0] s_pp_dataOut_ipcore;
wire s_pp_switch_ipcore;

wire [31:0] s_dma_address;
wire s_dma_data_ready;
wire [3:0] s_dma_byte_enable;
wire s_dma_readReady;

wire [8:0] s_pp_address_dma;
wire s_pp_writeEnable_dma;
wire [31:0] s_pp_dataIn_dma;
wire [31:0] s_pp_dataOut_dma;

// instantiate the ipcore module
ipcore ipcore (
    .JTCK(JTCK),
    .JTDI(JTDI),
    .JRTI1(JRTI1),
    .JRTI2(JRTI2),
    .JSHIFT(JSHIFT),
    .JUPDATE(JUPDATE),
    .JRSTN(JRSTN),
    .JCE1(JCE1),
    .JCE2(JCE2),
    .JTD1(JTDO1),
    .JTD2(JTDO2),

    // Chain1 outputs
    .pp_address(s_pp_address_ipcore), 
    .pp_writeEnable(s_pp_writeEnable_ipcore), 
    .pp_dataIn(s_pp_dataIn_ipcore), 
    .pp_dataOut(s_pp_dataOut_ipcore), 
    .pp_switch(s_pp_switch_ipcore), 

    // DMA connections
    .dma_address(s_dma_address),
    .dma_data_ready(s_dma_data_ready),
    .dma_byte_enable(s_dma_byte_enable),
    .dma_readReady(s_dma_readReady)
);

// Instantiate the Ping-Pong Buffer
pingpongbuffer pingpongbuffer_inst (
    .clock(JTCK),
    .addressA(s_pp_address_ipcore),
    .addressB(s_pp_address_dma),
    .writeEnableA(s_pp_writeEnable_ipcore),
    .writeEnableB(s_pp_writeEnable_dma),
    .dataInA(s_pp_dataIn_ipcore),
    .dataInB(s_pp_dataIn_dma),
    .dataOutA(s_pp_dataOut_ipcore),
    .dataOutB(s_pp_dataOut_dma),
    .switch(s_pp_switch_ipcore),
    .reset(JRSTN)
);

// Instantiate the DMA module
DMA dma_inst (
    .clock(JTCK),
    .reset(JRSTN),
    .ipcore_dataReady(s_dma_data_ready),
    .ipcore_readReady(s_dma_readReady),
    .ipcore_byteEnable(s_dma_byte_enable),
    .ipcore_address_to_read(s_dma_address),

    // Buffer interface
    .bufferAddress(s_pp_address_dma),
    .dataIn(s_pp_dataIn_dma),
    .writeEnable(s_pp_writeEnable_dma),
    .dataOut(s_pp_dataOut_dma),

    // Bus interface
    .address_dataIN(address_dataIN),
    .end_transactionIN(end_transactionIN),
    .data_validIN(data_validIN),
    .busyIN(busyIN),
    .errorIN(errorIN),
    .address_dataOUT(address_dataOUT),
    .byte_enableOUT(byte_enableOUT),
    .busrt_sizeOUT(busrt_sizeOUT),
    .read_n_writeOUT(read_n_writeOUT),
    .begin_transactionOUT(begin_transactionOUT),
    .end_transactionOUT(end_transactionOUT),
    .data_validOUT(data_validOUT),
    .busyOUT(busyOUT),

    // Arbitrer interface
    .request(request),
    .granted(granted) // Assuming granted is always high for simplicity
);



endmodule