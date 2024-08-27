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
`include "Pipe_Reg.v"

module  Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [31:0] pc_in, pc_out;
  wire [31:0] instr_in, instr_out;
  wire [4:0] write_data1, write_data2;
  wire [15:0] I_type_out;
  wire [4:0] mux_write_reg_out, mux_write_reg, mux_write_reg_out2;
  wire [31:0] reg_data_in, rs_data, rt_data, rs_data_out, rt_data_out, rt_data_out2;
  wire reg_write, reg_write_out, reg_write_out2, reg_write_out3;
  wire [2:0] alu_op, alu_op_out;
  wire alu_src, alu_src_out, branch, mem_read, mem_read_out, mem_read_out2, mem_write, mem_write_out, mem_write_out2;
  wire [3:0] alu_operation;
  wire [1:0] fur_slt, reg_dst, reg_dst_out, mem_to_reg, mem_to_reg_out, mem_to_reg_out2, mem_to_reg_out3, jump, branch_type1, branch_type2;
  wire left_right;
  wire [31:0] sign_ext_out, zero_filled_out;
  wire [31:0] alu_src2;
  wire [31:0] alu_result;
  wire alu_zero, alu_overflow;
  wire [31:0] shifter_result;
  wire [31:0] data_mem_out, data_mem;
  wire [31:0] mux_write_out, mux_write, mux_write_out2, mux_write_out3;


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
      .sum_o (pc_in)
  );

  //always @(*) begin
  //      if(instr[31:26] == 6'b011100) $display("rs_data=%b, rt_data=%b",rs_data, rt_data);
  //      if(instr[31:26] == 6'b011100) $display("mux_branch_out=%b, mux_branch_type_out=%b, branch=%b", mux_branch_out, mux_branch_type_out, branch);
  //      $display("rs_data=%b, rt_data=%b",rs_data, rt_data);
  //end

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr_in)
  );

  Pipe_Reg #(
      .size(32)
  ) IF_ID (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .data_i({instr_in}),
      .data_o({instr_out})
  );

  Decoder Decoder (
      .instr_op_i(instr_out[31:26]),
      .funct_i(instr_out[5:0]),
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

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr_out[25:21]),
      .RTaddr_i(instr_out[20:16]),
      .RDaddr_i(mux_write_reg_out2),
      .RDdata_i(mux_write_out3),
      .RegWrite_i(reg_write_out3),
      .RSdata_o(rs_data),
      .RTdata_o(rt_data)
  );

  // 1, 1, 1, 1, 3, 2, 32, 32, 16, 5, 5
  Pipe_Reg #(
      .size(101)
  ) ID_EX (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .data_i({reg_write, mem_to_reg, mem_read, mem_write, alu_src, alu_op, reg_dst, rs_data, rt_data, instr_out[15:0], instr_out[20:16], instr_out[15:11]}),
      .data_o({reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, alu_src_out, alu_op_out, reg_dst_out, rs_data_out, rt_data_out, I_type_out, write_data1, write_data2})
  );

  Sign_Extend SE (
      .data_i(I_type_out),
      .data_o(sign_ext_out)
  );

  Zero_Filled ZF (
      .data_i(I_type_out),
      .data_o(zero_filled_out)
  );

  Shifter shifter (
      .result(shifter_result),
      .leftRight(left_right),
      .shamt(I_type_out[10:6]),
      .sftSrc(alu_src2)
  );

  Mux3to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i(write_data1), // Rt
      .data1_i(write_data2), // Rd
      .data2_i(5'b11111), // reg 31
      .select_i(reg_dst_out),
      .data_o(mux_write_reg)
  );

  ALU_Ctrl AC (
      .funct_i(I_type_out[5:0]),
      .ALUOp_i(alu_op_out),
      .ALU_operation_o(alu_operation),
      .FURslt_o(fur_slt),
      .leftRight_o(left_right)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i(rt_data_out),
      .data1_i(sign_ext_out),
      .select_i(alu_src_out),
      .data_o(alu_src2)
  );

  ALU ALU (
      .aluSrc1(rs_data_out),
      .aluSrc2(alu_src2),
      .ALU_operation_i(alu_operation),
      .result(alu_result),
      .zero(alu_zero),
      .overflow(alu_overflow)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i(alu_result),
      .data1_i(shifter_result),
      .data2_i(zero_filled_out),
      .select_i(fur_slt),
      .data_o(mux_write)
  );
  
  Pipe_Reg #(
      .size(74)
  ) EX_MEM (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .data_i({reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, mux_write, rt_data_out, mux_write_reg}),
      .data_o({reg_write_out2, mem_to_reg_out2, mem_read_out2, mem_write_out2, mux_write_out, rt_data_out2, mux_write_reg_out})
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(mux_write_out),
      .data_i(rt_data_out2),
      .MemRead_i(mem_read_out2),
      .MemWrite_i(mem_write_out2),
      .data_o(data_mem)
  );

  Pipe_Reg #(
      .size(72)
  ) MEM_WB (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .data_i({reg_write_out2, mem_to_reg_out2, data_mem, mux_write_out, mux_write_reg_out}),
      .data_o({reg_write_out3, mem_to_reg_out3, data_mem_out, mux_write_out2, mux_write_reg_out2})
  );

  Mux3to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(mux_write_out2),
      .data1_i(data_mem_out),
      .data2_i(pc_in),
      .select_i(mem_to_reg_out3),
      .data_o(mux_write_out3)
  );

  //always @(*) begin
  //  if(instr[31:26] == 6'b001111) $display("pc=%d, mux_write_out=%d, mux_write_reg_out=%d, pc_adder=%d, mem_to_reg=%d", pc_in, mux_write_out, mux_write_reg_out, pc_adder, mem_to_reg);
  //end

endmodule



