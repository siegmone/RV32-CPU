`timescale 1ns / 1ps
// SCHEMATIC FLAT 0
module Processor (
    input  logic        clk,
    rst,
    output logic [31:0] PC,
    input  logic [31:0] Instr,      // Interfaccia ROM
    output logic [31:0] WriteData,
    ALUResult,  // interfaccia RAM
    input  logic [31:0] ReadData,
    output logic        MemWrite    // interfaccia RAM
);

  // definire i vari segnali interni, istanziare i blocchi
  // descrivere i multiplexer, il program counter
  // gli addizionatori per aggiornare il program counter

  // Program Counter signals
  logic PCSrc, PCJumpSrc;
  logic [1:0] RegSrc;
  logic [31:0] PC_Next;
  logic [31:0] PCPlus4;
  logic [31:0] PCTarget;
  logic [31:0] PCJalr;
  logic [31:0] PCTmp;

  // Immediate handling
  logic [31:0] ImmExt;
  logic [2:0] ImmSrc;

  // RegisterFile signals
  logic RegWrite;
  logic WE3;
  logic [4:0] A1, A2, A3;
  logic [31:0] RD1, RD2, WD3;

  // ALU signals
  logic ALUSrc;
  logic [4:0] ALUControl;
  logic [31:0] ALUSrcA, ALUSrcB;
  logic Zero, Neg, SignedExt, ALUBypass;

  // Register writing handling
  logic ResultSrc;
  logic [31:0] Result;

  // Module instantiation
  Control control_unit (.*);
  RegisterFile register_file (.*);
  Extend extend_unit (.*);
  ALU alu (
      .A(ALUSrcA),
      .B(ALUSrcB),
      .Y(ALUResult),
      .*
  );

  // continuous assignment
  assign ALUSrcA = RD1;
  assign WriteData = RD2;
  assign A1 = Instr[19:15];
  assign A2 = Instr[24:20];
  assign A3 = Instr[11:7];
  assign WE3 = RegWrite;
  assign PCJalr = {ALUResult[31:1], 1'b0};

  // output next PC
  always_ff @(posedge clk) begin
    if (rst == 1'b1) PC <= 32'b0;
    else PC <= PC_Next;
  end

  // add 4 to PC
  always_comb begin
    PCPlus4 = PC + 4;
  end

  // how much to jump
  always_comb begin
    PCTarget = PC + ImmExt;
  end

  // decide PCTmp
  always_comb begin
    PCTmp = (PCJumpSrc == 1'b1) ? PCJalr : PCTarget;
  end

  // jump or continue
  always_comb begin
    PC_Next = (PCSrc == 1'b1) ? PCTmp : PCPlus4;
  end

  // Decide ALU inputs
  always_comb begin
    ALUSrcB = (ALUSrc == 1) ? ImmExt : RD2;
  end

  // Decide what to put into register
  always_comb begin
    Result = (ResultSrc == 1) ? ReadData : ALUResult;
    case (RegSrc)
      2'b00:   WD3 = Result;
      2'b01:   WD3 = PCPlus4;
      2'b10:   WD3 = PCTarget;
      2'b11:   ;
      default: ;
    endcase
  end

endmodule
