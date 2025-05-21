#############################
## Read libraries from CPF ##
#############################
read_power_intent -cpf  -module sparc_exu_alu ../DesignDataIn/cpf/sparc_exu_alu.cpf

####################
## Read RTL files ##
####################
set_attribute hdl_search_path ../DesignDataIn/src/ /

read_hdl {./lib/u1/u1.behV \
./lib/m1/m1.behV \
./common/swrvr_clib.v \
./common/swrvr_dlib.v \
./rtl/sparc_exu_aluor32.v \
./rtl/sparc_exu_aluadder64.v \
./rtl/sparc_exu_aluspr.v \
./rtl/sparc_exu_alu_16eql.v \
./rtl/sparc_exu_alulogic.v \
./rtl/sparc_exu_aluzcmp64.v \
./rtl/sparc_exu_aluaddsub.v \
./rtl/sparc_exu_alu.v \
}

###########################
## Enabling Clock Gating ##
###########################
set_attribute lp_insert_clock_gating  true /
#set_attribute lp_insert_clock_gating false /
set_dont_use [ get_lib_cells SDFF* ]

##########################
## Elaborate the design ##
##########################
elaborate sparc_exu_alu
uniquify /designs/sparc_exu_alu -verbose

##############################
## Define Clock Gating cell ##
##############################
set_attribute lp_clock_gating_cell [lindex [find / -libcell TLATNCAX4] 0] /designs/sparc_exu_alu

###############################
## Define switching activity ##
###############################
set_attribute lp_toggle_rate_unit /ns /
set_attribute lp_power_analysis_effort high /
set_attribute lp_asserted_probability 0.35 [find / -invert "ports_in/rclk" -port ports_in/*]
set_attribute lp_asserted_toggle_rate 0.5 [find / -invert "ports_in/rclk" -port ports_in/*]
#set_attribute lp_asserted_probability 0.5 [find -port "ports_in/rclk"]
#set_attribute lp_asserted_toggle_rate 0.666666667 [find -port "ports_in/rclk"]
#get_attribute lp_computed_toggle_rate [find -port "ports_in/rclk"]

#################################
## Power Optimization settings ##
#################################
set_attribute leakage_power_effort medium /
set_attribute lp_power_optimization_weight 0.95 /designs/sparc_exu_alu

###############
## Apply CPF ##
###############
apply_power_intent

################
## Commit CPF ##
################
#report low_power_cells -summary
commit_power_intent -design sparc_exu_alu
#report low_power_cells -summary

##############################
## Synthesis to GPDK045 lib ##
##############################
set_attribute syn_map_effort express
syn_map sparc_exu_alu

report timing -summary
report power -detail > reports/PowerBeforeOpt.rpt

##############################
## Incremental optimization ##
##############################
report power
set_attribute syn_opt_effort high
syn_opt sparc_exu_alu -incremental

report timing -summary
report power > reports/PowerAfterOpt.rpt

####################
## Some Reporting ##
####################
report area > ./reports/compile.area.rpt
report gates > ./reports/compile.gates.rpt
report clock_gating >  ./reports/compile.clock_gating.rpt
report power >  ./reports/compile.power.rpt

#sizeof_collection  [get_cells * -filter "ref_lib_cell_name !~ *HVT" -hierarchical -quiet]
#sizeof_collection  [get_cells * -filter "ref_lib_cell_name =~ *HVT" -hierarchical -quiet]

###############################
## Write out verilog netlist ##
###############################
write_hdl > ../DesignDataOut/compile.v
write_hdl > ../DesignDataIn/netlist/compile.v

#exit
