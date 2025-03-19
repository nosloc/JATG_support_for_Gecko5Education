module ipcore(
    input wire JTCK,
    input wire JTDI,
    input wire JRTI1,
    input wire JRTI2,
    input wire JSHIFT,
    input wire JUPDATE,
    input wire JRSTN,
    input wire JCE1,
    input wire JCE2,
    output wire JTD1,
    output wire JTD2,
    output wire [8:0] LEDS,
    output wire [3:0] LEDS_colums
);

chain1 instruction_chain1 (
    .JTCK(JTCK),
    .JTDI(JTDI),
    .JRTI1(JRTI1),
    .JSHIFT(JSHIFT),
    .JUPDATE(JUPDATE),
    .JRSTN(JRSTN),
    .JCE1(JCE1),
    .JTD1(JTD1),
    .LEDS(LEDS)
);

chain2 instruction_chain2 (
    .JTCK(JTCK),
    .JTDI(JTDI),
    .JRTI2(JRTI2),
    .JSHIFT(JSHIFT),
    .JUPDATE(JUPDATE),
    .JRSTN(JRSTN),
    .JCE2(JCE2),
    .JTD2(JTD2),
    .LEDS_colums(LEDS_colums)
);

endmodule