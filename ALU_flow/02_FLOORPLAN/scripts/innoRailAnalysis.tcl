#######################
## Load floorplan dB ##
#######################
source ./scripts/innoGlobal.tcl
source ../DesignDataIn/dbs/floorplan.enc

##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_fast_mode_wc_rc125_setup} -hold {AV_eco_mode_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup

####################
## Fast Placement ##
####################
setPlaceMode -fp true
placeDesign -noPrePlaceOpt
refinePlace
fit
clearDrc

###########################################
## Pre Rail Analysis Structural Analysis ##
###########################################
verifyGeometry
#verifyConnectivity -noAntenna -noUnroutedNet
verifyPowerVia

####################
## Power Analysis ##
####################
set_power_analysis_mode -method static -analysis_view AV_fast_mode_wc_rc125_setup \
	-corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir ./PowerAnalysis
set_default_switching_activity -input_activity 0.75 -period 3.0 -global_activity 0.75
report_power -rail_analysis_format VS -outfile ./PowerAnalysis/sparc_exu_alu.rpt

######################################
## Setup Rail Analysis mode for VDD ##
######################################
set_rail_analysis_mode -method era_static -accuracy xd -power_grid_library {../Library/pgv/techonly.cl ../Library/pgv/stdcells.cl}

set_pg_nets -net VDD -voltage 1.080 -threshold [expr 1.080 * 0.975]
set_power_data -reset
set_power_data -format current -scale 1 PowerAnalysis/static_VDD.ptiavg
set_power_pads -reset
set_power_pads -net VDD -format xy -file ../DesignDataIn/misc/sparc_exu_alu.VDD.1point.pp
set_package -reset
set_package -spice {} -mapping {}
set_net_group -reset
set_advanced_rail_options -reset
analyze_rail -type net -results_directory ./ VDD

######################################
## Setup Rail Analysis mode for VSS ##
######################################
## MANUAL TASK
##############

###################################
## Analyze Rail Analysis Results ##
###################################
## MANUAL TASK
##############


#exit
