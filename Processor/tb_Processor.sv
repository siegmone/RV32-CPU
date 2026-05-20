`timescale 1ns / 1ps
// testbench complessivo del sistema
module tb_Processore;

  parameter realtime CLK_PERIOD = 10ns;
  parameter N_TICKS = 40;  // numero di semiperiodi del clock da generare

  // segnali del processore
  logic clk = 1'b0, rst;
  logic [31:0] PC, Instr;  // Interfaccia ROM
  logic [31:0] WriteData, ALUResult, ReadData;
  logic MemWrite;  // interfaccia RAM

  Processor myProcessor (.*);

  // generazione del clock
  // dopo N_TICKS il clock si ferma e la simulazione termina
  initial begin
    repeat (N_TICKS) begin
      #(CLK_PERIOD / 2) clk = ~clk;
    end
  end

  // applico il reset nel periodo iniziale
  initial begin
    rst = 1'b1;
    #(CLK_PERIOD) rst = 1'b0;
  end

  // monitoraggio dei segnali
  initial begin
    int i;
    i = 0;
    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h00900293;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000000) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    // no WriteData
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", PC, i);
    if (ALUResult !== 32'h00000009)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);

    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h02928313;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000004) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    // no WriteData
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000032)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);

    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h006283b3;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000008) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    if (WriteData !== 32'h00000032)
      $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h0000003b)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);

    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h01000a13;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h0000000c) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    // if (WriteData !== 32'h00000032) $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000010)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h007a2423;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000010) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    if (WriteData !== 32'h0000003b)
      $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b1) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000018)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h008a2e03;
    ReadData = 32'h0000003b;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000014) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    //if (WriteData !== 32'h0000003b) $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000018)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h03b00413;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000018) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    //if (WriteData !== 32'h0000003b) $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h0000003b)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;  // clock 8
    Instr = 32'h008e0463;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h0000001c) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    if (WriteData !== 32'h0000003b)
      $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000000)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'h00000013;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000024) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    if (WriteData !== 32'h00000000)
      $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000000)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);


    @(posedge clk);
    #1ns;
    i++;
    Instr = 32'hfe000ee3;
    #(CLK_PERIOD - 1ns);
    if (PC !== 32'h00000028) $display("       !ERRORE! PC=%h  clock %0d", PC, i);
    if (WriteData !== 32'h00000000)
      $display("       !ERRORE! WriteData=%b  clock %0d", WriteData, i);
    if (MemWrite !== 1'b0) $display("       !ERRORE! MemWrite=%b  clock %0d", MemWrite, i);
    if (ALUResult !== 32'h00000000)
      $display("       !ERRORE! ALUResult=%h  clock %0d", ALUResult, i);

    $display("----------------------------------------------------");
    $display("-----------------FINE CONTROLLI---------------------");
    $display("----------------------------------------------------");
  end

endmodule
