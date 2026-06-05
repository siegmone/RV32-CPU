# 5_final.tcl

set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

set RCX_FILE "/vlsi/tech/ihp-sg13g2/rcx_patterns.rules"

set GDS_FILES "/vlsi/tech/ihp-sg13g2/gds/sg13g2_stdcell.gds"

set LEF_FILES { /vlsi/tech/ihp-sg13g2/lef/sg13g2_stdcell.lef
                /vlsi/tech/ihp-sg13g2/lef/sg13g2_tech.lef}


read_liberty $LIB_FILE
read_db  impl/results/routed.odb
read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

extract_parasitics -ext_model_file $RCX_FILE
write_spef impl/results/final.spef
read_spef impl/results/final.spef
set_propagated_clock  [all_clocks]
report_checks -path_delay max -digits 3 -format full_clock_expanded
report_checks -path_delay min -digits 3 -format full_clock_expanded
report_power

set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -net VDD -error_file VDD.rpt

set_pdnsim_net_voltage -net VSS -voltage 0.0
analyze_power_grid -net VSS -error_file VSS.rpt

write_verilog impl/results/final.v

write_def impl/results/final.def
write_timing_model impl/results/final.lib
write_abstract_lef impl/results/final.lef
write_sdf impl/results/final.sdf

write_gds impl/results/final.def  $GDS_FILES $LEF_FILES  impl/results/final.gds

#########
