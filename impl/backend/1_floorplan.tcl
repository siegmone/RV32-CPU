# 1_floorplan.tcl

set NETLIST_FILE "impl/results/netlist_fe.v"
set TOP_MODULE "Processor"
set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"

set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"

set LEF_FILE_CELLS  "/vlsi/tech/ihp-sg13g2/lef/sg13g2_stdcell.lef"
set LEF_FILE_TECH  "/vlsi/tech/ihp-sg13g2/lef/sg13g2_tech.lef"

set TRACK_SCRIPT "/vlsi/tech/ihp-sg13g2/make_tracks.tcl"

read_liberty $LIB_FILE
read_lef $LEF_FILE_TECH
read_lef $LEF_FILE_CELLS

read_verilog $NETLIST_FILE
link_design $TOP_MODULE

read_sdc $CONSTRAINTS_FILE

# Argomenti di initialize_floorplan:
# Dobbiamo indicare le coordinate di:
# - core (dove verranno alloggiate le celle standard)
# - die (dove arriveranno i terminali del circuito)
# Il die è più grande del core (include una zona "cuscinetto" attorno al core)
#
# Forniremo le coordinate degli estremi (in basso a sinistra ed in alto a destra)
# del core e del die (espresse in micron).
#
# C'è un ulteriore parametro (-site) che determina l'altezza delle righe in cui allocare
# le standard-cell. E' definito nel file di tecnologia.

set L 680
set margin_x 1.44
set margin_y 3.78
set padding_x [expr $margin_x * 12]
set padding_y [expr $margin_y * 5]

set x0_die 0
set y0_die 0
set x0_core [expr $margin_x + $padding_x]
set y0_core [expr $margin_y + $padding_y]

set x1_die [expr 2*($margin_x + $padding_x) + $L]
set y1_die [expr 2*($margin_y + $padding_y) + $L]
set x1_core [expr $x0_core + $L]
set y1_core [expr $y0_core + $L]

puts "x0_core = $x0_core, y0_core = $y0_core"
puts "x1_core = $x1_core, y1_core = $y1_core"
puts "x0_die = $x0_die, y0_die = $y0_die"
puts "x1_die = $x1_die, y1_die = $y1_die"


initialize_floorplan -die_area "$x0_die $y0_die $x1_die $y1_die" -core_area "$x0_core $y0_core $x1_core $y1_core" -site CoreSite

source $TRACK_SCRIPT

tapcell -endcap_master sg13g2_decap_4  -halo_width_x 2 -halo_width_y 2

#### Griglia di alimentazione
# Definiamo innanzitutto i nomi dei segnali di alimentazione e di massa
# I pin delle celle standard si chiamano VDD e VSS e noi continuiamo a chiamarli allo stesso modo
add_global_connection -net VDD -pin_pattern VDD -power
add_global_connection -net VSS -pin_pattern VSS -ground
global_connect

set_voltage_domain -name CORE -power VDD -ground VSS

define_pdn_grid -name power_grid -voltage_domains CORE

add_pdn_stripe -grid power_grid -layer Metal1 -width {0.44} -followpins

# metal 5 vertical stripes (solves TopMetal1 to metal1 vias snapping issues)
add_pdn_stripe -grid power_grid -layer Metal5 \
    -width 0.8 -spacing 1.6 \
    -offset 5 -pitch 60 \

# vertical stripes
add_pdn_stripe -grid power_grid -layer TopMetal2  -width 2  -spacing 8 \
    -offset [expr $margin_x * 5] -pitch 50 -extend_to_boundary

# horizontal stripes
add_pdn_stripe -grid power_grid -layer TopMetal1  -width 2  -spacing 8 \
    -offset [expr $margin_y * 5] -pitch 50 -extend_to_boundary

# ring
add_pdn_ring -grid power_grid \
    -layers {TopMetal1 TopMetal2} \
    -widths {2 2} \
    -spacings {2 2} \
    -core_offsets {2 2} \
    -connect_to_pads

# vias
add_pdn_connect -grid power_grid -layers {Metal1 Metal5}
add_pdn_connect -grid power_grid -layers {Metal5 TopMetal1}
add_pdn_connect -grid power_grid -layers {TopMetal1 TopMetal2}

pdngen

check_power_grid -net VDD
check_power_grid -net VSS

tee -file impl/results/floorplan_area.rpt { report_design_area }
write_db "impl/results/floorplan.odb"

gui::show

exit
