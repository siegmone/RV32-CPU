# 2_placement.tcl

set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

read_liberty $LIB_FILE
read_db "impl/results/floorplan.odb"

read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

buffer_ports -buffer_cell "sg13g2_buf_4"
report_top_fanout 10

# E' possibile specificare singolarmente dove piazzare i vari pin, ma per semplicità,
# non lo faremo e lasceremo il compito al programma di poiazzamento

report_design_area
# Mettiamo una density coerente con report_design_area e realizziamo il global placement,
# senza inserire ancora i pin
global_placement -density 0.58 -routability_driven -skip_io

# Piazziamo i pin
# place_pins -hor_layer Metal2 -ver_layer Metal3 -min_distance_in_tracks -min_distance 4
place_pins -hor_layer Metal2 -ver_layer Metal3 -min_distance_in_tracks -min_distance 16 -corner_avoidance 20 -annealing

# aggiusto anche il fanout come specificato nel file sdf
set_dont_use [get_lib_cells */sg13g2_buf_1]
set_dont_use [get_lib_cells */sg13g2_buf_2]
set_dont_use [get_lib_cells */sg13g2_dlygate*]


repair_design

report_design_area

# verifica timing
estimate_parasitics -placement
set_propagated_clock clk
tee -file impl/results/placement_setup_time.rpt \
    { report_checks -path_delay max -digits 3 -format full_clock_expanded -field capacitance }

tee -file impl/results/placement_setup_time.rpt \
    { report_checks -path_delay min  -digits 3 -format full_clock_expanded }

# Ottimizzazione per aggiustare hold time
repair_timing -setup -verbose
repair_timing -hold -hold_margin 0.150 -verbose
tee -file impl/results/placement_hold_time.rpt \
    { report_checks -path_delay min  -digits 3 -format full_clock_expanded }

tee -file impl/results/placement_area.rpt { report_design_area }
# aggiorno il global placement dopo l'introduzione dei buffers
global_placement -density 0.90 -routability_driven -incremental

# placement dettagliato
detailed_placement
improve_placement -max_displacement 20
check_placement -verbose

unset_dont_use [get_lib_cells */sg13g2_buf_1]
unset_dont_use [get_lib_cells */sg13g2_buf_2]
unset_dont_use [get_lib_cells */sg13g2_dlygate*]


write_db "impl/results/placement.odb"

gui::show

exit

#############################################################################
