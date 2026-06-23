# sintesi.tcl
# Script per la sintesi

set LIB_FILE /vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib
set VERILOG_FILES {
    ./RTL/Control.sv
    ./RTL/Extend.sv
    ./RTL/Processor.sv
    ./RTL/RegisterFile.sv
    ./RTL/ALU.sv
}
set CONSTRAINTS_FILE ./impl/frontend/constraints_fe.sdc

read_liberty $LIB_FILE
read_slang  {*}$VERILOG_FILES

#sintesi generica iniziale
syn_generic

# Standard-cell mapping ed ottimizzazione.
syn_map $CONSTRAINTS_FILE

#salvataggio dei risultati
write_netlist ./impl/results/netlist_fe.v
write_sdf ./impl/results/netlist.sdf
report_area
report_timing

# eventual salvataggio dei report in file di testo
report_area   ./impl/results/synth_area_report.txt
report_timing ./impl/results/synth_timing_report.txt


