# --- run_BAD.tcl 

# 1. CLEANUP
file delete -force switch.dlib

# 2. SETUP
set_host_options -max_cores 4
set TECH_FILE "/data/synopsys/lib/saed32nm/ref/tech/saed32nm_1p9m.tf"

# 3. CREATE LIBRARY
create_lib -technology $TECH_FILE -ref_libs { \
    /data/synopsys/lib/saed32nm/ref/CLIBs/saed32_hvt.ndm \
    /data/synopsys/lib/saed32nm/ref/CLIBs/saed32_lvt.ndm \
    /data/synopsys/lib/saed32nm/ref/CLIBs/saed32_rvt.ndm \
} switch.dlib

read_parasitic_tech -tlu /data/synopsys/lib/saed32nm/ref/tech/saed32nm_1p9m_Cmax.lv.tluplus -name Cmax
read_parasitic_tech -tlu /data/synopsys/lib/saed32nm/ref/tech/saed32nm_1p9m_Cmin.lv.tluplus -name Cmin

# 4. READ DESIGN
analyze -format sverilog {port_if.sv arbiter.sv switch_port.sv switch_4port.sv}
elaborate switch_4port
set_top_module switch_4port

# 5. CONSTRAINTS
create_corner Fast; create_corner Slow
set_parasitics_parameters -early_spec Cmin -late_spec Cmin -corners {Fast}
set_parasitics_parameters -early_spec Cmax -late_spec Cmax -corners {Slow}
create_mode FUNC; current_mode FUNC
create_scenario -mode FUNC -corner Fast -name FUNC_Fast
create_scenario -mode FUNC -corner Slow -name FUNC_Slow
current_scenario FUNC_Fast; source ./switch.sdc
current_scenario FUNC_Slow; source ./switch.sdc

# --- OVERWRITE CLOCK FREQUENCY (manual checking) ---
# Target: ~200 MHz (Limit of Bad Design)
create_clock -name clk -period 5.01 [get_ports clk]
set_input_delay -max 0.2 -clock clk [all_inputs]
set_output_delay -max 0.2 -clock clk [all_outputs]
# ---------------------------------------------------

# 6. COMPILE (disable clock gating
puts "INFO: Disabling tool-inserted clock gating..."
set icg_lc [get_lib_cells -quiet -filter "is_integrated_clock_gating_cell==true"]
if {[sizeof_collection $icg_lc] > 0} {
  set_dont_use $icg_lc
} else {
  set icg_lc2 [get_lib_cells -quiet */*CGLP*] 
  if {[sizeof_collection $icg_lc2] > 0} {
    set_dont_use $icg_lc2 
  }
}

compile_fusion -to final_opto

# 7. GENERATE REPORTS
report_power > report_power_BAD.txt
report_area > report_area_BAD.txt
report_clock_gating > report_clock_gating_BAD.txt
report_timing > report_timing_BAD.txt

# 8. SAVE NETLIST
write_verilog -hierarchy all switch_4port_BAD.v
write_sdf switch_4port_BAD.sdf

exit
