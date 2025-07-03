// Immediate Generator for RISC-V RV32I

module imm_gen #(parameter WIDTH=32) (
  input  logic [WIDTH-1:0] instr,
  output logic [WIDTH-1:0] data_out
);

  // Tipos de instrucciones por opcode
  localparam ALI_OP    = 7'b0010011; // I-type (aritmética inmediata)
  localparam MEM_RD_OP = 7'b0000011; // I-type (load)
  localparam JALR      = 7'b1100111; // I-type (jalr)
  localparam MEM_WR_OP = 7'b0100011; // S-type (store)
  localparam BR_OP     = 7'b1100011; // B-type (branch)
  localparam JAL       = 7'b1101111; // J-type
  localparam LUI       = 7'b0110111; // U-type
  localparam AUIPC     = 7'b0010111; // U-type

  logic [6:0] opcode;

  assign opcode = instr[6:0];

  always_comb begin
    logic [2:0] func3; // LOCAL
    func3 = instr[14:12];

    case (opcode)
      // I-type: aritmética o load
      ALI_OP: begin
        case (func3)
          3'b001, 3'b101: data_out = {27'b0, instr[24:20]}; // slli, srli, srai (zero-extended)
          default:        data_out = {{20{instr[31]}}, instr[31:20]}; // sign-extended
        endcase
      end
      MEM_RD_OP, JALR: begin
        data_out = {{20{instr[31]}}, instr[31:20]};
      end

      // S-type
      MEM_WR_OP: begin
        data_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end

      // B-type
      BR_OP: begin
        data_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      end

      // J-type
      JAL: begin
        data_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      end

      // U-type
      LUI, AUIPC: begin
        data_out = {instr[31:12], 12'b0};
      end

      default: data_out = 32'b0;
    endcase
  end

endmodule
