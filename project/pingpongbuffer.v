module pingpongbuffer(
    input wire clock,
    input wire[31:0] pushAddress,
    input wire[31:0] popAddress,
    input wire[31:0] pushData,
    input wire push,
    input wire switch
    output wire[31:0] popData
);

