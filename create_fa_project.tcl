# TCL Script to create Full Adder 32-bit project
project_new -overwrite -revision full_adder_32bit "C:/Users/USER/Documents/MIPS_Project/full_adder/full_adder_32bit"

# Set project settings
set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C35F672C6
set_global_assignment -name TOP_LEVEL_ENTITY full_adder_32bit
set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.1"
set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:00:00 MAY 08, 2026"

# Add source file
set_global_assignment -name SYSTEMVERILOG_FILE "C:/Users/USER/Documents/MIPS_Project/full_adder_32bit.sv"

# Save and close
project_close
