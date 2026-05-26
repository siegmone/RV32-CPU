`timescale 1ns / 1ps

module tb_RegisterFile;

  logic clk = 1'b0;
  logic WE3;
  logic [4:0] A1, A2, A3;
  logic [31:0] WD3;
  logic [31:0] RD1, RD2;

  int errori = 0;

  RegisterFile dut (.*);

  // Generazione del clock (periodo 10ns)
  always #5ns clk = ~clk;

  initial begin
    $display("--- INIZIO TEST REGISTER FILE ---");

    // --- RESET INIZIALE ---
    WE3 = 1'b0;
    A1  = 5'd0;
    A2  = 5'd0;
    A3  = 5'd0;
    WD3 = 32'd0;
    #10;

    // --- TEST 1: Lettura del registro x0 (Deve sempre restituire 0) ---
    A1 = 5'd0;
    #1;
    if (RD1 === 32'd0) $display("[OK] Lettura x0 iniziale");
    else begin
      $display("[ERR] x0 non è zero: RD1=%h", RD1);
      errori++;
    end

    // --- TEST 2: Scrittura e lettura sincrona su x5 ---
    A3  = 5'd5;
    WD3 = 32'hDEAD_BEEF;
    WE3 = 1'b1;
    @(posedge clk);
    #1;  // Aspetta il fronte di salita e la propagazione
    WE3 = 1'b0;  // Disabilita la scrittura
    A1  = 5'd5;
    #1;  // Leggi da x5
    if (RD1 === 32'hDEAD_BEEF) $display("[OK] Scrittura e Lettura x5");
    else begin
      $display("[ERR] Lettura x5: RD1=%h", RD1);
      errori++;
    end

    // --- TEST 3: Tentativo di scrittura su x0 (Deve rimanere 0) ---
    A3  = 5'd0;
    WD3 = 32'hFFFF_FFFF;
    WE3 = 1'b1;
    @(posedge clk);
    #1;
    WE3 = 1'b0;
    A1  = 5'd0;
    #1;
    if (RD1 === 32'd0) $display("[OK] Scrittura inibita su x0");
    else begin
      $display("[ERR] x0 è stato sovrascritto! RD1=%h", RD1);
      errori++;
    end

    // --- TEST 4: Scrittura con WE3 disattivato (Non deve scrivere) ---
    A3  = 5'd10;
    WD3 = 32'h1234_5678;
    WE3 = 1'b0;  // WE3 disattivato
    @(posedge clk);
    #1;
    A1 = 5'd10;
    #1;
    if (RD1 !== 32'h1234_5678) $display("[OK] WE3=0 blocca scrittura");
    else begin
      $display("[ERR] Scrittura avvenuta anche con WE3=0");
      errori++;
    end

    // --- TEST 5: Lettura simultanea di due porte diverse (x5 e un registro vuoto x10) ---
    A1 = 5'd5;
    A2 = 5'd10;
    #1;
    if (RD1 === 32'hDEAD_BEEF && RD2 !== 32'h1234_5678)
      $display("[OK] Lettura simultanea RD1 e RD2");
    else begin
      $display("[ERR] Lettura simultanea: RD1=%h RD2=%h", RD1, RD2);
      errori++;
    end

    // --- FINALE ---
    $display("----------------------------------------------------");
    $display("TEST RF TERMINATI. Errori totali riscontrati: %0d", errori);
    $display("----------------------------------------------------");
    $finish;
  end

endmodule
