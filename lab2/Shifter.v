module Shifter (
    leftRight,
    shamt,
    sftSrc,
    result
);

  //I/O ports
  input leftRight;
  input [5-1:0] shamt;
  input [32-1:0] sftSrc;

  output [32-1:0] result;

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
