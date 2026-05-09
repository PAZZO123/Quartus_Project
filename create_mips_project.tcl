# TCL Script to create Single-Cycle MIPS Processor project
project_new -overwrite -revision mips_processor "C:/Users/USER/Documents/MIPS_Project/mips/mips_processor"

set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C35F672C6
set_global_assignment -name TOP_LEVEL_ENTITY mips_processor
set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.1"
set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:00:00 MAY 08, 2026"

# Add all source files
set_global_assignment -name SYSTEMVERILOG_FILE "C:/Users/USER/Documents/MIPS_Project/mips_processor.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "C:/Users/USER/Documents/MIPS_Project/alu_32bit.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "C:/Users/USER/Documents/MIPS_Project/alu_control.sv"

project_close
