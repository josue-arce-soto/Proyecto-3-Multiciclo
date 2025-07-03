`timescale 1ns/1ps

module top_tb;

  logic clk;
  logic rst;

  top dut (
    .clk(clk),
    .rst(rst)
  );

  // Clock: periodo de 10 ns
  always #5 clk = ~clk;

  initial begin
    $display("Cargando programa desde program.mem...");
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);

    clk = 0;
    rst = 1;
    #20 rst = 0;

    // Tiempo total: suficiente para al menos 3 instrucciones multiciclo
    #300;

    $display("\n== RESULTADOS ==");

    $display("x1 = %0d (esperado: 5)",  dut.rf.registers[1]);
    $display("x2 = %0d (esperado: 10)", dut.rf.registers[2]);
    $display("x3 = %0d (esperado: 15)", dut.rf.registers[3]);

    if (dut.rf.registers[1] !== 5)   $display("❌ Error en x1");
    if (dut.rf.registers[2] !== 10)  $display("❌ Error en x2");
    if (dut.rf.registers[3] !== 15)  $display("❌ Error en x3");

    $finish;
  end

  // Monitoreo cada flanco positivo de reloj
  always @(posedge clk) begin
    $display(
      "[%0t] PC=%h IR=%h | A=%0d B=%0d Imm=%0d ALU=%0d ALUOut=%0d MDR=%0d",
      $time, dut.PC, dut.IR, dut.A, dut.B, dut.Imm,
      dut.ALUResult, dut.ALUOut, dut.MDR
    );
  end

endmodule