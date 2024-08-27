`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [31:0] pc_in, pc_out;
  wire [31:0] pc_adder, branch_adder, jump_adder;
  wire [31:0] mux_branch_out;
  wire mux_branch_type_out, mux_branch_type_out1;
  wire [31:0] instr;
  wire [4:0] mux_write_reg_out;
  wire [31:0] reg_data_in, rs_data, rt_data;
  wire reg_write;
  wire [2:0] alu_op;
  wire alu_src, branch, mem_read, mem_write;
  wire [3:0] alu_operation;
  wire [1:0] fur_slt, reg_dst, mem_to_reg, jump, branch_type1, branch_type2;
  wire left_right;
  wire [31:0] sign_ext_out, zero_filled_out;
  wire [31:0] alu_src2;
  wire [31:0] alu_result;
  wire alu_zero, alu_overflow;
  wire [31:0] shifter_result;
  wire [31:0] data_mem_out;
  wire [31:0] mux_write_out, mux_write_out_2;


  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );
  // Add 4 to PC
  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i({ {28{1'b0}}, 4'b0100 }),
      .sum_o (pc_adder)
  );

  // Branch target
  Adder Adder2 (
      .src1_i(pc_adder),
      .src2_i(sign_ext_out << 2),
      .sum_o (branch_adder)
  );

  Mux3to1 #(
      .size(1)
  ) Mux_branch_type1 (
      .data0_i(alu_zero),
      .data1_i(~alu_zero),
      .data2_i(alu_result === 32'b00000000000000000000000000000001),
      .select_i(branch_type1),
      .data_o(mux_branch_type_out1)
  );

  Mux3to1 #(
      .size(1)
  ) Mux_branch_type2 (
      .data0_i(mux_branch_type_out1),
      .data1_i($signed(rs_data) != 0),
      .data2_i($signed(rs_data) >= 0),
      .select_i(branch_type2),
      .data_o(mux_branch_type_out)
  );
  
  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i(pc_adder),
      .data1_i(branch_adder),
      .select_i(branch && mux_branch_type_out),
      .data_o(mux_branch_out)
  );

  //always @(*) begin
  //      if(instr[31:26] == 6'b011100) $display("rs_data=%b, rt_data=%b",rs_data, rt_data);
  //      if(instr[31:26] == 6'b011100) $display("mux_branch_out=%b, mux_branch_type_out=%b, branch=%b", mux_branch_out, mux_branch_type_out, branch);
  //      $display("rs_data=%b, rt_data=%b",rs_data, rt_data);
  //end

  Mux3to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i(mux_branch_out),
      .data1_i({pc_adder[31:28], instr[25:0], 2'b00}),
      .data2_i(rs_data),
      .select_i(jump),
      .data_o(pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

  Mux3to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i(instr[20:16]), // Rt
      .data1_i(instr[15:11]), // Rd
      .data2_i(5'b11111), // reg 31
      .select_i(reg_dst),
      .data_o(mux_write_reg_out)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr[25:21]),
      .RTaddr_i(instr[20:16]),
      .RDaddr_i(mux_write_reg_out),
      .RDdata_i(mux_write_out_2),
      .RegWrite_i(reg_write),
      .RSdata_o(rs_data),
      .RTdata_o(rt_data)
  );

  Decoder Decoder (
      .instr_op_i(instr[31:26]),
      .funct_i(instr[5:0]),
      .RegWrite_o(reg_write),
      .ALUOp_o(alu_op),
      .ALUSrc_o(alu_src),
      .RegDst_o(reg_dst),
      .Jump_o(jump),
      .Branch_o(branch),
      .BranchType1_o(branch_type1),
      .BranchType2_o(branch_type2),
      .MemRead_o(mem_read),
      .MemWrite_o(mem_write),
      .MemtoReg_o(mem_to_reg)
  );

  ALU_Ctrl AC (
      .funct_i(instr[5:0]),
      .ALUOp_i(alu_op),
      .ALU_operation_o(alu_operation),
      .FURslt_o(fur_slt),
      .leftRight_o(left_right)
  );

  Sign_Extend SE (
      .data_i(instr[15:0]),
      .data_o(sign_ext_out)
  );

  Zero_Filled ZF (
      .data_i(instr[15:0]),
      .data_o(zero_filled_out)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i(rt_data),
      .data1_i(sign_ext_out),
      .select_i(alu_src),
      .data_o(alu_src2)
  );

  ALU ALU (
      .aluSrc1(rs_data),
      .aluSrc2(alu_src2),
      .ALU_operation_i(alu_operation),
      .result(alu_result),
      .zero(alu_zero),
      .overflow(alu_overflow)
  );

  Shifter shifter (
      .result(shifter_result),
      .leftRight(left_right),
      .shamt(instr[10:6]),
      .sftSrc(alu_src2)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i(alu_result),
      .data1_i(shifter_result),
      .data2_i(zero_filled_out),
      .select_i(fur_slt),
      .data_o(mux_write_out)
  );
  
  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(mux_write_out),
      .data_i(rt_data),
      .MemRead_i(mem_read),
      .MemWrite_i(mem_write),
      .data_o(data_mem_out)
  );

  Mux3to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(mux_write_out),
      .data1_i(data_mem_out),
      .data2_i(pc_adder),
      .select_i(mem_to_reg),
      .data_o(mux_write_out_2)
  );

  always @(*) begin
    if(instr[31:26] == 6'b011110) $display("pc=%d, test=%d, data=%d, data2=%d", pc_in, $signed(rs_data) >= 0, $signed(rs_data), rs_data);
  end

endmodule


