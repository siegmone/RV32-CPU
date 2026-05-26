`timescale 1ns / 1ps
module ALU (
    input logic SignedExt,
    input logic [31:0] A,
    B,
    input logic [4:0] ALUControl,
    output logic [31:0] Y,
    output logic Zero,
    Neg
);

  // ALUControl for basic instructions
  localparam logic [4:0] UNDEFINED = 5'bxxxxx,
                         ADD       = 5'b00000,
                         SUB       = 5'b00010,
                         XOR       = 5'b00100,
                         OR        = 5'b00110,
                         AND       = 5'b00111,
                         SLL       = 5'b00001,
                         SRA       = 5'b00011,
                         SRL       = 5'b00101,
                         SLT       = 5'b01001,
                         SLTU      = 5'b01010,
                         MUL       = 5'b10000,
                         MULH      = 5'b10001,
                         MULHSU    = 5'b10010,
                         MULHU     = 5'b10011,
                         DIV       = 5'b10100,
                         DIVU      = 5'b10101,
                         REM       = 5'b10110,
                         REMU      = 5'b10111,
                         CPB       = 5'b01000;

  // logic and arith buses
  logic [31:0] logic_result;
  logic [31:0] arith_result;

  // extended buses
  logic [32:0] A_ext, B_ext;
  logic [32:0] sub_ext;

  assign A_ext[31:0] = A;
  assign B_ext[31:0] = B;

  // extend with or without sign bit
  always_comb begin
    if (SignedExt == 1) begin
      A_ext[32] = A[31];
      B_ext[32] = B[31];
    end else begin
      A_ext[32] = 1'b0;
      B_ext[32] = 1'b0;
    end
  end

  // logic
  always_comb begin
    logic_result = 32'b0;
    case (ALUControl)
      XOR: logic_result = A ^ B;
      OR: logic_result = A | B;
      AND: logic_result = A & B;
      SLL: logic_result = A << B[4:0];
      SRL: logic_result = A >> B[4:0];
      SRA: logic_result = signed'(A) >>> B[4:0];
      CPB: logic_result = B;
      SLT: logic_result = (signed'(A) < signed'(B)) ? 32'd1 : 32'd0;
      SLTU: logic_result = (Neg == 1'b1) ? 32'd1 : 32'd0;
      default: ;
    endcase
  end

  // arithmetic
  always_comb begin
    arith_result = 32'b0;
    sub_ext = A_ext - B_ext;
    case (ALUControl)
      ADD: arith_result = A + B;
      SUB: arith_result = sub_ext[31:0];
      MUL: arith_result = A * B;
      MULH: arith_result = (64'(signed'(A)) * 64'(signed'(B))) >>> 32;
      MULHSU: arith_result = (64'(signed'(A)) * 64'(B)) >>> 32;
      MULHU: arith_result = (64'(A) * 64'(B)) >>> 32;
      DIV: begin
        if (B == 32'b0) arith_result = 32'hffffffff;
        else arith_result = signed'(A) / signed'(B);
      end
      DIVU: begin
        if (B == 32'b0) arith_result = 32'hffffffff;
        else arith_result = A / B;
      end
      REM: begin
        if (B == 32'b0) arith_result = A;
        else arith_result = signed'(A) % signed'(B);
      end
      REMU: begin
        if (B == 32'b0) arith_result = A;
        else arith_result = A % B;
      end
      default: ;
    endcase
    Neg = sub_ext[32];
  end

  // final mux
  always_comb begin
    case (ALUControl)
      // use arithmetic unit result
      ADD, SUB, MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU: Y = arith_result;
      // else use logic unit result
      default: Y = logic_result;
    endcase
    Zero = (Y == 32'b0) ? 1'b1 : 1'b0;
  end

endmodule

