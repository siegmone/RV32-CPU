# File di vincoli per la sintesi

set_cmd_units -time ns -capacitance fF

create_clock -name cpu_clock  -period 9.5 clk
set_clock_transition  0.050 cpu_clock

set_input_delay  -clock cpu_clock 0.5  [all_inputs -no_clocks]
set_output_delay -clock cpu_clock 0.5  [all_outputs ]

set_load 3.9 [all_outputs]
set_driving_cell -lib_cell sg13g2_inv_2 [all_inputs -no_clocks]

set_max_fanout 16 [current_design]
set_max_capacitance 80  [current_design]

