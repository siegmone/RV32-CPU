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
  logic PCSrc;
  logic [31:0] PC_Next;
  logic [31:0] PC_Plus4;
  logic [31:0] PC_Target;

  // Immediate handling
  logic [31:0] ImmExt;
  logic [1:0] ImmSrc;

  // RegisterFile signals
  logic RegWrite;
  logic WE3;
  logic [4:0] A1, A2, A3;
  logic [31:0] RD1, RD2, WD3;

  // ALU signals
  logic ALUSrc;
  logic [2:0] ALUControl;
  logic [31:0] ALU_Src_A, ALU_Src_B;
  logic Zero, Neg, SignedExt;

  // Register writing handling
  logic ResultSrc;

  // Module instantiation
  Control control_unit (.*);
  RegisterFile register_file (.*);
  Extend extend_unit (.*);
  ALU alu (
      .A(ALU_Src_A),
      .B(ALU_Src_B),
      .Y(ALUResult),
      .*
  );

  // continuous assignment
  assign ALU_Src_A = RD1;
  assign WriteData = RD2;
  assign A1 = Instr[19:15];
  assign A2 = Instr[24:20];
  assign A3 = Instr[11:7];
  assign WE3 = RegWrite;

  // output next PC
  always_ff @(posedge clk) begin
    if (rst == 1'b1) PC <= 32'b0;
    else PC <= PC_Next;
  end

  // jump or continue
  always_comb begin
    PC_Next = (PCSrc == 1'b1) ? PC_Target : PC_Plus4;
  end

  // add 4 to PC
  always_comb begin
    PC_Plus4 = PC + 4;
  end

  // how much to jump
  always_comb begin
    PC_Target = PC + ImmExt;
  end

  // Decide ALU inputs
  always_comb begin
    ALU_Src_B = (ALUSrc == 1) ? ImmExt : RD2;
  end

  // Decide which result to put into register
  always_comb begin
    WD3 = (ResultSrc == 1) ? ReadData : ALUResult;
  end

endmodule
