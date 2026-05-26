# RISC-V 32bit Processor

This is a project for an **ASIC** class @ University Federico II of Naples.

It involves designing a RISC-V 32bit microprocessor with SystemVerilog.

The programs used are present in the custom environment provided by the professor,
so the scripts are not useful in a different environment,
but the source HDL files can still be compiled with the tools of your choice.

## Features
- [x] RV32I base instruction set
- [x] RV32M multiplication/division extension instruction set

For now the only missing part is the backend of the design process (floorplanning, placement, routing, ...)

## Testbenches
To run the testbenches run the commands in the scripts directory:
```
./scripts/tb_<module>.sh
```

## Test programs
In the `test/` directory write a `<test-name>.s` assembly code file and
run it with the following command:
```
./scripts/test_rv32_program.sh ./tests/<test-name>.s
```
This will compile the program,
place the built binaries in the `tests/build` directory,
copy the newly compiled `.hex` file to `tests/test.hex`,
and run the `TB/tb_Sistema.sv` testbench with it,
opening `gtkwave` at the end.
