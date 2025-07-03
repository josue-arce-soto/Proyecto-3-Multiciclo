// design.sv - Procesador RISC-V Multiciclo

`define MULTICYCLE

`include "mux_2_1.sv"
`include "mux_4_1.sv"
`include "adder.sv"
`include "register.sv"
`include "reg_file.sv"
`include "alu.sv"
`include "data_mem.sv"
`include "inst_mem.sv"
`include "imm_gen.sv"
`include "control_multicycle.sv"

module top #(parameter WIDTH=32, parameter DEPTH=5) (
  input logic clk,
  input logic rst
);

  // Señales internas
  logic [WIDTH-1:0] PC, IR, A, B, ALUOut, MDR, Imm, ALUResult;
  logic [WIDTH-1:0] inst_mem_data, data_mem_data;
  logic [4:0] rs1, rs2, rd;
  logic [6:0] opcode;
  logic [2:0] func3;
  logic [6:0] func7;

  // Señales de control
  logic pc_write, ir_write, reg_write, mem_read, mem_write;
  logic alu_src_a, alu_src_b, mem_to_reg;
  logic aluout_write, mdr_write;
  logic [1:0] alu_op;

  // INSTRUCTION FETCH
  inst_mem #(WIDTH, 16) imem (
    .rst(rst),
    .addr(PC[15:0]),
    .rd(1'b1),
    .data_out(inst_mem_data)
  );

  register #(WIDTH) pc_reg (
    .clk(clk), .rst(rst), .data_in(ALUResult), .wr(pc_write), .data_out(PC)
  );

  register #(WIDTH) ir_reg (
    .clk(clk), .rst(rst), .data_in(inst_mem_data), .wr(ir_write), .data_out(IR)
  );

  // INSTRUCTION DECODE
  assign rs1 = IR[19:15];
  assign rs2 = IR[24:20];
  assign rd  = IR[11:7];
  assign opcode = IR[6:0];
  assign func3  = IR[14:12];
  assign func7  = IR[31:25];

  reg_file #(WIDTH, DEPTH) rf (
    .clk(clk), .rst(rst),
    .write_data(mem_to_reg ? MDR : ALUOut),
    .write_register(rd), .wr(reg_write),
    .read_register_1(rs1), .read_register_2(rs2),
    .rd(1'b1), .read_data_1(A), .read_data_2(B)
  );

  imm_gen #(WIDTH) imm_gen_inst (
    .instr(IR),
    .data_out(Imm)
  );

  // INSTRUCTION EXECUTION
  logic [WIDTH-1:0] alu_in_a, alu_in_b;

  mux_2_1 #(WIDTH) mux_alu_a (
    .A(PC), .B(A), .sel(alu_src_a), .out(alu_in_a)
  );

  mux_2_1 #(WIDTH) mux_alu_b (
    .A(B), .B(Imm), .sel(alu_src_b), .out(alu_in_b)
  );

  alu #(WIDTH) alu_unit (
    .data_in_1(alu_in_a), .data_in_2(alu_in_b),
    .func3(func3), .func7(func7), .opcode(opcode),
    .data_out(ALUResult), .zero(), .comparison()
  );

  register #(WIDTH) aluout_reg (
    .clk(clk), .rst(rst), .data_in(ALUResult), .wr(aluout_write), .data_out(ALUOut)
  );

  // MEMORY ACCESS
  data_mem #(WIDTH, 16) dmem (
    .clk(clk), .rst(rst),
    .data_in(B), .addr(ALUOut[15:0]),
    .wr(mem_write), .rd(mem_read),
    .one_byte(1'b0), .two_bytes(1'b0), .four_bytes(1'b1),
    .data_out(data_mem_data)
  );

  register #(WIDTH) mdr_reg (
    .clk(clk), .rst(rst), .data_in(data_mem_data), .wr(mdr_write), .data_out(MDR)
  );

  // CONTROL UNIT
  control_multicycle control (
    .clk(clk), .rst(rst), .opcode(opcode),
    .pc_write(pc_write), .ir_write(ir_write), .reg_write(reg_write),
    .mem_read(mem_read), .mem_write(mem_write),
    .alu_src_a(alu_src_a), .alu_src_b(alu_src_b),
    .mem_to_reg(mem_to_reg),
    .aluout_write(aluout_write), .mdr_write(mdr_write),
    .alu_op(alu_op)
  );

endmodule
