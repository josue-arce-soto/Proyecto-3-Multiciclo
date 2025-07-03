// Mux 2x1: Multiplexor parametrizable

module mux_2_1 #(parameter WIDTH = 32) (
  input  logic [WIDTH-1:0] A,
  input  logic [WIDTH-1:0] B,
  input  logic             sel,
  output logic [WIDTH-1:0] out
);

  always_comb begin
    out = (sel == 1'b0) ? A : B;
  end

endmodule