#######################
## Load floorplan dB ##
#######################
source ./scripts/innoGlobal.tcl
source ../DesignDataIn/dbs/floorplan.enc

##########################
## Setup Timing options ##
##########################
set_analysis_view -setup {AV_0100_wc_rc125_setup} -hold {AV_0100_bc_rc0_hold}
setAnalysisMode -analysisType onChipVariation -cppr both -checkType setup
set_interactive_constraint_modes [ all_constraint_modes -active ]

#####################
## Timing Derating ##
#####################
source ../DesignDataIn/misc/innoTimingDerate.tcl

######################
## Place the Design ##
######################
#placeDesign -inPlaceOpt
place_opt_design
getTieHiLoMode
addTieHiLo -cell "TIEHI TIELO" -powerDomain TOP

###################
## Report Timing ##
###################
timeDesign -preCTS -outDir timingReports/place -prefix place
#timeDesign -preCTS -numPaths 10 -outDir timingReports/place -prefix place

#################
## Save Design ##
#################
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../DesignDataOut/place.enc
saveDesign ../DesignDataIn/dbs/place.enc
#exit
