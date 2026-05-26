#! /bin/bash

path="$1"
parent="$(dirname "$path")"
name="$(basename "$path")"
base="${name%.*}"
build_dir="$parent/build"
elf_file="$build_dir/$base.elf"
hex_file="$build_dir/$base.hex"
current_hex="$parent/test.hex"

riscv32-gcc -march=rv32im "$path" -o "$elf_file"
riscv32-objcopy "$elf_file" "$hex_file"
cp "$hex_file" "$current_hex"
./scripts/tb_sistema.sh
mv dati.vcd "$build_dir/"$base"_sim.vcd"
gtkwave "$build_dir/"$base"_sim.vcd"

