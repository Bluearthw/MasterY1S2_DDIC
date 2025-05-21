################################################
## Setup physical libraries and input netlist ##
################################################
set defHierChar /
set init_cpf_file ../DesignDataIn/cpf/sparc_exu_alu.cpf
set init_lef_file {../Library/lef/gsclib045_tech.lef \
 ../Library/lef/gsclib045_macro.lef \
 ../Library/lef/gsclib045_hvt_macro.lef \
 ../Library/lef/gsclib045_lvt_macro.lef}
set init_pwr_net {VDD VDD1}
set init_gnd_net {VSS}
set init_top_cell sparc_exu_alu
set init_verilog ../DesignDataIn/netlist/compile.v

#################
## Read Design ##
#################
init_design
source ./scripts/innoGlobal.tcl

######################
## Create RC corner ##
######################
create_rc_corner -name rc125 \
 -qx_tech_file ../Library/qrc/qrcTechFile \
 -T 125

create_rc_corner -name rc0 \
 -qx_tech_file ../Library/qrc/qrcTechFile \
 -T 0


##########################
## Update Delay Corners ##
##########################
#Note: CPF syntax doesn't allow to define the extraction corner to be used for each Analysis View.
#We have to define this relationship through native encounter command
#Encounter will automatically create a delay_corner based on AV name => <AV_name>_dc
#We need to update this delay_corner with the extraction rc_corner we want
update_delay_corner -name AV_0100_wc_rc125_setup_dc \
    -rc_corner rc125

update_delay_corner -name AV_0100_wc_rc125_hold_dc \
    -rc_corner rc125

update_delay_corner -name AV_0100_bc_rc0_hold_dc \
    -rc_corner rc0

################################
## Select Active Timing Views ##
################################
set_analysis_view -setup {AV_0100_wc_rc125_setup} -hold {AV_0100_bc_rc0_hold}

#####################
## Timing Derating ##
#####################
source ../DesignDataIn/misc/innoTimingDerate.tcl

#########################
## Adding SI Libraries ##
#########################
update_library_set -name gpdk045_wc_lib -si [ list ../Library/cdb/slow.cdb ]
update_library_set -name gpdk045_bc_lib -si [ list ../Library/cdb/fast.cdb ]

###########################
## Read Power Intent CPF ##
###########################
read_power_intent -cpf ../DesignDataIn/cpf/sparc_exu_alu.cpf


#########################
## Commit Power Intent ##
#########################
commit_power_intent

###############################
## Floorplan initialization  ##
###############################
setPinConstraint -side {top bottom} -layer {M2}
setPinConstraint -side {right left} -layer {M3}
floorPlan -site CoreSite -s 230 204 30.0 30.0 30.0 30.0
loadIoFile ../DesignDataIn/misc/sparc_exu_alu.save.io

################################################
## Always-On TOP Power Domain RING generation ##
################################################
## MANUAL TASK
## ###########
##Create a VDD VSS Ring around the core
##Create a ring around the core for VDD and VSS in metal 5 (hor.) and metal 6 (vert.) 
##with a width of 12�m each and a spacing of 2.0�m between the wires on all sides and an offset to the core of 1.0 �m.
 addRing \
 -around default_power_domain \
 -nets {VDD VSS} \
 -layer {bottom M5 top M5 right M6 left M6} \
 -width 12 \
 -spacing 2 \
 -offset 1

################################
## Global VSS GRID generation ##
################################
# MANUAL TASK
#Create VSS Stripes on core
#Create VSS Stripes covering thecore in metal6 (vert.) with a width of 2.0�m and a spacing between the stripes of 12.0�m
addStripe \
 -set_to_set_distance 12 \
 -spacing 12 \
 -xleft_offset 5.05 \
 -direction vertical \
 -layer M6 \
 -width 2.3 \
 -nets VSS

set addsub_x1 [expr [dbGet top.FPlan.CoreBox_llx] + 19.35]
set addsub_y1 [expr [dbGet top.FPlan.CoreBox_ury] - 70]
set addsub_x2 [expr [dbGet top.FPlan.CoreBox_urx] - 20.95]
set addsub_y2 [expr [dbGet top.FPlan.CoreBox_ury] - 22]

addStripe \
 -set_to_set_distance 10.26 \
 -spacing 10.26 \
 -ybottom_offset 3.980 \
 -direction horizontal \
 -layer M5 \
 -width 2.3 \
 -nets VSS \
 -area_blockage "$addsub_x1 $addsub_y1 $addsub_x2 $addsub_y2"

#####################################################
## VDD1 stripes generation for Header Power Switch ##
#####################################################
addStripe -extend_to design_boundary \
 -set_to_set_distance 96 \
 -spacing 96 \
 -xleft_offset 69.7 \
 -direction vertical \
 -layer M4 \
 -width 5 \
 -area_blockage "0 [expr [dbGet top.FPlan.CoreBox_lly] + 70 + 5]  [dbGet top.fplan.box_urx] [dbGet top.fplan.box_ury] " \
 -nets VDD1



####################################################
## Always-On VDD TOP Power Domain GRID generation ##
####################################################
addStripe \
 -nets VDD \
 -direction vertical \
 -layer M6 \
 -xleft_offset 11.05 \
 -width 2.3 \
 -spacing 12 \
 -set_to_set_distance 12


#############################################
## M1 power rails prerouting for Std Cells ##
#############################################
#Allow connectin M1 rail between different PD
setSrouteMode -corePinJoinLimit 6                                       
sroute -connect corePin -nets VSS -allowJogging 0 -corePinMaxViaWidth 60
sroute -connect corePin -nets VDD -powerDomains TOP -allowJogging 0 -corePinMaxViaWidth 60

###################################################
## VDD via connections from stripes to switches ##
###################################################
sroute \
 -connect { secondaryPowerPin } \
 -layerChangeRange { M1 M6 } \
 -blockPinTarget { nearestTarget } \
 -secondaryPinRailVerticalStripeGrid { M6 0 0 } \
 -checkAlignedSecondaryPin 1 \
 -powerDomains { KERNEL_PSO } \
 -allowJogging 0 \
 -crossoverViaBottomLayer M1 \
 -secondaryPinRailLayer M6 \
 -allowLayerChange 1 \
 -secondaryPinNet { VDD } \
 -targetViaTopLayer M6 \
 -crossoverViaTopLayer M6 \
 -targetViaBottomLayer M1 \
 -nets { VDD } \
 -viaConnectToShape {stripe}

###############
## Reporting ##
###############
timeDesign -prePlace -outDir timingReports -prefix floorplan
report_timing -format {instance pin cell net  load slew delay arrival}

timeDesign -prePlace -expandedViews -numPaths 10 -outDir timingReports -prefix floorplan
timeDesign -prePlace -hold -expandedViews -numPaths 10 -outDir timingReports -prefix floorplan

reportGateCount -stdCellOnly -outfile ./reports/stdGateCount.rpt
analyzeFloorplan -outfile ./reports/AnalyzeFloorplan.rpt

##########################
## Check DRC		##
##########################
verifyGeometry

##########################
## Save Design and exit ##
##########################
clearDrc
foreach mode [ all_constraint_modes ] {
    eval "update_constraint_mode -name $mode -sdc \"[ get_constraint_mode  $mode -sdc_files ]\""
}
saveDesign ../DesignDataOut/floorplan.enc
saveDesign ../DesignDataIn/dbs/floorplan.enc
#exit
