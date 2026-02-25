# switch.sdc 
# -------------------------------------------------------------------------


remove_sdc -design


# Period: 5.01 ns
create_clock -name "clk" -period 5.01 [get_ports clk]

# Set Clock Jitter 
set_clock_uncertainty -setup 0.15 [get_clocks clk]

# Input/Output Delays
# These define how long signals take to arrive from/leave to the outside world.
set_input_delay -max 0.2 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 0.2 -clock clk [all_outputs]

# -------------------------------------------------------------------------
