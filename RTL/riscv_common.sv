`timescale 1ns / 1ps

package riscv_common;
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

  // ImmSrc values
  localparam logic [2:0] IS_UNDEFINED = 3'bxxx,
                         IS_LW_I_TYPE = 3'b000,
                         IS_S_TYPE    = 3'b001,
                         IS_B_TYPE    = 3'b010,
                         IS_U_TYPE    = 3'b011,
                         IS_J_TYPE    = 3'b100;


endpackage
