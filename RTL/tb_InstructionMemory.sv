`timescale 1ns / 1ps

module tb_InstructionMemory;

  logic [31:0] A;
  logic [31:0] RD;

  //InstructionMemory  uut  (.*);
  InstructionMemory #(.FILE_NAME("program.txt")) uut (.*);

  initial begin
    $display("Stampa delle prime 16 istruzioni lette dal file 'program.txt' ");
    for (int unsigned i = 0; i < 64; i = i + 4) begin
      A = i;
      #1ns;
      $display("Indice: %d  Dato: %h", i, RD);
    end

    $display("\n Provo ad accedere ad un indirizzo non word-aligned");
    $display(" Questo dovrebbe produrre un errore fatale.");

    A = 32'd27;
    #1ns;
    $display("Indice: %d  Dato: %h", 27, RD);
    $finish;
  end

endmodule
