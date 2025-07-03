// Instruction Memory File: Instruction Memory

module inst_mem #(parameter WIDTH=32, parameter DEPTH=16) (

  input logic               clk,
  input logic               rst,
  input logic [WIDTH-1:0]   data_in,  
  input logic [DEPTH-1:0]   addr,
  input logic               wr,    
  input logic               rd,

  output logic [WIDTH-1:0]  data_out
);

  logic [7:0] memory [2**DEPTH];

  // Solo lectura inicial desde archivo
  initial begin
    $display("Cargando programa desde program.mem...");
    $readmemh("program.mem", memory);
  end

  // Lectura combinacional
  always_comb begin
    if (rd) begin
      data_out = {memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};
    end else begin
      data_out = 32'bz;
    end
  end

endmodule