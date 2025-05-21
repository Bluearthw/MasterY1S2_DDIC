\\##############
\\## Settings ##
\\##############
tclmode
set_case_sensitivity on
set_lowpower_option -netlist_style logical
\\#Ignore following rules as SI inputs of ret flops are floating
\\#vpx set rule handling CLP_STRC2 -Ignore
\\#Ignore identify_always_on_driver for RTL
vpx set rule handling CPF_DES10 -Ignore
\\#Ignore libraries pin definition mismatch
\\#vpx set rule handling CPF_LIB17 -Ignore

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
read_design -verilog -sensitive ../DesignDataIn/netlist/compile.v

report_floating_signals > ./reports/float.rpt
report_tied_signals > ./reports/tied.rpt

\\##########################
\\## Power Intent Checks ##
\\##########################
read_power_intent -pre_route -cpf ../DesignDataIn/cpf/sparc_exu_alu.cpf
commit_power_intent
analyze_power_domain

report_rule_check -verbose > ./reports/struct_check_summary.rpt
write_rule_check -replace ./reports/struct_check_full.rpt

\\#exit
