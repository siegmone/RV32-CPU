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
  logic PCSrc;
  logic [31:0] PC_Next;
  logic [31:0] PC_Plus4;
  logic [31:0] PC_Target;
  logic [31:0] ImmExt;

  logic [31:0] RD1, RD2, WD3;

  logic ALUSrc;
  logic [31:0] ALU_Src_A, ALU_Src_B;

  logic ResultSrc;

  Control control_unit (.*);

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
    ALU_Src_A = RD1;
    ALU_Src_B = (ALUSrc == 1) ? ImmExt : RD2;
  end

  // Decide which result to put into register
  always_comb begin
    WD3 = (ResultSrc == 1) ? ReadData : ALUResult;
  end

endmodule
