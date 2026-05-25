`timescale 1ns / 1ps
module ALU (
    input logic SignedExt,
    input logic [31:0] A,
    B,
    input logic [2:0] ALUControl,
    output logic [31:0] Y,
    output logic Zero,
    Neg
);

  // ALUControl for basic instructions
  localparam logic [2:0] ADD = 3'b000,
                         SUB = 3'b010,
                         XOR = 3'b100,
                         OR  = 3'b110,
                         AND = 3'b111,
                         SLL = 3'b001,
                         SRL = 3'b101,
                         SRA = 3'b011;

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
      // xor: bit-wise xor
      XOR:  logic_result = A ^ B;
      // or:  bit-wise or
      OR:   logic_result = A | B;
      // and: bit-wise and
      AND:  logic_result = A & B;
      // sll: logical left shift
      SLL:  logic_result = A << B[4:0];
      // srl: logical right shift
      SRL:  logic_result = A >> B[4:0];
      // sra: arithmetic right shift
      SRA:  logic_result = $signed(A) >>> B[4:0];
      default: ;
    endcase
  end

  // arithmetic
  always_comb begin
    arith_result = 32'b0;
    sub_ext = A_ext - B_ext;
    case (ALUControl)
      // add & addi: addition
      ADD:  arith_result = A + B;
      // sub & subi: subtraction
      SUB:  arith_result = sub_ext[31:0];
      default: ;
    endcase
    Neg = sub_ext[32];
  end

  // final mux
  always_comb begin
    case (ALUControl)
      // use arithmetic unit result
      ADD, SUB: Y = arith_result;
      // else use logic unit result
      default: Y = logic_result;
    endcase
    Zero = (Y == 32'b0) ? 1'b1 : 1'b0;
  end

endmodule

