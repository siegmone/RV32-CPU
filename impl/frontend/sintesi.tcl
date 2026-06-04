# sintesi.tcl
# Script per la sintesi

set LIB_FILE /vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib
set VERILOG_FILES {src/example.sv}
set CONSTRAINTS_FILE ./src/constraints.sdc

read_liberty $LIB_FILE
read_slang  {*}$VERILOG_FILES

#sintesi generica iniziale
syn_generic 

# Standard-cell mapping ed ottimizzazione.
syn_map $CONSTRAINTS_FILE

#salvataggio dei risultati
write_netlist results/example.v
write_sdf results/netlist.sdf
report_area
report_timing

# eventual salvataggio dei report in file di testo
report_area   results/area_report.txt
report_timing results/timing_report.txt


