`timescale 1ns / 1ps
// SCHEMATIC MODE 1
module Control (
    input logic [31:0] Instr,
    input logic Zero,
    output logic PCSrc,
    RegWrite,
    ALUSrc,
    MemWrite,
    ResultSrc,
    output logic [2:0] ALUControl,
    output logic [1:0] ImmSrc
);

  localparam    [6:0] R_TYPE = 7'b0110011,
                    I_TYPE = 7'b0010011,
                    LW     = 7'b0000011,
                    SW     = 7'b0100011,
                    B_TYPE = 7'b1100011;

  logic [6:0] Opcode;
  logic [2:0] funct3;
  logic f7;

  assign Opcode = Instr[6:0];
  assign funct3 = Instr[14:12];
  assign f7 = Instr[30];

  always_comb
    // Tutti i segnali controllo, tranne ALUControl
    // Dipendono solo da Opcode e Zero
    case (Opcode)
      R_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'bxx;
        ALUSrc = 1'b0;
        ResultSrc = 1'b0;
        PCSrc = 1'b0;
      end
      I_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'b00;
        ALUSrc = 1'b1;
        ResultSrc = 1'b0;
        PCSrc = 1'b0;
      end
      LW: begin
        MemWrite = 1'b0;
        RegWrite = 1'b1;
        ImmSrc = 2'b00;
        ALUSrc = 1'b1;
        ResultSrc = 1'b1;
        PCSrc = 1'b0;
      end
      SW: begin  // S_type
        MemWrite = 1'b1;
        RegWrite = 1'b0;
        ImmSrc = 2'b01;
        ALUSrc = 1'b1;
        ResultSrc = 1'bx;
        PCSrc = 1'b0;
      end
      B_TYPE: begin
        MemWrite = 1'b0;
        RegWrite = 1'b0;
        ImmSrc = 2'b10;
        ALUSrc = 1'b0;
        ResultSrc = 1'bx;
        if (Zero) PCSrc = 1'b1;  // salto
        else PCSrc = 1'b0;  // non si salta
      end
      default: begin
        MemWrite = 1'bx;
        RegWrite = 1'bx;
        ImmSrc = 2'bxx;
        ALUSrc = 1'bx;
        ResultSrc = 1'bx;
        PCSrc = 1'bx;
      end
    endcase

  always_comb
    // Calcolo di ALUControl
    case (Opcode)
      R_TYPE:
      if (funct3 == 3'b000)
        if (f7 == 1'b1) ALUControl = 3'b010;  // sottrazione
        else ALUControl = 3'b000;  // somma
      else if (funct3 == 3'b101)
        if (f7 == 1'b1) ALUControl = 3'b011;  // srl
        else ALUControl = 3'b101;  // sra
      else ALUControl = funct3;

      I_TYPE:
      if (funct3 == 3'b101)
        if (f7 == 1'b1) ALUControl = 3'b011;  // srai
        else ALUControl = 3'b101;  // srli
      else ALUControl = funct3;

      LW: ALUControl = 3'b000;  // somma

      SW: ALUControl = 3'b000;  // somma

      B_TYPE: ALUControl = 3'b010;  // sottrazione

      default: ALUControl = 3'bxxx;
    endcase

endmodule

