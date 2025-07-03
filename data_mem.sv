// Data Memory for RV32I (byte-addressable)


module data_mem #(parameter WIDTH=32, parameter DEPTH=20) (
  input  logic              clk,
  input  logic              rst,
  input  logic [WIDTH-1:0]  data_in,
  input  logic [DEPTH-1:0]  addr,
  input  logic              wr,
  input  logic              rd,
  input  logic              one_byte,     // lb, sb
  input  logic              two_bytes,    // lh, sh
  input  logic              four_bytes,   // lw, sw
  output logic [WIDTH-1:0]  data_out
);

  logic [7:0] memory [0:(2**DEPTH)-1];

  // Reset y escritura sincrónica (flanco de bajada)
  always_ff @(negedge clk) begin
    if (rst) begin
      for (int i = 0; i < 2**DEPTH; i++)
        memory[i] <= 8'b0;
    end else if (wr) begin
      case (1'b1)
        one_byte: begin
          memory[addr] <= data_in[7:0];
        end
        two_bytes: begin
          memory[addr]     <= data_in[7:0];
          memory[addr + 1] <= data_in[15:8];
        end
        four_bytes: begin
          memory[addr]     <= data_in[7:0];
          memory[addr + 1] <= data_in[15:8];
          memory[addr + 2] <= data_in[23:16];
          memory[addr + 3] <= data_in[31:24];
        end
        default: ; // nada
      endcase
    end
  end

  // Lectura combinacional (little-endian)
  always_comb begin
    if (rd) begin
      case (1'b1)
        one_byte:   data_out = {24'b0, memory[addr]};
        two_bytes:  data_out = {16'b0, memory[addr + 1], memory[addr]};
        four_bytes: data_out = {memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};
        default:    data_out = 32'b0;
      endcase
    end else begin
      data_out = 32'bz; 
  end

endmodule