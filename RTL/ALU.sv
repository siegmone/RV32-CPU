`timescale 1ns / 1ps
module ALU (
    input logic SignedExt,
    input logic [31:0] A,
    B,
    input logic [3:0] ALUControl,
    output logic [31:0] Y,
    output logic Zero,
    Neg
);

  // ALUControl for basic instructions
  localparam logic [3:0] UNDEFINED = 4'bxxxx,  // undefined instruction
  ADD = 4'b0000,  // addition
  SUB = 4'b0010,  // subtraction
  XOR = 4'b0100,  // bitwise xor
  OR = 4'b0110,  // bitwise or
  AND = 4'b0111,  // bitwise and
  SLL = 4'b0001,  // shift left logic
  SRL = 4'b0101,  // shift right logic
  SRA = 4'b0011,  // shift right arithmetic
  CPB = 4'b1000;  // copy B

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
      SRA: logic_result = $signed(A) >>> B[4:0];
      CPB: logic_result = B;
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
      default:  Y = logic_result;
    endcase
    Zero = (Y == 32'b0) ? 1'b1 : 1'b0;
  end

endmodule

