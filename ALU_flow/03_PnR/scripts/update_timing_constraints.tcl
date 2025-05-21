set_interactive_constraint_modes [all_constraint_modes -active]
update_constraint_mode -name sleep_mode -sdc [ list ../DesignDataIn/sdc/sparc_exu_alu_sleepmode.sdc]

set_analysis_view \
 -setup {AV_fast_mode_wc_rc125_setup AV_eco_mode_wc_rc125_setup AV_sleep_mode_wc_rc125_setup} \
 -hold {AV_sleep_mode_bc_rc0_hold AV_eco_mode_bc_rc0_hold AV_fast_mode_bc_rc0_hold AV_sleep_mode_wc_rc125_hold AV_eco_mode_wc_rc125_hold AV_fast_mode_wc_rc125_hold}
 
#  -hold {AV_sleep_mode_bc_rc0_hold AV_eco_mode_bc_rc0_hold AV_fast_mode_bc_rc0_hold}

set_interactive_constraint_modes [ all_constraint_modes -active ]
set_propagated_clock [ all_clocks ]
