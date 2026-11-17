#######LIBRARY CREATION##############

set link_library "/home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ss0p6v125c.db \
/home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v125c.db \
/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v125c.db \
/home1/14_nmts/14_nmts/stdcell_slvt/db_ccs/saed14slvt_ss0p6v125c.db \
/home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ss0p6vm40c.db \
/home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6vm40c.db \
/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6vm40c.db \
/home1/14_nmts/14_nmts/stdcell_slvt/db_ccs/saed14slvt_ss0p6vm40c.db \
/home1/14_nmts/14_nmts/stdcell_hvt/db_ccs/saed14hvt_ss0p6v25c.db \
/home1/14_nmts/14_nmts/stdcell_lvt/db_ccs/saed14lvt_ss0p6v25c.db \
/home1/14_nmts/14_nmts/stdcell_rvt/db_ccs/saed14rvt_ss0p6v25c.db \
/home1/14_nmts/14_nmts/stdcell_slvt/db_ccs/saed14slvt_ss0p6v25c.db"

create_lib -technology /home1/14_nmts/14_nmts/tech/milkyway/saed14nm_1p9m_mw.tf \
-ref_libs { /home1/14_nmts/14_nmts/stdcell_hvt/ndm/saed14hvt_frame_only.ndm \
/home1/14_nmts/14_nmts/stdcell_lvt/ndm/saed14lvt_frame_only.ndm \
/home1/14_nmts/14_nmts/stdcell_rvt/ndm/saed14rvt_frame_only.ndm \
/home1/14_nmts/14_nmts/stdcell_slvt/ndm/saed14slvt_frame_only.ndm \
/home1/WBPD20/GDebasisH/RISC_V_PNR/alu14.ndm} riscv3.dlib

#########READING NETLIST & SDC######
read_verilog ../scripts/msrv32_top.v
read_sdc ../scripts/msrv32_top.sdc
load_upf ../scripts/riscv.upf
commit_upf
set_voltage 0.6 -object_list VDD
set_voltage 0 -object_list VSS

#######Reading paracitics###############
read_parasitic_tech -name {new_model} -tlup {/home1/14_nmts/14_nmts/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus} -layermap {/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map}
read_parasitic_tech -name {new_model} -tlup {/home1/14_nmts/14_nmts/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus} -layermap {/home1/14_nmts/14_nmts/tech/star_rc/saed14nm_tf_itf_tluplus.map}
report_lib -parasitic_tech riscv3.dlib
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical
get_attribute [get_layers M?] routing_direction

############Applying MCMM constraints########
current_corner default
set_parasitic_parameters -early_spec new_model -late_spec new_model
set_process_number 0.99 -corners default
set_temperature 125 -corners default
set_voltage 0.6 -corners default
current_mode default
set_scenario_status default -active true -setup true -hold true -max_transition true -max_capacitance true -min_capacitance true -leakage_power true -dynamic_power true
current_scenario
#remove_terminals -force *

#########Floorplan#####
check_design -checks {dp_pre_floorplan}
initialize_floorplan -core_offset {10} -core_utilization {0.7} -side_ratio {1 1}
shape_blocks
create_placement -floorplan
#remove_placement
#remove_placement_blockages -all
#save_block -as risc/floorplan
set_block_pin_constraints -self -allowed_layers {M7 M8} -side {1 2}
place_pins -port [get_ports -filter direction==in] -self
set_block_pin_constraints -self -allowed_layers {M7 M8} -side {3 4}
place_pins -port [get_ports -filter direction==out] -self
remove_keepout_margins *
create_keepout_margin -outer {2 2 2 2} [get_cell ALU]
create_keepout_margin -type routing_blockage -outer {1 1 1 1} -layers {M1} [get_cell ALU] 
report_power
check_pin_placement
set_attribute [get_ports *] physical_status fixed
remove_placement_blockages -all
set_fixed_objects [get_cells -hierarchical -filter "is_hard_macro==true"]
save_block -as risc/floorplan
#legalize_placement

############Powerplan#############
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_regions -all
remove_pg_via_master_rules -all
remove_pg_strategy_via_rules -all
remove_routes -net_types {power ground} -ring -stripe -macro_pin_connect -lib_cell_pin_connect > /dev/null
connect_pg_net
connect_pg_net -net VDD [get_pins -hierarchical -quiet "*/VDD"]
connect_pg_net -net VSS [get_pins -hierarchical -quiet "*/VSS"]

set all_macros [get_cells -hierarchical -filter "is_hard_macro && !is_physical_only"]

##############PowerRings#################
create_pg_ring_pattern ring_pattern -horizontal_layer M8 -horizontal_spacing {0.5} -vertical_layer M7 -vertical_spacing {0.5} -side_width {{side: 1 2 3 4} {width: 0.5}} -via_rule {{intersection: all} {via_master: default}}
set_pg_strategy ring -core -pattern {{name: ring_pattern} {nets: {VDD VSS VDD VSS}} {offset: {0.25 0.25}}} -extension {{{side: 1} {nets: VDD} {direction:B} {stop: design_boundary_and_generate_pin}} {{side: 1} {nets: VSS} {stop: first_target}} {{side: 1} {nets: VSS} {direction:B} {stop: design_boundary_and_generate_pin}} {{side: 1} {nets: VDD} {stop: first_target}} {{side: 1} {nets: VDD VSS} {stop: first_target}}}
compile_pg -strategies ring

