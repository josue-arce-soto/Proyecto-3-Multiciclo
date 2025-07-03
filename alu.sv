// ALU: Arithmetic Logic Unit for RV32I

module alu #(parameter WIDTH=32) (
  input  logic [WIDTH-1:0] data_in_1,
  input  logic [WIDTH-1:0] data_in_2,
  input  logic [2:0]       func3,
  input  logic [6:0]       func7,
  input  logic [6:0]       opcode,

  output logic [WIDTH-1:0] data_out,
  output logic             zero,
  output logic             comparison
);

  // Opcodes
  localparam ALI_OP    = 7'b0010011;
  localparam AL_OP     = 7'b0110011;
  localparam MEM_WR_OP = 7'b0100011;
  localparam MEM_RD_OP = 7'b0000011;
  localparam BR_OP     = 7'b1100011;
  localparam JALR      = 7'b1100111;
  localparam LUI       = 7'b0110111;
  localparam AUIPC     = 7'b0010111;

  always_comb begin
    data_out   = 0;
    comparison = 0;

    case (opcode)
      ALI_OP: begin
        case (func3)
          3'b000: data_out = signed'(data_in_1) + signed'(data_in_2);     // addi
          3'b001: data_out = data_in_1 << data_in_2[4:0];                 // slli
          3'b010: data_out = (signed'(data_in_1) < signed'(data_in_2));  // slti
          3'b011: data_out = (data_in_1 < data_in_2);                    // sltiu
          3'b100: data_out = data_in_1 ^ data_in_2;                      // xori
          3'b101: data_out = (func7 == 7'b0100000) ?
                             (signed'(data_in_1) >>> data_in_2[4:0]) :    // srai
                             (data_in_1 >> data_in_2[4:0]);              // srli
          3'b110: data_out = data_in_1 | data_in_2;                      // ori
          3'b111: data_out = data_in_1 & data_in_2;                      // andi
        endcase
      end

      AL_OP: begin
        case (func3)
          3'b000: data_out = (func7 == 7'b0100000) ?
                             (data_in_1 - data_in_2) :                   // sub
                             (data_in_1 + data_in_2);                    // add
          3'b001: data_out = data_in_1 << data_in_2[4:0];                // sll
          3'b010: data_out = (signed'(data_in_1) < signed'(data_in_2));  // slt
          3'b011: data_out = (data_in_1 < data_in_2);                    // sltu
          3'b100: data_out = data_in_1 ^ data_in_2;                      // xor
          3'b101: data_out = (func7 == 7'b0100000) ?
                             (signed'(data_in_1) >>> data_in_2[4:0]) :   // sra
                             (data_in_1 >> data_in_2[4:0]);              // srl
          3'b110: data_out = data_in_1 | data_in_2;                      // or
          3'b111: data_out = data_in_1 & data_in_2;                      // and
        endcase
      end

      MEM_WR_OP, MEM_RD_OP, JALR, AUIPC: begin
        data_out = data_in_1 + data_in_2;                                // dirección efectiva
      end

      LUI: begin
        data_out = data_in_2;                                            // valor inmediato directo
      end

      BR_OP: begin
        case (func3)
          3'b000: comparison = (data_in_1 == data_in_2);                 // beq
          3'b001: comparison = (data_in_1 != data_in_2);                 // bne
          3'b100: comparison = (signed'(data_in_1) <  signed'(data_in_2)); // blt
          3'b101: comparison = (signed'(data_in_1) >= signed'(data_in_2)); // bge
          3'b110: comparison = (data_in_1 <  data_in_2);                 // bltu
          3'b111: comparison = (data_in_1 >= data_in_2);                 // bgeu
        endcase
        data_out = 0; // prevenir latch
      end

      default: begin
        data_out = 0;
        comparison = 0;
      end
    endcase
  end

  assign zero = (data_out == 0);

endmodule