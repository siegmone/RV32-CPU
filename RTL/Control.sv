`timescale 1ns / 1ps
// SCHEMATIC MODE 1
module Control (
    input logic [31:0] Instr,
    input logic Zero,
    Neg,
    output logic PCSrc,
    RegWrite,
    ALUSrc,
    MemWrite,
    ResultSrc,
    SignedExt,
    output logic [2:0] ALUControl,
    output logic [1:0] ImmSrc
);

  localparam logic [6:0] R_TYPE = 7'b0110011,
                         I_TYPE = 7'b0010011,
                         LW     = 7'b0000011,
                         SW     = 7'b0100011,
                         B_TYPE = 7'b1100011;

  // ALUControl for basic instructions
  localparam logic [2:0] ADD = 3'b000,
                         SUB = 3'b010,
                         XOR = 3'b100,
                         OR  = 3'b110,
                         AND = 3'b111,
                         SLL = 3'b001,
                         SRL = 3'b101,
                         SRA = 3'b011;

  // funct3 for branch instructions
  localparam logic [2:0] BEQ  = 3'b000,
                         BNE  = 3'b001,
                         BLT  = 3'b100,
                         BGE  = 3'b101,
                         BLTU = 3'b110,
                         BGEU = 3'b111;

  logic [6:0] Opcode;
  logic [2:0] funct3;
  logic f7;

  assign Opcode = Instr[6:0];
  assign funct3 = Instr[14:12];
  assign f7 = Instr[30];


  // control signals handling
  always_comb begin
    SignedExt = 1'b1;  // signed by default
    PCSrc = 1'b0;  // don't jump by default
    case (Opcode)
      R_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'bxx;
        ALUSrc = 1'b0;
        ResultSrc = 1'b0;
      end
      I_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'b00;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
      end
      LW: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'b00;
        ALUSrc = 1'b1;
        ResultSrc = 1'b1;
      end
      SW: begin  // S_type
        MemWrite = 1'b1;
        RegWrite = 1'b0;
        ImmSrc = 2'b01;
        ALUSrc = 1'b1;
        ResultSrc = 1'bx;
      end
      B_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b0;
        ImmSrc = 2'b10;
        ALUSrc = 1'b0;
        ResultSrc = 1'bx;
        case (funct3)
          BEQ: PCSrc = Zero;
          BNE: PCSrc = ~Zero;
          BLT: PCSrc = Neg;
          BGE: PCSrc = ~Neg;
          BLTU: begin
            PCSrc = Neg;
            SignedExt = 1'b0;
          end
          BGEU: begin
            PCSrc = ~Neg;
            SignedExt = 1'b0;
          end
          default: PCSrc = 1'b0;
        endcase
      end
      default: begin
        MemWrite = 1'bx;
        RegWrite = 1'bx;
        ImmSrc = 2'bxx;
        ALUSrc = 1'bx;
        ResultSrc = 1'bx;
        PCSrc = 1'bx;
        SignedExt = 1'bx;
      end
    endcase
  end

  // ALUControl handling
  always_comb begin
    case (Opcode)
      R_TYPE:
      case (funct3)
        3'b000:  ALUControl = (f7 == 1'b1) ? SUB : ADD;
        3'b101:  ALUControl = (f7 == 1'b1) ? SRL : SRA;
        default: ALUControl = funct3;
      endcase

      I_TYPE:
      case (funct3)
        3'b101:  ALUControl = (f7 == 1'b1) ? SRL : SRA;
        default: ALUControl = funct3;
      endcase

      LW: ALUControl = 3'b000;  // add

      SW: ALUControl = 3'b000;  // add

      B_TYPE: begin
        ALUControl = 3'b010;  // sub
      end

      default: ALUControl = 3'bxxx;
    endcase
  end

endmodule

