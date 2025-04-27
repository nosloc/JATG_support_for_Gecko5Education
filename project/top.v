module top(
    // input wire TCK,
    // input wire TMS,
    // input wire TDI,
    // output wire TDO,
    // output wire [9:0] red,
    // output wire [9:0] blue,
    // output wire [9:0] green,
    // output wire [3:0] rgbRow
);

    wire s_TDO, s_JTDI, s_JTCK, s_JRTI2, s_JRTI1, s_JSHIFT, s_JUPDATE, s_JRSTN, s_JCE2, s_JCE1;
    wire s_JTDO1, s_JTDO2;

    JTAGG JTAGG(
        // .TCK(TCK),
        // .TMS(TMS),
        // .TDI(TDI),
        .JTDO2(s_JTDO2),
        .JTDO1(s_JTDO1),
        // .TDO(s_TDO),
        .JTDI(s_JTDI),
        .JTCK(s_JTCK),
        .JRTI2(s_JRTI2),
        .JRTI1(s_JRTI1),
        .JSHIFT(s_JSHIFT),
        .JUPDATE(s_JUPDATE),
        .JRSTN(s_JRSTN),
        .JCE2(s_JCE2),
        .JCE1(s_JCE1)
    );


    wire [8:0] pp_address;
    wire pp_writeEnable;
    wire [31:0] pp_dataIn;
    wire [31:0] pp_dataOut;
    wire pp_switch;
    wire [31:0] dma_address;
    wire dma_data_ready;
    wire [3:0] dma_byte_enable;
    wire dma_readReady;
    wire switch_ready;

    ipcore ipcore(
        .JTCK(s_JTCK),
        .JTDI(s_JTDI),
        .JRTI1(s_JRTI1),
        .JRTI2(s_JRTI2),
        .JSHIFT(s_JSHIFT),
        .JUPDATE(s_JUPDATE),
        .JRSTN(s_JRSTN),
        .JCE1(s_JCE1),
        .JCE2(s_JCE2),
        .JTD1(s_JTDO1),
        .JTD2(s_JTDO2),

        // Chain1 outputs
        .pp_address(pp_address),
        .pp_writeEnable(pp_writeEnable),
        .pp_dataIn(pp_dataIn),
        .pp_dataOut(pp_dataOut),
        .pp_switch(pp_switch),

        // DMA connections
        .dma_address(dma_address),
        .dma_data_ready(dma_data_ready),
        .dma_byte_enable(dma_byte_enable),
        .dma_readReady(dma_readReady),
        .switch_ready(switch_ready)
    );

    assign TDO = s_JTDO1;
endmodule
