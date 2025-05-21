\\##############
\\## Settings ##
\\##############
tclmode
set_case_sensitivity on
set_lowpower_option -netlist_style logical
\\#Ignore identify_always_on_driver for RTL
vpx set rule handling CPF_DES10 -Ignore
\\#vpx set rule handling CPF_LIB41 -Ignore

\\###################
\\## Library Setup ##
\\###################
\\#LEF needed for power pin definition
read_lef_file \
../Library/lef/gsclib045_macro.lef \
../Library/lef/gsclib045_hvt_macro.lef

read_library -cpf ../DesignDataIn/cpf/sparc_exu_alu.cpf

\\##################
\\## Design Setup ##
\\##################
read_design -verilog2k -noelab \
../DesignDataIn/src/lib/u1/u1.behV \
../DesignDataIn/src/lib/m1/m1.behV \
../DesignDataIn/src/common/swrvr_clib.v \
../DesignDataIn/src/common/swrvr_dlib.v \
../DesignDataIn/src/rtl/sparc_exu_aluor32.v \
../DesignDataIn/src/rtl/sparc_exu_aluadder64.v \
../DesignDataIn/src/rtl/sparc_exu_aluspr.v \
../DesignDataIn/src/rtl/sparc_exu_alu_16eql.v \
../DesignDataIn/src/rtl/sparc_exu_alulogic.v \
../DesignDataIn/src/rtl/sparc_exu_aluzcmp64.v \
../DesignDataIn/src/rtl/sparc_exu_aluaddsub.v \
../DesignDataIn/src/rtl/sparc_exu_alu.v
elaborate_design -root sparc_exu_alu

report_floating_signals > ./reports/float.rpt
report_tied_signals > ./reports/tied.rpt

\\#########################
\\## Power Intent Checks ##
\\#########################
read_power_intent -pre_synthesis -cpf ../DesignDataIn/cpf/sparc_exu_alu.cpf
\\#commit_power_intent -insert_isolation -functional_insertion
commit_power_intent -functional_insertion
analyze_power_domain

#exit
