#################
## Load CTS dB ##
#################
source ./scripts/innoGlobal.tcl
source ../DesignDataIn/dbs/cts.enc

##########################
## Setup Timing options ##
##########################
set_analysis_view -setup { AV_0100_wc_rc125_setup} -hold {AV_0100_bc_rc0_hold}
set_interactive_constraint_modes [ all_constraint_modes -active ]
set_propagated_clock [ all_clocks ]
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
source ../DesignDataIn/misc/innoTimingDerate.tcl

#############################
## Insert Std Filler Cells ##
#############################
setFillerMode -doDRC false -corePrefix FILL -core "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1"
addFiller

#####################
## Routing options ##
#####################
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -routeAntennaCellName "ANTENNA"
## MANUAL TASK
##############
#?Enabling timing Driven Routing?

########################################
## Secondary power pins power routing ##
########################################
#No level shifters

##################
## Route Design ##
##################
routeDesign

###################
## Report timing ##
###################
timeDesign -postRoute -numPaths 10 -outDir timingReports/route -prefix route

########################################
## Export def file for QRC Extraction ##
########################################
defOut -floorplan -placement -netlist -routing ../DesignDataOut/route.def.gz

#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../DesignDataOut/route.enc
saveDesign ../DesignDataIn/dbs/route.enc
#exit
