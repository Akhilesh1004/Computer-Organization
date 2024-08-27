`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;
  wire sum;
  wire a_in, b_in;
  wire and_out, or_out;

  //Main function

  xor x1 (a_in, a, invertA);
  xor x2 (b_in, b, invertB);
  and a1 (and_out, a_in, b_in);
  or  o1 (or_out, a_in, b_in);

  // Full Adder for addition and subtraction
  Full_adder fa (
    .carryIn(carryIn),
    .input1(a_in),
    .input2(b_in),
    .sum(sum),
    .carryOut(carryOut)
  );
  
  reg r1;
  always @(*) begin
    case (operation)
      2'b00: r1 = and_out;
      2'b01: r1 = less;
      2'b10: r1 = or_out;
      2'b11: r1 = sum;
    endcase
  end
  assign result = r1;
endmodule
