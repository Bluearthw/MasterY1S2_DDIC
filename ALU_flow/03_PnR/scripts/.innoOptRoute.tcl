source ./scripts/innoGlobal.tcl
###################
## Load Route dB ##
###################
source dbs/route.enc

##########################
## Setup Timing options ##
##########################
set_analysis_view \
 -setup {AV_fast_mode_wc_rc125_setup AV_eco_mode_wc_rc125_setup AV_sleep_mode_wc_rc125_setup} \
 -hold {AV_sleep_mode_bc_rc0_hold AV_eco_mode_bc_rc0_hold AV_fast_mode_bc_rc0_hold AV_sleep_mode_wc_rc125_hold AV_eco_mode_wc_rc125_hold AV_fast_mode_wc_rc125_hold}
 ##-hold {AV_sleep_mode_bc_rc0_hold AV_eco_mode_bc_rc0_hold AV_fast_mode_bc_rc0_hold}
source ../DesignDataIn/misc/innoTimingDerate.tcl

set_interactive_constraint_modes [ all_constraint_modes -active ]
set_propagated_clock [ all_clocks ]
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
createBasicPathGroups
get_path_groups *

setDelayCalMode -reset
setDelayCalMode -engine Aae -SIAware true
setDelayCalMode -equivalent_waveform_model_type ecsm -equivalent_waveform_model_propagation true

#set_false_path -to addsub/sub_dff_sw/q_reg[32]/D

#################
## SI settings ##
#################
setSIMode -reset
setSIMode -analysisType aae
setSIMode -detailedReports false
setSIMode -separate_delta_delay_on_data true
setSIMode -delta_delay_annotation_mode lumpedOnNet
setSIMode -num_si_iteration 3
setSIMode -enable_glitch_report true


#####################
## Routing options ##
#####################
setNanoRouteMode -quiet -routeInsertAntennaDiode true
setNanoRouteMode -quiet -routeAntennaCellName "ANTENNA"
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true

#############################
## Remove Std Filler Cells ##
#############################
setFillerMode -doDRC false -corePrefix FILL -core "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1"
deleteFiller

#############################
## Post Route Optimization ##
#############################
# Allow the usage of LVT cells for final setup fixing
set_dont_use [get_lib_cells *LVT] false
# Allow the usage of Delay Cells for hold fixing
set_dont_use   [get_lib_cells */DLY*] false
set_dont_touch [get_lib_cells */DLY*] false
## Fix Setup and Hold ##
optDesign -postRoute -setup -hold -outDir timingReports/optRoute -prefix optRouteSetupHold -expandedViews
#Is the hold clean ? If not an incremental fix can be usefull:
setOptMode -holdTargetSlack 0.075
optDesign -postRoute -hold -outDir timingReports/optRoute -prefix optRouteHoldIncr -expandedViews

#############################
## Insert Std Filler Cells ##
#############################
addFiller

############################
## Final Timing Reporting ##
############################
timeDesign -postRoute -outDir timingReports/optRoute -prefix optRouteSetupFinal -expandedViews
timeDesign -postRoute -hold -outDir timingReports/optRoute -prefix optRouteHoldFinal -expandedViews

########################################
## Export def file for QRC Extraction ##
########################################
defOut -floorplan -placement -netlist -routing ../DesignDataOut/optRoute.def.gz
saveNetlist ../DesignDataOut/optRoute.v -excludeLeafCell
saveNetlist ../DesignDataOut/optRoute.phys.v -excludeLeafCell -phys

#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign dbs/optRoute.enc

exit
