module Pipe_Reg (
  clk_i,
  rst_n,
  data_i,
  data_o
);

  parameter size = 64;

  //I/O ports
  input clk_i;
  input rst_n;
  input [size-1:0] data_i;

  output [size-1:0] data_o;

  //Internal Signals
  reg [size-1:0] data_o;

  //Main function
  always @(posedge clk_i) begin
    data_o = data_i;
  end

endmodule
