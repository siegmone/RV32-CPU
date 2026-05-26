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
  CPB = 4'b1000,  // copy B
  SLT = 4'b1010,  // set less than
  SLTU = 4'b1011;  // set less than unsigned

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
    MemWrite  = 1'b0;  // default: don't write in Data Memory
    RegWrite  = 1'b0;  // default: don't write in Register File
    PCSrc     = 1'b0;  // default: don't jump
    PCSave    = 1'b0;  // default: don't save
    PCJumpSrc = 1'b0;  // default: don't use the jump register
    SignedExt = 1'b1;  // default: treat as signed
    ALUSrc    = 1'b0;  // default: use RD2 as SrcB for ALU
    ResultSrc = 1'b0;  // default: use ALUResult
    ImmSrc    = IS_UNDEFINED;  // default: undefined immediate
    // for each case, if not specified, default values apply
    case (Opcode)
      R_TYPE: begin
        RegWrite = 1'b1;
      end

      I_TYPE: begin
        RegWrite = 1'b1;
        ImmSrc   = IS_LW_I_TYPE;
        ALUSrc   = 1'b1;
      end

      LW: begin
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        ResultSrc = 1'b1;
      end

      SW: begin  // S_type
        MemWrite = 1'b1;
        ImmSrc = IS_SW;
        ALUSrc = 1'b1;
        ResultSrc = 1'bx;
      end

      B_TYPE: begin
        ImmSrc = IS_B_TYPE;
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
        RegWrite = 1'b1;
        ImmSrc   = IS_LUI;
        ALUSrc   = 1'b1;
      end

      JAL: begin
        RegWrite = 1'b1;
        ImmSrc = IS_JAL;
        ALUSrc = 1'b1;
        PCSrc = 1'b1;
        PCSave = 1'b1;
      end

      JALR: begin
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        PCSrc = 1'b1;
        PCSave = 1'b1;
        PCJumpSrc = 1'b1;
      end

      default: begin
        MemWrite = 1'bx;
        RegWrite = 1'bx;
        ImmSrc = IS_UNDEFINED;
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
        3'b010:  ALUControl = SLT;
        3'b011:  ALUControl = SLTU;
        default: ALUControl = {1'b0, funct3};
      endcase

      I_TYPE:
      case (funct3)
        3'b101:  ALUControl = (f7 == 1'b1) ? SRL : SRA;
        3'b010:  ALUControl = SLT;
        3'b011:  ALUControl = SLTU;
        default: ALUControl = {1'b0, funct3};
      endcase

      LW, SW, JALR: ALUControl = ADD;  // add

      B_TYPE: ALUControl = SUB;  // sub

      LUI, JAL: ALUControl = CPB;  // copy b

      default: ALUControl = UNDEFINED;
    endcase
  end

endmodule

