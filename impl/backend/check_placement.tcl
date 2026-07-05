set CONSTRAINTS_FILE "impl/backend/constraints_be.sdc"
set LIB_FILE "/vlsi/tech/ihp-sg13g2/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set RC_SCRIPT "/vlsi/tech/ihp-sg13g2/setRC.tcl"

read_liberty $LIB_FILE
read_db "impl/results/placement.odb"

read_sdc $CONSTRAINTS_FILE
source $RC_SCRIPT

gui::show

