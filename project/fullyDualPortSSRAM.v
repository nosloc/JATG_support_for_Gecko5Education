module fullyDualPortSSRAM ( input wire [8:0]  addressA,
                                         addressB,
                       input wire        clockA,
                                         clockB,
                                         writeEnableA, writeEnableB,
                       input wire [31:0] dataInA, dataInB,
                       output reg [31:0] dataOutA, dataOutB);

  reg [31:0] memoryContent [511:0]; // 2kbit memory
  
  always @(posedge clockA)
  begin
    if (writeEnableA == 1'b1) memoryContent[addressA] = dataInA;
    dataOutA = memoryContent[addressA];
  end
  always @(posedge clockB)
    begin
      if (writeEnableB == 1'b1) memoryContent[addressB] = dataInB;
      dataOutB = memoryContent[addressB];
    end
endmodule