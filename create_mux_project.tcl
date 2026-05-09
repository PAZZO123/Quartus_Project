# TCL Script to create 4-to-1 MUX 32-bit project
project_new -overwrite -revision mux4to1_32bit "C:/Users/USER/Documents/MIPS_Project/mux4to1/mux4to1_32bit"

set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C35F672C6
set_global_assignment -name TOP_LEVEL_ENTITY mux4to1_32bit
set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.1"
set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:00:00 MAY 08, 2026"

set_global_assignment -name SYSTEMVERILOG_FILE "C:/Users/USER/Documents/MIPS_Project/mux4to1_32bit.sv"

project_close
