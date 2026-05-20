`timescale 1ns / 1ps
module tb_DataMemory;

  logic clk, WE;
  logic [31:0] A, WD, RD;

  DataMemory dut (.*);

  initial begin
    clk = 0;
    repeat (100) begin
      #5ns clk = ~clk;
    end
  end

  initial begin
    WE = 1;
    for (int unsigned i = 0; i < 32; i++) begin
      A  = 4 * i;  // indirizzo word-aligned
      WD = i * 10;
      #10ns;
    end
    // Ora leggo quanto scritto
    WE = 0;
    for (int unsigned i = 1; i < 32; i++) begin
      A = 4 * i;
      #0.2ns;
      assert (RD === i * 10)
      else $fatal(1, "Read data mismatch. Address: %d", A);
    end

    $display("------------------------------------------------");
    $display("Test DataMemory superato");
    $display("------------------------------------------------");

    $finish;

  end

endmodule

