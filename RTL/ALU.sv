`timescale 1ns / 1ps
module ALU (
    input logic [31:0] A,
    B,
    input logic [2:0] ALUControl,
    output logic [31:0] Y,
    output logic Zero
);


  logic [31:0] logic_result;
  logic [31:0] arith_result;

  // logic
  always_comb begin
    logic_result = 32'b0;
    case (ALUControl)
      // xor: bit-wise xor
      3'b100:  logic_result = A ^ B;
      // or:  bit-wise or
      3'b110:  logic_result = A | B;
      // and: bit-wise and
      3'b111:  logic_result = A & B;
      // sll: logical left shift
      3'b001:  logic_result = A << B[4:0];
      // srl: logical right shift
      3'b011:  logic_result = A >> B[4:0];
      // sra: arithmetic right shift
      3'b101:  logic_result = $signed(A) >>> B[4:0];
      default: ;
    endcase
  end

  // arithmetic
  always_comb begin
    arith_result = 32'b0;
    case (ALUControl)
      // add & addi: addition
      3'b000:  arith_result = A + B;
      // sub & subi: subtraction
      3'b010:  arith_result = A - B;
      default: ;
    endcase
  end

  // final mux
  always_comb begin
    case (ALUControl)
      // use arithmetic unit result
      3'b000, 3'b010: Y = arith_result;
      // else use logic unit result
      default: Y = logic_result;
    endcase
    Zero = (Y == 32'b0) ? 1'b1 : 1'b0;
  end

endmodule

