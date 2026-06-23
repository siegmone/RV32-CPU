# 3_cts.tcl

set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

read_liberty $LIB_FILE

read_db "impl/results/placement.odb"
read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

clock_tree_synthesis -buf_list {sg13g2_buf_4 sg13g2_buf_8 sg13g2_buf_16} \
                     -root_buf  sg13g2_buf_4
report_cts
report_clock_latency
report_clock_skew
report_cell_usage -verbose

detailed_placement
improve_placement -max_displacement 20
check_placement -verbose

estimate_parasitics -placement
set_propagated_clock clk
report_checks -path_delay min  -digits 3 -format full_clock_expanded
report_checks -path_delay max  -digits 3 -format full_clock_expanded

# Eventuale aggiustamento del hold
repair_timing -hold -hold_margin 0.200 -verbose
report_checks -path_delay min -digits 3 -format full_clock_expanded
detailed_placement
improve_placement -max_displacement 20

tee -file impl/results/cts_setup_time.rpt \
    { report_checks -path_delay max -digits 3 -format full_clock_expanded }
tee -file impl/results/cts_hold_time.rpt \
    { report_checks -path_delay min -digits 3 -format full_clock_expanded }

tee -file impl/results/cts_design_area.rpt { report_design_area }
write_db   impl/results/cts.odb

gui::show

exit

