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
    PCJumpSrc,
    output logic [1:0] RegSrc,
    output logic [4:0] ALUControl,
    output logic [2:0] ImmSrc
);

  // opcodes
  localparam logic [6:0] R_TYPE       = 7'b0110011,
                         I_TYPE       = 7'b0010011,
                         LOAD         = 7'b0000011,
                         S_TYPE       = 7'b0100011,
                         B_TYPE       = 7'b1100011,
                         J_TYPE       = 7'b1101111,
                         JALR         = 7'b1100111,
                         U_TYPE_LUI   = 7'b0110111,
                         U_TYPE_AUIPC = 7'b0010111;

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
                         IS_S_TYPE    = 3'b001,
                         IS_B_TYPE    = 3'b010,
                         IS_U_TYPE    = 3'b011,
                         IS_J_TYPE    = 3'b100;

  // signals
  logic [6:0] Opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic f7_i, f7_m;
  logic [4:0] AC_def;

  // assigns
  assign Opcode = Instr[6:0];
  assign funct3 = Instr[14:12];
  assign funct7 = Instr[31:25];
  assign f7_i   = funct7[5];
  assign f7_m   = funct7[0];
  assign AC_def = {2'b0, funct3};

  // control signals handling
  always_comb begin
    // RegSrc cases:
    // 00 -> Result is stored,
    // 01 -> PCPlus4 is stored,
    // 10 -> PCTarget is stored,
    // 11 -> unused
    RegSrc    = 2'b0;  // default: save final result
    MemWrite  = 1'b0;  // default: don't write in Data Memory
    RegWrite  = 1'b0;  // default: don't write in Register File
    PCSrc     = 1'b0;  // default: don't jump
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

      LOAD: begin
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        ResultSrc = 1'b1;
      end

      S_TYPE: begin  // S_type
        MemWrite = 1'b1;
        ImmSrc = IS_S_TYPE;
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

      U_TYPE_LUI: begin
        RegWrite = 1'b1;
        ImmSrc   = IS_U_TYPE;
        ALUSrc   = 1'b1;
      end

      U_TYPE_AUIPC: begin
        RegWrite = 1'b1;
        ImmSrc   = IS_U_TYPE;
        ALUSrc   = 1'b1;
        RegSrc   = 2'b10;
      end

      J_TYPE: begin
        RegWrite = 1'b1;
        ImmSrc = IS_J_TYPE;
        ALUSrc = 1'b1;
        PCSrc = 1'b1;
        RegSrc = 2'b01;
      end

      JALR: begin
        RegWrite = 1'b1;
        ImmSrc = IS_LW_I_TYPE;
        ALUSrc = 1'b1;
        PCSrc = 1'b1;
        RegSrc = 2'b01;
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
        3'b000: begin
          if (f7_m == 1'b1) ALUControl = MUL;
          else ALUControl = (f7_i == 1'b1) ? SUB : ADD;
        end
        3'b001: begin
          if (f7_m == 1'b1) ALUControl = MULH;
          else ALUControl = AC_def;
        end
        3'b010: begin
          if (f7_m == 1'b1) ALUControl = MULHSU;
          else ALUControl = SLT;
        end
        3'b011: begin
          if (f7_m == 1'b1) ALUControl = MULHU;
          else ALUControl = SLTU;
        end
        3'b100: begin
          if (f7_m == 1'b1) ALUControl = DIV;
          else ALUControl = AC_def;
        end
        3'b101: begin
          if (f7_m == 1'b1) ALUControl = DIVU;
          else ALUControl = (f7_i == 1'b1) ? SRL : SRA;
        end
        3'b110: begin
          if (f7_m == 1'b1) ALUControl = REM;
          else ALUControl = AC_def;
        end
        3'b111: begin
          if (f7_m == 1'b1) ALUControl = REMU;
          else ALUControl = AC_def;
        end
        default: ALUControl = AC_def;
      endcase

      I_TYPE:
      case (funct3)
        3'b101:  ALUControl = (f7_i == 1'b1) ? SRL : SRA;
        3'b010:  ALUControl = SLT;
        3'b011:  ALUControl = SLTU;
        default: ALUControl = AC_def;
      endcase

      LOAD, S_TYPE, JALR: ALUControl = ADD;  // add

      B_TYPE: ALUControl = SUB;  // sub

      U_TYPE_LUI, J_TYPE: ALUControl = CPB;  // copy b

      default: ALUControl = UNDEFINED;
    endcase
  end

endmodule

