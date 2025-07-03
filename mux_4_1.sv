// Mux 4x1: Multiplexor parametrizable

module mux_4_1 #(parameter WIDTH = 32) (
  input  logic [WIDTH-1:0] A,
  input  logic [WIDTH-1:0] B,
  input  logic [WIDTH-1:0] C,
  input  logic [WIDTH-1:0] D,
  input  logic [1:0]       sel,
  output logic [WIDTH-1:0] out
);

  always_comb begin
    case (sel)
      2'b00: out = A;
      2'b01: out = B;
      2'b10: out = C;
      2'b11: out = D;
      default: out = '0;
    endcase
  end

endmodule