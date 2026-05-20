`timescale 1ns / 1ps
module RegisterFile (
    input logic clk,
    WE3,
    input logic [4:0] A1,
    A2,
    A3,
    input logic [31:0] WD3,
    output logic [31:0] RD1,
    RD2
);

  logic [31:0] rf[32];

  always_comb begin
    RD1 = (A1 == 0) ? 0 : rf[A1];
    RD2 = (A2 == 0) ? 0 : rf[A2];
  end

  always_ff @(posedge clk) begin
    if (WE3 == 1) begin
      if (A3 != 0) rf[A3] <= WD3;
    end
  end

endmodule

