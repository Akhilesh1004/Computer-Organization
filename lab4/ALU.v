module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input signed [32-1:0] aluSrc1;
  input signed [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  reg [31:0] unsigned_aluSrc1;
  reg [31:0] unsigned_aluSrc2;
  reg [31:0] result;
  reg zero;
  reg overflow;
  reg carry_out;

  //Main function
  always @(*) begin
    unsigned_aluSrc1 = aluSrc1;
    unsigned_aluSrc2 = aluSrc2;
    case (ALU_operation_i)
      4'b0000: result = aluSrc1 + aluSrc2;   // ADD
      4'b0001: result = aluSrc1 - aluSrc2;   // SUB
      4'b0010: result = aluSrc1 & aluSrc2;   // AND
      4'b0011: result = aluSrc1 | aluSrc2;   // OR
      4'b0100: result = ~(aluSrc1 | aluSrc2); // NOR
      4'b0101: result = unsigned_aluSrc2 << unsigned_aluSrc1; // SLLV
      4'b0110: result = unsigned_aluSrc2 >> unsigned_aluSrc1; // SLRV
      4'b0111: result = (aluSrc1 < aluSrc2) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000; // SLT
      default: result = 32'b0;                // Default
    endcase
    
    // Zero flag
    zero = (result == 32'b00000000000000000000000000000000);

    // Overflow detection for ADD and SUB operations
    case (ALU_operation_i)
      4'b0000: begin // ADD
        carry_out = ((aluSrc1[31] == aluSrc2[31]) && (result[31] != aluSrc1[31]));
        overflow = carry_out;
      end
      4'b0001: begin // SUB
        carry_out = ((aluSrc1[31] != aluSrc2[31]) && (result[31] != aluSrc1[31]));
        overflow = carry_out;
      end
      default: overflow = 1'b0;
    endcase
  end

endmodule
