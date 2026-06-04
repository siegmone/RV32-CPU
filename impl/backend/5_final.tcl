# ese01
# 5_final.tcl

set CONSTRAINTS_FILE "./src/constraints.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

set RCX_FILE "/vlsi/tech/ihp-sg13g2/rcx_patterns.rules"

set GDS_FILES "/vlsi/tech/ihp-sg13g2/gds/sg13g2_stdcell.gds"

set LEF_FILES { /vlsi/tech/ihp-sg13g2/lef/sg13g2_stdcell.lef
                /vlsi/tech/ihp-sg13g2/lef/sg13g2_tech.lef}


read_liberty $LIB_FILE
read_db  results/routed.odb
read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

extract_parasitics -ext_model_file $RCX_FILE
write_spef results/final.spef
read_spef results/final.spef
set_propagated_clock  [all_clocks]
report_checks -path_delay max -digits 3 -format full_clock_expanded
report_checks -path_delay min -digits 3 -format full_clock_expanded
report_power

set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -net VDD -error_file VDD.rpt

set_pdnsim_net_voltage -net VSS -voltage 0.0
analyze_power_grid -net VSS -error_file VSS.rpt

write_verilog results/final.v

write_def results/final.def
write_timing_model results/final.lib
write_abstract_lef results/final.lef
write_sdf results/final.sdf

write_gds results/final.def  $GDS_FILES $LEF_FILES  results/final.gds 

#########