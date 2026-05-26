# Programma di test avanzato per RV32I + RV32M
    .globl _start
_start:

    # -----------------------------------------------------------------
    # SCENARIO 1: Shift Logico vs Aritmetico (Test su SRA e SRL)
    # -----------------------------------------------------------------
    li x5, -8               # x5 = 0xFFFFFFF8 (Numero negativo)
    srl x6, x5, 1           # Shift logico:   x6 = 0x7FFFFFFC (Inserisce uno 0)
    sra x7, x5, 1           # Shift aritmetico: x7 = 0xFFFFFFFC (Preserva il segno '1')

    # -----------------------------------------------------------------
    # SCENARIO 2: Estensione M (Moltiplicazioni e Divisioni)
    # -----------------------------------------------------------------
    li x10, 2               # x10 = 2
    li x11, -3              # x11 = -3 (0xFFFFFFFD)

    # Test MULHSU (Moltiplicando Segnato x Non Segnato)
    mulhsu x12, x11, x10    # Risultato alto a 32-bit di (-3 * 2)

    # Test Divisione per Zero (Caso limite hardware)
    li x13, 0               # x13 = 0
    div x14, x10, x13       # 2 / 0 -> Deve restituire 0xFFFFFFFF (come da tua ALU)
    rem x15, x10, x13       # 2 % 0 -> Deve restituire il dividendo originale (2)

    # -----------------------------------------------------------------
    # SCENARIO 3: Flag 'Neg' e Branch Non Segnati (BLTU)
    # -----------------------------------------------------------------
    li x20, 5               # x20 = 5
    li x21, -1              # x21 = 0xFFFFFFFF (In modalità non segnata è il numero massimo!)

    # Dal punto di vista segnato:  5 > -1  (Non salterebbe)
    # Dal punto di vista non segnato (BLTU): 5 < 4294967295 -> IL SALTO DEVE ESSERE PRESO!
    bltu x20, x21, unsigned_taken

    # Se la ALU sbaglia il flag Neg non segnato, finisce qui (Errore)
    li x30, 0xBAD
    beq x0, x0, end

unsigned_taken:
    # Se il circuito è corretto, salta direttamente qui
    li x30, 0x600D    # x30 = 0x600D ("GOOD")

end:
    nop
    beq x0, x0, end
