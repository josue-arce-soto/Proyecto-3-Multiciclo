module control_multicycle (
  input  logic       clk,
  input  logic       rst,
  input  logic [6:0] opcode,

  output logic       pc_write,
  output logic       ir_write,
  output logic       reg_write,
  output logic       mem_read,
  output logic       mem_write,
  output logic       alu_src_a,
  output logic       alu_src_b,
  output logic       mem_to_reg,
  output logic       aluout_write,
  output logic       mdr_write,
  output logic [1:0] alu_op
);

  typedef enum logic [3:0] {
    IFETCH         = 4'd0,
    IDECODE        = 4'd1,
    EXECUTE        = 4'd2,
    ALU_WRITE      = 4'd3,
    MEMACCESS      = 4'd4,
    MEM_READ_WAIT  = 4'd5,
    WRITEBACK      = 4'd6,
    REG_WRITE_WAIT = 4'd7,
    BRANCH         = 4'd8,
    JUMP           = 4'd9
  } state_t;

  state_t state, next_state;

  localparam [6:0] ALU_IMM  = 7'b0010011;
  localparam [6:0] ALU_REG  = 7'b0110011;
  localparam [6:0] LOAD     = 7'b0000011;
  localparam [6:0] STORE    = 7'b0100011;
  localparam [6:0] BRANCHOP = 7'b1100011;
  localparam [6:0] JAL      = 7'b1101111;
  localparam [6:0] JALR     = 7'b1100111;

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      state <= IFETCH;
    else
      state <= next_state;
  end

  always_comb begin
    case (state)
      IFETCH:    next_state = IDECODE;
      IDECODE: begin
        case (opcode)
          ALU_IMM, ALU_REG,
          LOAD, STORE: next_state = EXECUTE;
          BRANCHOP:    next_state = BRANCH;
          JAL, JALR:   next_state = JUMP;
          default:     next_state = IFETCH;
        endcase
      end
      EXECUTE: begin
        case (opcode)
          ALU_IMM, ALU_REG, LOAD, STORE: next_state = ALU_WRITE;
          default: next_state = IFETCH;
        endcase
      end
      ALU_WRITE: begin
        case (opcode)
          LOAD:     next_state = MEMACCESS;
          STORE:    next_state = MEMACCESS;
          default:  next_state = REG_WRITE_WAIT;
        endcase
      end
      MEMACCESS: begin
        if (opcode == LOAD)
          next_state = MEM_READ_WAIT;
        else
          next_state = IFETCH;
      end
      MEM_READ_WAIT: next_state = WRITEBACK;
      WRITEBACK:     next_state = IFETCH;
      REG_WRITE_WAIT:next_state = WRITEBACK;
      BRANCH:        next_state = IFETCH;
      JUMP:          next_state = IFETCH;
      default:       next_state = IFETCH;
    endcase
  end

  always_comb begin
    // Defaults
    pc_write     = 0;
    ir_write     = 0;
    reg_write    = 0;
    mem_read     = 0;
    mem_write    = 0;
    alu_src_a    = 0;
    alu_src_b    = 0;
    mem_to_reg   = 0;
    alu_op       = 2'b00;
    aluout_write = 0;
    mdr_write    = 0;

    case (state)
      IFETCH: begin
        pc_write  = 1;
        ir_write  = 1;
        alu_src_a = 0;
        alu_src_b = 1;
        alu_op    = 2'b00;
      end
      IDECODE: begin
        alu_src_a = 0;
        alu_src_b = 1;
        alu_op    = 2'b00;
      end
      EXECUTE: begin
        alu_src_a = 1;
        alu_src_b = (opcode == ALU_REG) ? 0 : 1;
        alu_op    = 2'b10;
      end
      ALU_WRITE: begin
        aluout_write = 1;
      end
      MEMACCESS: begin
        if (opcode == LOAD) begin
          mem_read = 1;
        end else begin
          mem_write = 1;
        end
      end
      MEM_READ_WAIT: begin
        mdr_write = 1;
      end
      WRITEBACK: begin
        reg_write  = 1;
        mem_to_reg = (opcode == LOAD);
      end
      REG_WRITE_WAIT: begin

      end
      BRANCH: begin
        alu_src_a = 1;
        alu_src_b = 0;
        alu_op    = 2'b01;
        pc_write  = 1;
      end
      JUMP: begin
        pc_write  = 1;
        reg_write = 1;
      end
    endcase
  end

endmodule