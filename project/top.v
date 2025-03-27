module top(
    // input wire TCK,
    // input wire TMS,
    // input wire TDI,
    // output wire TDO,
    output wire [9:0] red,
    output wire [9:0] blue,
    output wire [9:0] green,
    output wire [3:0] rgbRow
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
        .red(red),
        .blue(blue),
        .green(green),
        .rgbRow(rgbRow)

    );

    assign TDO = s_TDO;
endmodule
