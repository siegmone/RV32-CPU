`timescale 1ns / 1ps

package rv32i_pkg;

  // Sign-extend helpers
  function automatic int sext12(input logic [11:0] imm);
    sext12 = $signed({{20{imm[11]}}, imm});
  endfunction
  function automatic int sext13(input logic [12:0] imm);
    sext13 = $signed({{19{imm[12]}}, imm});
  endfunction
  function automatic int sext20(input logic [19:0] imm);
    sext20 = $signed({{12{imm[19]}}, imm});
  endfunction
  function automatic int sext21(input logic [20:0] imm);
    sext21 = $signed({{11{imm[20]}}, imm});
  endfunction

  // Ritorna la mnemotecnica formattata
  function automatic string rv32i_decode(input logic [31:0] instr);
    string asm;

    // campi comuni
    logic [6:0] opcode = instr[6:0];
    logic [4:0] rd = instr[11:7];
    logic [2:0] funct3 = instr[14:12];
    logic [4:0] rs1 = instr[19:15];
    logic [4:0] rs2 = instr[24:20];
    logic [6:0] funct7 = instr[31:25];

    // immediati precomposti (non tutti sign-extended qui)
    int imm_i = sext12(instr[31:20]);
    int imm_s = sext12({instr[31:25], instr[11:7]});
    int imm_b = sext13({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});  // branch *2
    int imm_u = int'({instr[31:12], 12'b0});  // upper 20 << 12 (no sign)
    int imm_j = sext21({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});  // jal *2
    int shamt = int'(instr[24:20]);  // per shift immediati

    // decodifica per opcode
    case (opcode)
      7'b0110111: begin  // LUI
        asm = $sformatf("lui x%0d, 0x%0h", rd, imm_u);
      end
      7'b0010111: begin  // AUIPC
        asm = $sformatf("auipc x%0d, 0x%0h", rd, imm_u);
      end
      7'b1101111: begin  // JAL
        asm = $sformatf("jal x%0d, %0d", rd, imm_j);
      end
      7'b1100111: begin  // JALR (I-type, funct3==000)
        if (funct3 == 3'b000) asm = $sformatf("jalr x%0d, %0d(x%0d)", rd, imm_i, rs1);
        else asm = $sformatf("unknown (JALR opcode, funct3=%0b)", funct3);
      end
      7'b1100011: begin  // BRANCH
        case (funct3)
          3'b000:  asm = $sformatf("beq  x%0d, x%0d, %0d", rs1, rs2, imm_b);
          3'b001:  asm = $sformatf("bne  x%0d, x%0d, %0d", rs1, rs2, imm_b);
          3'b100:  asm = $sformatf("blt  x%0d, x%0d, %0d", rs1, rs2, imm_b);
          3'b101:  asm = $sformatf("bge  x%0d, x%0d, %0d", rs1, rs2, imm_b);
          3'b110:  asm = $sformatf("bltu x%0d, x%0d, %0d", rs1, rs2, imm_b);
          3'b111:  asm = $sformatf("bgeu x%0d, x%0d, %0d", rs1, rs2, imm_b);
          default: asm = $sformatf("unknown branch funct3=%0b", funct3);
        endcase
      end
      7'b0000011: begin  // LOAD
        case (funct3)
          3'b000:  asm = $sformatf("lb  x%0d, %0d(x%0d)", rd, imm_i, rs1);
          3'b001:  asm = $sformatf("lh  x%0d, %0d(x%0d)", rd, imm_i, rs1);
          3'b010:  asm = $sformatf("lw  x%0d, %0d(x%0d)", rd, imm_i, rs1);
          3'b100:  asm = $sformatf("lbu x%0d, %0d(x%0d)", rd, imm_i, rs1);
          3'b101:  asm = $sformatf("lhu x%0d, %0d(x%0d)", rd, imm_i, rs1);
          default: asm = $sformatf("unknown load funct3=%0b", funct3);
        endcase
      end
      7'b0100011: begin  // STORE
        case (funct3)
          3'b000:  asm = $sformatf("sb x%0d, %0d(x%0d)", rs2, imm_s, rs1);
          3'b001:  asm = $sformatf("sh x%0d, %0d(x%0d)", rs2, imm_s, rs1);
          3'b010:  asm = $sformatf("sw x%0d, %0d(x%0d)", rs2, imm_s, rs1);
          default: asm = $sformatf("unknown store funct3=%0b", funct3);
        endcase
      end
      7'b0010011: begin  // OP-IMM
        case (funct3)
          3'b000:  asm = $sformatf("addi x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b010:  asm = $sformatf("slti x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b011:  asm = $sformatf("sltiu x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b100:  asm = $sformatf("xori x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b110:  asm = $sformatf("ori  x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b111:  asm = $sformatf("andi x%0d, x%0d, %0d", rd, rs1, imm_i);
          3'b001: begin  // SLLI: funct7 = 0000000
            if (funct7 == 7'b0000000) asm = $sformatf("slli x%0d, x%0d, %0d", rd, rs1, shamt);
            else asm = $sformatf("unknown slli funct7=%0b", funct7);
          end
          3'b101: begin  // SRLI/SRAI
            if (funct7 == 7'b0000000) asm = $sformatf("srli x%0d, x%0d, %0d", rd, rs1, shamt);
            else if (funct7 == 7'b0100000) asm = $sformatf("srai x%0d, x%0d, %0d", rd, rs1, shamt);
            else asm = $sformatf("unknown shift funct7=%0b", funct7);
          end
          default: asm = $sformatf("unknown op-imm funct3=%0b", funct3);
        endcase
      end
      7'b0110011: begin  // OP
        case ({
          funct7, funct3
        })
          {7'b0000000, 3'b000} : asm = $sformatf("add  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0100000, 3'b000} : asm = $sformatf("sub  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b001} : asm = $sformatf("sll  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b010} : asm = $sformatf("slt  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b011} : asm = $sformatf("sltu x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b100} : asm = $sformatf("xor  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b101} : asm = $sformatf("srl  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0100000, 3'b101} : asm = $sformatf("sra  x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b110} : asm = $sformatf("or   x%0d, x%0d, x%0d", rd, rs1, rs2);
          {7'b0000000, 3'b111} : asm = $sformatf("and  x%0d, x%0d, x%0d", rd, rs1, rs2);
          default: asm = $sformatf("unknown op funct7=%0b funct3=%0b", funct7, funct3);
        endcase
      end
      7'b1110011: begin  // SYSTEM
        case (funct3)
          3'b000: begin
            if (instr[31:20] == 12'b000000000000) asm = "ecall";
            else if (instr[31:20] == 12'b000000000001) asm = "ebreak";
            else asm = $sformatf("csr-priv (imm=0x%0h)", instr[31:20]);
          end
          default: begin
            // CSR (CSRRW/CSRRS/CSRRC + immediate versions) — opzionale, base print
            string csr_op;
            case (funct3)
              3'b001:  csr_op = "csrrw";
              3'b010:  csr_op = "csrrs";
              3'b011:  csr_op = "csrrc";
              3'b101:  csr_op = "csrrwi";
              3'b110:  csr_op = "csrrsi";
              3'b111:  csr_op = "csrrci";
              default: csr_op = $sformatf("csr-unk(f3=%0b)", funct3);
            endcase
            if (funct3[2])  // *I: usa zimm (rs1)
              asm = $sformatf("%s x%0d, 0x%0h", csr_op, rd, instr[31:20]);
            else asm = $sformatf("%s x%0d, x%0d, 0x%0h", csr_op, rd, rs1, instr[31:20]);
          end
        endcase
      end
      default: asm = $sformatf("unknown opcode=0x%02h", opcode);
    endcase

    return asm;
  endfunction

endpackage : rv32i_pkg






module helper #(
    parameter int MAX_ASCII = 64
) (
    input logic [31:0] Instr,
    output logic [8*MAX_ASCII-1:0] asm_bus
);

  import rv32i_pkg::*;

  // Converte una string in un vettore packed: [7:0]=primo char, [15:8]=secondo, ...
  function automatic logic [8*MAX_ASCII-1:0] string_to_packed(input string s);
    logic [8*MAX_ASCII-1:0] v;
    int n;
    v = '0;  // padding con zeri
    n = (s.len() < MAX_ASCII) ? s.len() : MAX_ASCII;
    for (int i = 0; i < n; i++) begin
      v[8*(MAX_ASCII-1-i)+:8] = $unsigned(s[i]);  // blocchi da 8 bit in ordine crescente
    end
    return v;
  endfunction

  string asm_str;

  always_comb begin
    asm_str = rv32i_decode(Instr);
    asm_bus = string_to_packed(asm_str);
  end

endmodule : helper
