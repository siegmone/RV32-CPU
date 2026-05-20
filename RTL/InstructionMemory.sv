`timescale 1ns / 1ps

module InstructionMemory #(
    parameter FILE_NAME = "program.hex"
) (
    input  logic [31:0] A,
    output logic [31:0] RD
);
  localparam WORDS = 8192;  // 8K word
  logic [31:0] dati[0:WORDS-1];

  initial begin
    int count;
    count = WORDS;
    // legge il file di inizializzazione della memoria
    // e conta quante celle sono state effettivamente lette
    // Inizializza tutto a X (esplicito)
    for (int i = 0; i < WORDS; i++) dati[i] = 'x;
    // Carica il file
    $readmemh(FILE_NAME, dati);
    // Conta quante word sono state realmente lette
    for (int i = 0; i < WORDS; i++) begin
      if ($isunknown(dati[i])) begin
        count = i;
        break;
      end
    end
    $display("\n");
    $display("========================================================");
    $display(" InstructionMemory: letto il file %s", FILE_NAME);
    $display(" Istruzioni caricate: %0d", count);
    $display("========================================================");
    $display("\n");
  end

  //assign RD = dati[A[$clog2(WORDS)+1:2]];
  assign RD = dati[A[31:2]];

  // controllo di indirizzamento word-aligned
  always_comb begin
    if (A[1:0] != 2'b00) begin
      $display("\n");
      $display("========================================================");
      $display(" InstructionMemory: Errore: indirizzo dati non word-aligned.");
      $display(" Tempo: %0.3f ns; Indirizzo: %0d", $realtime / 1ns, A);
      $display("========================================================");
      $display("\n");
      $fatal(1, "Errore fatale in InstructionMemory.");
    end
  end

endmodule
