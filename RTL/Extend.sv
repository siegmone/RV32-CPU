`timescale 1ns / 1ps
module Extend (
    input  logic [31:0] Instr,
    input  logic [ 2:0] ImmSrc,
    output logic [31:0] ImmExt
);

  // ImmSrc values
  localparam logic [2:0] IS_UNDEFINED = 3'bxxx,
                         IS_LW_I_TYPE = 3'b000,
                         IS_S_TYPE    = 3'b001,
                         IS_B_TYPE    = 3'b010,
                         IS_U_TYPE    = 3'b011,
                         IS_J_TYPE    = 3'b100;

  always_comb begin
    case (ImmSrc)
      IS_LW_I_TYPE: ImmExt = {{20{Instr[31]}}, Instr[31:20]};  // I_type
      IS_S_TYPE: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};  // S_type
      IS_B_TYPE: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};  // B_type
      IS_U_TYPE: ImmExt = {Instr[31:12], 12'b0};  // IS_U_TYPE
      IS_J_TYPE: ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // J_type
      default: ImmExt = 32'bx;
    endcase
  end

endmodule

