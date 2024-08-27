`include "ALU_1bit.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input signed [32-1:0] aluSrc1;
  input signed [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire [32-1:0] carryOut;
  wire zero, less;
  wire overflow;

  //Main function
  
  // Generate for the rest of the 31 ALU_1bit (from 1 to 31)
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) 
    begin : alu_gen
      if (i == 0) begin
        ALU_1bit alu (
          .a(aluSrc1[i]),
          .b(aluSrc2[i]),
          .invertA(invertA),
          .invertB(invertB),
          .operation(operation),
          .carryIn(invertB),
          .less(aluSrc1 < aluSrc2),
          .result(result[i]),
          .carryOut(carryOut[i])
        );
      end else begin
        ALU_1bit alu (
          .a(aluSrc1[i]),
          .b(aluSrc2[i]),
          .invertA(invertA),
          .invertB(invertB),
          .operation(operation),
          .carryIn(carryOut[i-1]),
          .less(1'b0),
          .result(result[i]),
          .carryOut(carryOut[i])
        );
      end
    end
  endgenerate
  //assign operation = (operation == 2'b01)? 2'b11 : operation;
  assign overflow = carryOut[30] ^ carryOut[31];
  assign zero = ~|result;
  
endmodule
