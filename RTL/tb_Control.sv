`timescale 1ns / 1ps
module tb_Control;
  logic [31:0] Instr;
  logic PCSrc, RegWrite, ALUSrc, MemWrite, ResultSrc, Zero;
  logic [2:0] ALUControl;
  logic [1:0] ImmSrc;

  Control uut (.*);

  initial begin
    Instr = 32'hFFC4A303;  //lw
    #1ns;
    $display("Testing lw");
    assert (PCSrc === 1'b0)
    else $error("errore PCSrc");
    assert (RegWrite === 1'b1)
    else $error("errore RegWrite");
    assert (ALUSrc === 1'b1)
    else $error("errore ALUSrc");
    assert (MemWrite === 1'b0)
    else $error("errore MemWrite");
    assert (ResultSrc === 1'b1)
    else $error("errore ResultSrc");
    assert (ImmSrc === 2'b00)
    else $error("errore ImmSrc");
    assert (ALUControl === 3'b000)
    else $error("errore ALUControl");
    $display("Testing lw finished");

    Instr = 32'h0064A423;  //sw
    #1ns;
    $display("Testing sw");
    assert (PCSrc === 1'b0)
    else $error("errore PCSrc");
    assert (RegWrite === 1'b0)
    else $error("errore RegWrite");
    assert (ALUSrc === 1'b1)
    else $error("errore ALUSrc");
    assert (MemWrite === 1'b1)
    else $error("errore MemWrite");
    assert (ImmSrc === 2'b01)
    else $error("errore ImmSrc");
    assert (ALUControl === 3'b000)
    else $error("errore ALUControl");
    $display("Testing sw finished");

    Instr = 32'h0062E233;  //or
    #1ns;
    $display("Testing or");
    assert (PCSrc === 1'b0)
    else $error("errore PCSrc");
    assert (RegWrite === 1'b1)
    else $error("errore RegWrite");
    assert (ALUSrc === 1'b0)
    else $error("errore ALUSrc");
    assert (MemWrite === 1'b0)
    else $error("errore MemWrite");
    assert (ResultSrc === 1'b0)
    else $error("errore ResultSrc");
    assert (ALUControl === 3'b110)
    else $error("errore ALUControl");
    $display("Testing or finished");

    Instr = 32'hFE420AE3;  //beq
    #1ns;
    $display("Testing beq");
    assert (RegWrite === 1'b0)
    else $error("errore RegWrite");
    assert (ALUSrc === 1'b0)
    else $error("errore ALUSrc");
    assert (MemWrite === 1'b0)
    else $error("errore MemWrite");
    assert (ImmSrc === 2'b10)
    else $error("errore ImmSrc");
    assert (ALUControl === 3'b010)
    else $error("errore ALUControl");
    Zero = 1'b1;
    #1ns;
    assert (PCSrc === 1'b1)
    else $error("errore PCSrc");
    Zero = 1'b0;
    #1ns;
    assert (PCSrc === 1'b0)
    else $error("errore PCSrc");
    $display("Testing beq finished");

    Instr = 32'h01300913;  //addi
    #1ns;
    $display("Testing addi");
    assert (PCSrc === 1'b0)
    else $error("errore PCSrc");
    assert (RegWrite === 1'b1)
    else $error("errore RegWrite");
    assert (ALUSrc === 1'b1)
    else $error("errore ALUSrc");
    assert (MemWrite === 1'b0)
    else $error("errore MemWrite");
    assert (ResultSrc === 1'b0)
    else $error("errore ResultSrc");
    assert (ImmSrc === 2'b00)
    else $error("errore ImmSrc");
    assert (ALUControl === 3'b000)
    else $error("errore ALUControl");
    $display("Testing addi finished");

  end


endmodule

