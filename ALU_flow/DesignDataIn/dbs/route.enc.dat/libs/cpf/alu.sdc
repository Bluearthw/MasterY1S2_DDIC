set clock_period_core 4.0
create_clock [get_ports rclk]  -period $clock_period_core  -name RCLK
set_clock_uncertainty 0.025  -setup [get_clocks RCLK]
set_clock_uncertainty 0.050  -hold [get_clocks RCLK]
set_clock_transition -fall 0.04 [get_clocks RCLK]
set_clock_transition -rise 0.04 [get_clocks RCLK]

group_path -name "reg2reg" -critical_range 0.1 -from [ all_registers -clock_pins ] -to [ all_registers -data_pins ]
group_path -name "in2reg"  -from [remove_from_collection [all_inputs] {nrestore rclk}] -to [ all_registers -data_pins ]
group_path -name "reg2out" -from [ all_registers -clock_pins ] -to [all_outputs]

set_input_delay 0.1 -clock RCLK [remove_from_collection [all_inputs] {rclk nrestore}]
set_output_delay 0.1 -clock RCLK  [remove_from_collection [all_outputs] {nsleep_out alu_ecl_cout64_e_l alu_ecl_zhigh_e}]
#set_input_transition 1.0 [get_ports nrestore]
set_input_transition 0.2 [all_inputs]

