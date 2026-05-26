`timescale 1ns / 1ps

module tb_ALU;

  logic SignedExt;
  logic [31:0] A, B;
  logic [ 4:0] ALUControl;
  logic [31:0] Y;
  logic Zero, Neg;

  // ALUControl for basic instructions
  // distinction based on MSB:
  // MSB = 1 -> arithmetic operation
  // MSB = 0 -> logic operation
  localparam logic [4:0] UNDEFINED = 5'bxxxxx,
                         ADD       = 5'b10000,
                         SUB       = 5'b10010,
                         MUL       = 5'b10100,
                         MULH      = 5'b10101,
                         MULHSU    = 5'b10110,
                         MULHU     = 5'b10111,
                         DIV       = 5'b11000,
                         DIVU      = 5'b11001,
                         REM       = 5'b11010,
                         REMU      = 5'b11011,
                         CPB       = 5'b00000,
                         SLL       = 5'b00001,
                         SRA       = 5'b00010,
                         SRL       = 5'b00011,
                         SLT       = 5'b00100,
                         SLTU      = 5'b00101,
                         AND       = 5'b01000,
                         XOR       = 5'b01001,
                         OR        = 5'b01010;

  int errori = 0;

  ALU dut (.*);

  initial begin
    $display("--- TEST ALU ---");

    // --- OPERAZIONI ARITMETICHE (MSB = 1) ---

    // ADD
    A = 32'd20;
    B = 32'd10;
    ALUControl = ADD;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd30 && Zero === 1'b0 && Neg === 1'b0) $display("[OK] ADD");
    else begin
      $display("[ERR] ADD: Y=%d Z=%b N=%b", Y, Zero, Neg);
      errori++;
    end

    // SUB (Risultato Positive)
    A = 32'd20;
    B = 32'd10;
    ALUControl = SUB;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd10 && Zero === 1'b0 && Neg === 1'b0) $display("[OK] SUB Positive");
    else begin
      $display("[ERR] SUB Positive: Y=%d Z=%b N=%b", Y, Zero, Neg);
      errori++;
    end

    // SUB (Risultato Negative Signed)
    A = 32'd10;
    B = 32'd20;
    ALUControl = SUB;
    SignedExt = 1'b1;
    #10;
    if (Y === -32'd10 && Zero === 1'b0 && Neg === 1'b1) $display("[OK] SUB Negative Signed");
    else begin
      $display("[ERR] SUB Negative Signed: Y=%d Z=%b N=%b", Y, Zero, Neg);
      errori++;
    end

    // SUB (Caso BLTU Unsigned: 5 < Max Unsigned)
    A = 32'd5;
    B = 32'hFFFFFFFF;
    ALUControl = SUB;
    SignedExt = 1'b0;
    #10;
    if (Neg === 1'b1 && Zero === 1'b0) $display("[OK] SUB BLTU Unsigned");
    else begin
      $display("[ERR] SUB BLTU Unsigned: Z=%b N=%b", Zero, Neg);
      errori++;
    end

    // MUL
    A = 32'd6;
    B = 32'd5;
    ALUControl = MUL;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd30) $display("[OK] MUL");
    else begin
      $display("[ERR] MUL: Y=%d", Y);
      errori++;
    end

    // MULH
    A = 32'h7FFFFFFF;
    B = 32'd2;
    ALUControl = MULH;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd0) $display("[OK] MULH");
    else begin
      $display("[ERR] MULH: Y=%h", Y);
      errori++;
    end

    // MULHSU
    A = -32'd2;
    B = 32'd2;
    ALUControl = MULHSU;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'hFFFFFFFF) $display("[OK] MULHSU");
    else begin
      $display("[ERR] MULHSU: Y=%h", Y);
      errori++;
    end

    // MULHU
    A = 32'hFFFFFFFF;
    B = 32'd2;
    ALUControl = MULHU;
    SignedExt = 1'b0;
    #10;
    if (Y === 32'd1) $display("[OK] MULHU");
    else begin
      $display("[ERR] MULHU: Y=%h", Y);
      errori++;
    end

    // DIV
    A = 32'd20;
    B = 32'd5;
    ALUControl = DIV;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd4) $display("[OK] DIV");
    else begin
      $display("[ERR] DIV: Y=%d", Y);
      errori++;
    end

    // DIV per Zero
    A = 32'd20;
    B = 32'd0;
    ALUControl = DIV;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'hFFFFFFFF) $display("[OK] DIV Zero");
    else begin
      $display("[ERR] DIV Zero: Y=%h", Y);
      errori++;
    end

    // DIVU
    A = 32'd40;
    B = 32'd2;
    ALUControl = DIVU;
    SignedExt = 1'b0;
    #10;
    if (Y === 32'd20) $display("[OK] DIVU");
    else begin
      $display("[ERR] DIVU: Y=%d", Y);
      errori++;
    end

    // REM
    A = 32'd22;
    B = 32'd5;
    ALUControl = REM;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd2) $display("[OK] REM");
    else begin
      $display("[ERR] REM: Y=%d", Y);
      errori++;
    end

    // REM per Zero
    A = 32'd22;
    B = 32'd0;
    ALUControl = REM;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd22) $display("[OK] REM Zero");
    else begin
      $display("[ERR] REM Zero: Y=%d", Y);
      errori++;
    end

    // REMU
    A = 32'd43;
    B = 32'd10;
    ALUControl = REMU;
    SignedExt = 1'b0;
    #10;
    if (Y === 32'd3) $display("[OK] REMU");
    else begin
      $display("[ERR] REMU: Y=%d", Y);
      errori++;
    end


    // --- OPERAZIONI LOGICHE (MSB = 0) ---

    // CPB
    A = 32'hAAAA_AAAA;
    B = 32'h5555_5555;
    ALUControl = CPB;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'h5555_5555) $display("[OK] CPB");
    else begin
      $display("[ERR] CPB: Y=%h", Y);
      errori++;
    end

    // SLL
    A = 32'd1;
    B = 32'd4;
    ALUControl = SLL;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd16) $display("[OK] SLL");
    else begin
      $display("[ERR] SLL: Y=%d", Y);
      errori++;
    end

    // SRA (Estensione del segno)
    A = 32'h8000_0000;
    B = 32'd1;
    ALUControl = SRA;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'hC000_0000) $display("[OK] SRA");
    else begin
      $display("[ERR] SRA: Y=%h", Y);
      errori++;
    end

    // SRL (Inserimento zeri)
    A = 32'h8000_0000;
    B = 32'd1;
    ALUControl = SRL;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'h4000_0000) $display("[OK] SRL");
    else begin
      $display("[ERR] SRL: Y=%h", Y);
      errori++;
    end

    // SLT (True: -5 < 2)
    A = -32'd5;
    B = 32'd2;
    ALUControl = SLT;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'd1) $display("[OK] SLT True");
    else begin
      $display("[ERR] SLT True: Y=%d", Y);
      errori++;
    end

    // SLTU (False: Max Unsigned non è minore di 2)
    A = 32'hFFFFFFFF;
    B = 32'd2;
    ALUControl = SLTU;
    SignedExt = 1'b0;
    #10;
    if (Y === 32'd0) $display("[OK] SLTU False");
    else begin
      $display("[ERR] SLTU False: Y=%d", Y);
      errori++;
    end

    // AND
    A = 32'hFFFF_0000;
    B = 32'hF0F0_F0F0;
    ALUControl = AND;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'hF0F0_0000) $display("[OK] AND");
    else begin
      $display("[ERR] AND: Y=%h", Y);
      errori++;
    end

    // XOR
    A = 32'hFFFF_0000;
    B = 32'hF0F0_F0F0;
    ALUControl = XOR;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'h0F0F_F0F0) $display("[OK] XOR");
    else begin
      $display("[ERR] XOR: Y=%h", Y);
      errori++;
    end

    // OR
    A = 32'hFFFF_0000;
    B = 32'hF0F0_F0F0;
    ALUControl = OR;
    SignedExt = 1'b1;
    #10;
    if (Y === 32'hFFFF_F0F0) $display("[OK] OR");
    else begin
      $display("[ERR] OR: Y=%h", Y);
      errori++;
    end

    // --- FINALE ---
    $display("----------------------------------------------------");
    $display("TEST ALU END. Total Errors: %0d", errori);
    $display("----------------------------------------------------");
    $finish;
  end

endmodule
