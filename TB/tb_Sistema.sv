`timescale 1ns / 1ps
// testbench complessivo del sistema
module tb_Sistema;

  parameter realtime CLK_PERIOD = 10ns;
  parameter integer N_TICKS = 30;  // numero di semiperiodi del clock da generare

  // array di byte per la stampa dell'istruzione in assembly
  parameter int MAX_ASCII = 64;
  logic [8*MAX_ASCII-1:0] asm_bus;


  // segnali del processore
  logic clk = 1'b0, rst;
  logic [31:0] PC, Instr;  // Interfaccia ROM
  logic [31:0] WriteData, ALUResult, ReadData;
  logic MemWrite;  // interfaccia RAM

  helper my_helper (.*);

  InstructionMemory #(
      .FILE_NAME("test.hex")
  ) myInstructionMemory (
      .A (PC),
      .RD(Instr)
  );
  Processor myProcessor (.*);
  DataMemory myDataMemory (
      .clk(clk),
      .WE (MemWrite),
      .A  (ALUResult),
      .WD (WriteData),
      .RD (ReadData)
  );

  // generazione del clock
  // dopo N_TICKS il clock si ferma e la simulazione termina
  initial begin
    repeat (N_TICKS) begin
      #(CLK_PERIOD / 2) clk = ~clk;
    end
    $display("\n");
    $display("----------------------------------------------------");
    $display("SIMULAZIONE TERMINATA.");
    $display("Simulati %0d cicli di clock.", N_TICKS / 2);
    $display("Il parametro NTICKS consente di modificare, se necessario, questo valore");
    $display("----------------------------------------------------");
    $display("\n");
  end

  // applico il reset nel periodo iniziale
  initial begin
    rst = 1'b1;
    #(CLK_PERIOD) rst = 1'b0;
  end

  // Stampa dell'istruzione eseguita a ogni ciclo di clock
  always @(posedge clk) begin
    #1ns;  // Attendiamo che i segnali siano stabili
    if (!rst) begin
      $display("[PC: 0x%h] %s", PC, asm_bus);
    end
  end

endmodule
