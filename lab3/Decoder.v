module Decoder (
    instr_op_i,
    funct_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType1_o,
    BranchType2_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;
  input [6-1:0] funct_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output [2-1:0] RegDst_o;
  output [2-1:0] Jump_o;
  output Branch_o;
  output [2-1:0] BranchType1_o, BranchType2_o;
  output MemRead_o;
  output MemWrite_o;
  output [2-1:0] MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire [2-1:0] RegDst_o;
  wire [2-1:0] Jump_o;
  wire Branch_o;
  wire [2-1:0] BranchType1_o, BranchType2_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire [2-1:0] MemtoReg_o;

  //Main function
  assign RegWrite_o = (instr_op_i == 6'b000000 || instr_op_i == 6'b010011 || instr_op_i == 6'b011000 || instr_op_i == 6'b001111)? 1'b1 : 1'b0;
  assign ALUOp_o = (instr_op_i == 6'b000000) ? 3'b001 : // R-type
                   (instr_op_i == 6'b011000 || instr_op_i == 6'b101000 || instr_op_i == 6'b010011) ? 3'b010 : // I-type lw sw addi
                   (instr_op_i == 6'b011001 || instr_op_i == 6'b011010) ? 3'b011 : // I-type beq bne
                   (instr_op_i == 6'b011100) ? 3'b000: //blt
                   3'b100; // default
  assign ALUSrc_o = (instr_op_i == 6'b010011) | (instr_op_i == 6'b011000) | (instr_op_i == 6'b101000);
  assign RegDst_o = (instr_op_i == 6'b000000)? 2'b01 :
                    (instr_op_i == 6'b001111)? 2'b10:
                    2'b00;
  assign Jump_o = (instr_op_i == 6'b001100 || instr_op_i == 6'b001111)? 2'b01 :
                  (instr_op_i == 6'b000000 && funct_i == 6'b000001)? 2'b10 :
                   2'b00;
  assign Branch_o = (instr_op_i == 6'b011001) | (instr_op_i == 6'b011010) | (instr_op_i == 6'b011100) | (instr_op_i == 6'b011101) | (instr_op_i == 6'b011110);
  assign BranchType1_o = (instr_op_i == 6'b011010)? 2'b01 :
                         (instr_op_i == 6'b011001)? 2'b00 :
                         2'b10; // 0 for beq, 1 for bne, 2 for blt
  assign BranchType2_o = (instr_op_i == 6'b011101)? 2'b01 :
                         (instr_op_i == 6'b011110)? 2'b10 :
                         2'b00; // 1 for bnez, 2 for bgez
  assign MemRead_o = (instr_op_i == 6'b011000)? 1'b1 : 1'b0;
  assign MemWrite_o = (instr_op_i == 6'b101000 )? 1'b1 : 1'b0;
  assign MemtoReg_o = (instr_op_i == 6'b011000)? 2'b01 :
                      (instr_op_i == 6'b001111)? 2'b10 :
                       2'b00;
  
endmodule
