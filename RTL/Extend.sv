`timescale 1ns / 1ps
module Extend (
    input  logic [31:0] Instr,
    input  logic [ 2:0] ImmSrc,
    output logic [31:0] ImmExt
);

  // ImmSrc values
  localparam logic [2:0] LW_I_TYPE = 3'b000,
        SW = 3'b001,
        B_TYPE = 3'b010,
        LUI = 3'b011,
        JAL = 3'b100;

  always_comb begin
    case (ImmSrc)
      LW_I_TYPE: ImmExt = {{20{Instr[31]}}, Instr[31:20]};  // I_type
      SW: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};  // S_type
      B_TYPE: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};  // SB_type
      LUI: ImmExt = {Instr[31:12], 12'b0};  // LUI
      JAL: ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
      default: ImmExt = 32'bx;
    endcase
  end

endmodule

