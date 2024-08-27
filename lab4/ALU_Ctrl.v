module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o;

  //Main function
  /*your code here*/
  assign FURslt_o = (funct_i == 6'b010010 || funct_i == 6'b100010 )? 2'b01 :
                    (ALUOp_i == 3'b001 || ALUOp_i == 3'b010 )? 2'b00:
                    2'b11;
  assign leftRight_o = (funct_i == 6'b010010)? 1'b1 : 1'b0;// 1 for left, 0 for right
  // 0 for add, 1 for sub, 2 for and, 3 for or, 4 for nor, 5 for sllv, 6 for slrv, 7 for slt, 8 for jr
  assign ALU_operation_o = (funct_i == 6'b100011 || ALUOp_i == 3'b010)? 4'b0000:
                           (funct_i == 6'b010011 || ALUOp_i == 3'b011)? 4'b0001:
                           (funct_i == 6'b011111)? 4'b0010:
                           (funct_i == 6'b101111)? 4'b0011:
                           (funct_i == 6'b010000)? 4'b0100:
                           (funct_i == 6'b011000)? 4'b0101:
                           (funct_i == 6'b101000)? 4'b0110:
                           (funct_i == 6'b010100)? 4'b0111:
                           4'b1000;
  
endmodule
