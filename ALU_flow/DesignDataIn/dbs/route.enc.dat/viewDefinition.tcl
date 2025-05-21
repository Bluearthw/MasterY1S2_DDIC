if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name gpdk045_bc_lib\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib\
    ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells_lvt.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/fast.cdb]
create_library_set -name gpdk045_wc_lib\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells.lib\
    ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells_lvt.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/slow.cdb]
create_op_cond -name bc_rc0_virtual -library_file ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib -P 1 -V 1.1 -T 0
create_op_cond -name wc_rc125_virtual -library_file ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells.lib -P 1 -V 0.9 -T 125
create_rc_corner -name rc0\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -T 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/rc0/qrcTechFile
create_rc_corner -name default_rc_corner\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0
create_rc_corner -name rc125\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -T 125\
   -qx_tech_file ${::IMEX::libVar}/mmmc/rc0/qrcTechFile
create_delay_corner -name AV_0100_wc_rc125_setup_dc\
   -library_set gpdk045_wc_lib\
   -opcond_library slow_vdd1v0\
   -opcond wc_rc125_virtual\
   -rc_corner rc125
update_delay_corner -name AV_0100_wc_rc125_setup_dc -power_domain TOP\
   -library_set gpdk045_wc_lib\
   -opcond_library slow_vdd1v0\
   -opcond wc_rc125_virtual
create_delay_corner -name AV_0100_bc_rc0_hold_dc\
   -library_set gpdk045_bc_lib\
   -opcond_library fast_vdd1v0\
   -opcond bc_rc0_virtual\
   -rc_corner rc0
update_delay_corner -name AV_0100_bc_rc0_hold_dc -power_domain TOP\
   -library_set gpdk045_bc_lib\
   -opcond_library fast_vdd1v0\
   -opcond bc_rc0_virtual
create_delay_corner -name AV_0100_wc_rc125_hold_dc\
   -library_set gpdk045_wc_lib\
   -opcond_library slow_vdd1v0\
   -opcond wc_rc125_virtual\
   -rc_corner rc125
update_delay_corner -name AV_0100_wc_rc125_hold_dc -power_domain TOP\
   -library_set gpdk045_wc_lib\
   -opcond_library slow_vdd1v0\
   -opcond wc_rc125_virtual
create_constraint_mode -name 0100_mode\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/0100_mode/0100_mode.sdc]
create_analysis_view -name AV_0100_wc_rc125_setup -constraint_mode 0100_mode -delay_corner AV_0100_wc_rc125_setup_dc -latency_file ${::IMEX::dataVar}/mmmc/views/AV_0100_wc_rc125_setup/latency.sdc
create_analysis_view -name AV_0100_wc_rc125_hold -constraint_mode 0100_mode -delay_corner AV_0100_wc_rc125_hold_dc
create_analysis_view -name AV_0100_bc_rc0_hold -constraint_mode 0100_mode -delay_corner AV_0100_bc_rc0_hold_dc -latency_file ${::IMEX::dataVar}/mmmc/views/AV_0100_bc_rc0_hold/latency.sdc
set_analysis_view -setup [list AV_0100_wc_rc125_setup] -hold [list AV_0100_bc_rc0_hold]
catch {set_interactive_constraint_mode [list 0100_mode] } 
