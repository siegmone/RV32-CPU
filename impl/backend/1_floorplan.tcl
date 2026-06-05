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

#report_design_area

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

set L 590
set xm [expr 0.9 + $L]
set ym [expr 3.7 + $L]
set xtop [expr 0.9 + $xm]
set ytop [expr 3.7 + $ym]
puts "xm = $xm, ym = $ym"
puts "xtop = $xtop, ytop = $ytop"

initialize_floorplan -die_area "0 0 $xtop $ytop" -core_area "0.9 3.7 $xm $ym" -site CoreSite
report_design_area
source $TRACK_SCRIPT

tapcell   -endcap_master sg13g2_decap_4  -halo_width_x 2 -halo_width_y 2
report_design_area

#### Gliglia di alimentazione
# Definiamo innanzitutto i nomi dei segnali di alimentazione e di massa
# I pin delle celle standard si chiamano VDD e VSS e noi continuiamo a chiamarli allo stesso modo
add_global_connection -net VDD -pin_pattern VDD -power
add_global_connection -net VSS -pin_pattern VSS -ground
global_connect
set_voltage_domain -name CORE -power VDD -ground VSS
define_pdn_grid -name power_grid -voltage_domains CORE

add_pdn_stripe -grid power_grid -layer Metal1 -width {0.44} -followpins
pdngen

# Aggiungiamo quindi le stripe verticali. Utilizzo TopMetal2
add_pdn_stripe -grid power_grid -layer TopMetal2  -width 2  -spacing 8 \
                -offset 14 -pitch 99999 -extend_to_boundary
add_pdn_connect -grid power_grid -layers {Metal1 TopMetal2}
pdngen

check_power_grid -net VDD
check_power_grid -net VSS

write_db "impl/results/floorplan.odb"

