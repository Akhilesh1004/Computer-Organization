module Shifter (
    result,
    leftRight,
    shamt,
    sftSrc
);

  //I/O ports
  output [32-1:0] result;

  input leftRight;
  input [5-1:0] shamt;
  input [32-1:0] sftSrc;

  //Internal Signals
  wire [32-1:0] result;

  //Main function
  reg[31:0] r1;
  always @* begin
    case (leftRight)
      1'b1: r1 = sftSrc << shamt;  // Logical shift left
      1'b0: r1 = sftSrc >> shamt;  // Logical shift right
    endcase
  end
  assign result = r1;


endmodule
