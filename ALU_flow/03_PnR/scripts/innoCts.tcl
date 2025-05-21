###################
## Load Place dB ##
###################
source ./scripts/innoGlobal.tcl
source ../DesignDataIn/dbs/place.enc

##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_0100_wc_rc125_setup } -hold {AV_0100_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
source ../DesignDataIn/misc/innoTimingDerate.tcl


#########################
## ClockTree Synthesis ##
#########################
cleanupSpecifyClockTree
source ../DesignDataIn/cts/my_ctsSpec_ccopt.tcl
create_ccopt_clock_tree_spec -views {AV_0100_wc_rc125_setup AV_0100_bc_rc0_hold } -file ../DesignDataIn/cts/ctsSpec_ccopt.tcl
source ../DesignDataIn/cts/ctsSpec_ccopt.tcl
ccopt_design

###################
## Report Timing ##
###################
timeDesign -postCTS -numPaths 10 -outDir timingReports/cts 
timeDesign -postCTS -hold -numPaths 10 -outDir timingReports/cts


#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../DesignDataOut/cts.enc
saveDesign ../DesignDataIn/dbs/cts.enc
#exit
