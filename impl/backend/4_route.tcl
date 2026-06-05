# 4_route.tcl

set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

read_liberty $LIB_FILE
read_db "impl/results/cts.odb"
read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

# Non uso i TopMetal
# default metal layer distribution
# set_routing_layers -signal Metal1-Metal5 -clock Metal1-Metal5

# improved metal layer distribution
set_thread_count 2
set_global_routing_layer_adjustment Metal2 0.3
set_global_routing_layer_adjustment Metal3 0.3
set_routing_layers -signal Metal2-Metal5 -clock Metal2-Metal5

global_route  -congestion_iterations 100 -verbose

set_propagated_clock  [all_clocks]
estimate_parasitics -global_routing
report_checks -path_delay min -digits 4 -format full_clock_expanded

detailed_route

repair_antennas
check_antennas
filler_placement {sg13g2_fill_1 sg13g2_fill_2 sg13g2_decap_4 sg13g2_decap_8}
check_placement -verbose


write_db impl/results/routed.odb
gui::show