#######Powermesh###########
create_pg_mesh_pattern mesh_pattern -layers {{{vertical_layer: M6} {width: 0.10} {pitch: 6} {offset:2.0} {spacing: interleaving}} {{horizontal_layer: M5}
{width: 0.1} {pitch: 6} {offset:2.0} {spacing: interleaving}}}
set_pg_strategy M5M6_mesh -core -pattern { {name: mesh_pattern} {nets: VDD VSS} {offset_start: 1 1}} -extension {{direction: T B L R} {stop: outermost_ring}} -blockage { {macro_with_keepout: $all_macros} }
compile_pg -strategies M5M6_mesh

###########PowerRail###########
create_pg_std_cell_conn_pattern rail_pattern -layers M1 -rail_width 0.06
set ALU_MACRO [get_cells -hierarchical -quiet -filter "is_hard_macro && !is_physical_only"]
set_pg_strategy rail_1 -core -pattern { {name: rail_pattern} {nets: VDD VSS} } -blockage {{nets: {VDD VSS}} {macros: $ALU_MACRO}}
#set_pg_strategy rail_1 -core -pattern { {name: rail_pattern} {nets: VDD} } -blockage { {macro_with_keepout: $all_macros} }
#set_pg_strategy rail_2 -core -pattern { {name: rail_pattern} {nets: VDD} } -blockage { {macro_with_keepout: $all_macros} }
compile_pg -strategies {rail_1}

########Sanity_Check########
check_pg_connectivity
check_pg_drc
save_block -as risc/drc
check_pg_missing_vias
report_power
save_block
##########placement#############
reset_placement
set_app_options -list {place.coarse.max_density {0.6}}
set_app_options -list {place.coarse.continue_on_missing_scandef {true}}
create_placement -floorplan -congestion
set_fixed_objects [get_cells -hierarchical -filter "is_hard_macro==true"]
legalize_placement
set_dont_touch [get_lib_cells */*TIE*] false
set_lib_cell_purpose -include optimization [get_lib_cells */*TIE*]
create_placement -floorplan -congestion
legalize_placement
check_legality
set_attribute [get_lib_cells *lvt*/*] threshold_voltage_group LVT
report_constraints -all_violators
set_multi_vth_constraint -low_vt_percentage 8 -cost cell_count
place_opt -to final_opto
report_constraints -all_violators
connect_pg_net
check_pg_connectivity

save_block -as placement_completed

########CTS#######

check_design -checks pre_clock_tree_stage

# Identify and enable clock-tree-eligible cells (buffers/clock cells)
set CTS_CELLS [get_lib_cells "*/*CK* */*BUF_S_* */*CLK*"]
set_dont_touch $CTS_CELLS false
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts $CTS_CELLS

# Non-default routing rule for clock nets (wider/more-spaced)
create_routing_rule rm_2w2s -default_reference_rule \
    -multiplier_width 2 -multiplier_spacing 2
set_clock_routing_rules -net_type root -rule rm_2w2s \
    -min_routing_layer M2 -max_routing_layer M8

set_app_options -name cts.common.max_fanout -value 30

set_clock_tree_options -clocks [all_clocks] -target_latency 0.250 -target_skew 0.030

clock_opt

report_constraints -all_violators
report_clock_tree_options
report_clock_qor
report_qor -summary
report_timing -delay_type min
report_timing -delay_type max

save_block -as cts_completed

############Routing#######################
check_design -checks pre_route_stage
check_routability
set_app_options -name route.detail.timing_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
set_app_options -name route.global.timing_driven -value true

# Restrict routing layers
set_ignored_layers -max_routing_layer M7 -min_routing_layer M2
set_app_options -name route.common.global_min_layer_mode -value allow_pin_connection
set_app_options -name route.common.global_max_layer_mode -value soft

# Signal integrity (crosstalk) aware analysis
set_app_options -name time.si_enable_analysis -value true
set_app_options -name time.enable_si_timing_windows -value true
set_app_options -name time.enable_ccs_rcv_cap -value true

route_auto
save_block -as initial_route

route_opt
save_block -as route_done

######################Analyze/Validate the Output##############
write_script -force -format icc2 -output ../outputs/msrv32_top
write_parasitics -output ../outputs/msrv32_top_spef_generation
write_sdf ../outputs/msrv32_top.sdf
write_verilog ../outputs/msrv32_top.v
write_gds ../outputs/msrv32_top.gds
write_sdc -output ../outputs/msrv32_top.sdc
create_abstract
create_frame -block_all true
write_gds -compress -hierarchy all -long_names -keep_data_type ../outputs/msrv32_top.gds
save_block

