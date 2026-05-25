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
    PCSave,
    PCJumpSrc,
    output logic [3:0] ALUControl,
    output logic [2:0] ImmSrc
);

  // opcodes
  localparam logic [6:0] R_TYPE = 7'b0110011,
                         I_TYPE = 7'b0010011,
                         LW     = 7'b0000011,
                         SW     = 7'b0100011,
                         B_TYPE = 7'b1100011,
                         LUI    = 7'b0110111,
                         JAL    = 7'b1101111,
                         JALR   = 7'b1100111;

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

  // funct3 for branch instructions
  localparam logic [2:0] BEQ  = 3'b000,
                         BNE  = 3'b001,
                         BLT  = 3'b100,
                         BGE  = 3'b101,
                         BLTU = 3'b110,
                         BGEU = 3'b111;

  // ImmSrc values
  localparam logic [2:0] IS_UNDEFINED = 3'bxxx,
                         IS_LW_I_TYPE = 3'b000,
                         IS_SW        = 3'b001,
                         IS_B_TYPE    = 3'b010,
                         IS_LUI       = 3'b011,
                         IS_JAL       = 3'b100;

  // signals
  logic [6:0] Opcode;
  logic [2:0] funct3;
  logic f7;

  // assigns
  assign Opcode = Instr[6:0];
  assign funct3 = Instr[14:12];
  assign f7 = Instr[30];

  // control signals handling
  always_comb begin
    SignedExt = 1'b1;  // default: treat as signed
    PCSrc     = 1'b0;  // default: don't jump
    PCSave    = 1'b0;  // default: don't save
    PCJumpSrc = 1'b0;  // default: don't use the jump register
    case (Opcode)
      R_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_UNDEFINED;
        ALUSrc = 1'b0;
        ResultSrc = 1'b0;
      end

      I_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
      end

      LW: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        ResultSrc = 1'b1;
      end

      SW: begin  // S_type
        MemWrite = 1'b1;
        RegWrite = 1'b0;
        ImmSrc = IS_SW;
        ALUSrc = 1'b1;
        ResultSrc = 1'bx;
      end

      B_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b0;
        ImmSrc = IS_B_TYPE;
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

      LUI: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_LUI;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
      end

      JAL: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_JAL;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
        PCSave = 1'b1;
      end

      JALR: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = IS_JAL;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
        PCSave = 1'b1;
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
        default: ALUControl = {1'b0, funct3};
      endcase

      I_TYPE:
      case (funct3)
        3'b101:  ALUControl = (f7 == 1'b1) ? SRL : SRA;
        default: ALUControl = {1'b0, funct3};
      endcase

      LW: ALUControl = ADD;  // add

      SW: ALUControl = ADD;  // add

      B_TYPE: begin
        ALUControl = SUB;  // sub
      end

      LUI: begin
        ALUControl = CPB;  // copy b
      end

      default: ALUControl = UNDEFINED;
    endcase
  end

endmodule

