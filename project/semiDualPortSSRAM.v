module semiDualPortSSRAM ( input wire [6:0]  addressA,
                                         addressB,
                       input wire        clockA,
                                         clockB,
                                         writeEnable,
                       input wire [31:0] dataInA,
                       output reg [31:0] dataOutB);

  reg [31:0] memory [0:127]; 
  
  always @(posedge clockA)
  begin
    if (writeEnable) memory[addressA] <= dataInA;
  end
  
  always @(posedge clockB) dataOutB <= memory[addressB];

endmodule