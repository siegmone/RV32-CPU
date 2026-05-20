`timescale 1ns / 1ps
module tb_Extend;

  logic [31:0] Instr;
  logic [1:0] ImmSrc;
  logic [31:0] ImmExt;

  logic signed [11:0] imm12;
  logic signed [12:0] imm13;

  Extend uut (.*);

  initial begin
    ImmSrc = 2'b00;
    imm12 = 33;
    Instr = 0;
    Instr[31:20] = imm12[11:0];
    #1ns;
    assert (signed'(ImmExt) === 33)
    else $error("Test failed: ImmExt is not equal to 33");
    imm12 = -33;
    Instr = 0;
    Instr[31:20] = imm12[11:0];
    #1ns;
    assert (signed'(ImmExt) === -33)
    else $error("Test failed: ImmExt is not equal to -33");

    ImmSrc = 2'b01;
    imm12 = 44;
    Instr = 0;
    Instr[31:25] = imm12[11:5];
    Instr[11:7] = imm12[4:0];
    #1ns;
    assert (signed'(ImmExt) === 44)
    else $error("Test failed: ImmExt is not equal to 44");
    imm12 = -44;
    Instr = 0;
    Instr[31:25] = imm12[11:5];
    Instr[11:7] = imm12[4:0];
    #1ns;
    assert (signed'(ImmExt) === -44)
    else $error("Test failed: ImmExt is not equal to -44");

    ImmSrc = 2'b10;
    imm13 = 56;
    Instr = 0;
    // {Instr[31], Instr[7], Instr[30:25], Instr[11:8]} = imm13[12:1];
    Instr[31] = imm13[12];
    Instr[30:25] = imm13[10:5];
    Instr[11:8] = imm13[4:1];
    Instr[7] = imm13[11];
    #1ns;
    assert (signed'(ImmExt) === 56)
    else $error("Test failed: ImmExt is not equal to 56");

    imm13 = -56;
    Instr = 0;
    Instr[31] = imm13[12];
    Instr[30:25] = imm13[10:5];
    Instr[11:8] = imm13[4:1];
    Instr[7] = imm13[11];
    #1ns;
    assert (signed'(ImmExt) === -56)
    else $error("Test failed: ImmExt is not equal to -56");

    $display("========================================================");
    $display(" Simulazione terminata senza errori.");
    $display("========================================================");

    $finish;

  end

endmodule

