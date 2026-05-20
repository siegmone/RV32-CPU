`timescale 1ns / 1ps
module DataMemory (
    input logic clk,
    WE,
    input logic [31:0] A,
    input logic [31:0] WD,
    output logic [31:0] RD
);

  localparam unsigned MAX_RAM = 8192;  // 8K word
  logic [31:0] ram[MAX_RAM-1:0];  // massimo MAX_RAM word in memoria

  always_ff @(posedge clk) begin
    if (WE) begin
      ram[A[31:2]] <= WD;
    end
  end

  assign RD = ram[A[31:2]];

  // Controllo di indirizzamento word-aligned e tentativo di accesso fuori memoria
  // IMPOSSIBILE
  //  in quanto il bus indirizzo è collegato all'uscita della ALU, che
  //  può assumere qualsiasi valore quando non si legge dalla memoria.

endmodule

