# Script TCL per GTKWave
set varnames  [list]
set codifiche [list]

# Aggiunta segnali di primo livello (non enumerati)
gtkwave::addSignalsFromList tb_ALU.A
gtkwave::addSignalsFromList tb_ALU.B
gtkwave::addSignalsFromList tb_ALU.ALUControl
gtkwave::addSignalsFromList tb_ALU.Y
gtkwave::addSignalsFromList tb_ALU.Zero

# Espandi i nomi reali mostrati da GTKWave
for {set k 0} {$k < [llength $varnames]} {incr k} {
    set base [lindex $varnames $k]
    set enum [lindex $codifiche $k]
    
    # 1) rimuovi eventuali occorrenze (bus o bit)
    set vis [gtkwave::getDisplayedSignals]
    set already [lsearch -all -inline -glob $vis "${base}*"]
        if {[llength $already] > 0} {
        gtkwave::deleteSignalsFromList $already
    }

    # 2) aggiungi
    gtkwave::addSignalsFromList $base

    # 3) EVIDENZIA I NOMI REALI (non il pattern)
    set targets [lsearch -all -inline -glob [gtkwave::getDisplayedSignals] "${base}*"]
    if {[llength $targets] == 0} {
        continue
    }

    # 4) format/colore/enum
    gtkwave::highlightSignalsFromList $targets
    gtkwave::/Edit/Data_Format/Decimal
    gtkwave::/Edit/Color_Format/Yellow
    set which_f [gtkwave::setCurrentTranslateEnums $enum]
    gtkwave::installFileFilter $which_f
    gtkwave::/Edit/UnHighlight_All
}
# Zoom pieno sulla timeline
gtkwave::/Time/Zoom/Zoom_Full
