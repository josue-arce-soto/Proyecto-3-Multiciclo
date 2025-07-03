// Register File: 32 registros de 32 bits para RV32I

module reg_file #(parameter WIDTH=32, parameter DEPTH=5) (
  input  logic             clk,
  input  logic             rst,
  input  logic [WIDTH-1:0] write_data,
  input  logic [DEPTH-1:0] write_register,
  input  logic             wr,
  input  logic [DEPTH-1:0] read_register_1,
  input  logic [DEPTH-1:0] read_register_2,
  input  logic             rd,
  output logic [WIDTH-1:0] read_data_1,
  output logic [WIDTH-1:0] read_data_2
);

  logic [WIDTH-1:0] registers [0:2**DEPTH-1];

  // Inicialización y escritura
  always_ff @(negedge clk or posedge rst) begin
    if (rst) begin
      for (int i = 0; i < 2**DEPTH; i++)
        registers[i] <= 0;
    end else if (wr && (write_register != 0)) begin
      registers[write_register] <= write_data;
    end
  end

  // Lectura combinacional
  always_comb begin
    if (rd) begin
      read_data_1 = (read_register_1 == 0) ? 0 : registers[read_register_1];
      read_data_2 = (read_register_2 == 0) ? 0 : registers[read_register_2];
    end else begin
      read_data_1 = 'hz;
      read_data_2 = 'hz;
    end
  end

endmodule