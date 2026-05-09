# TCL script to compile all projects

proc compile_project {proj_path top_entity} {
    puts "=== Compiling: $top_entity ==="
    project_open "$proj_path"

    # Run Analysis & Synthesis
    execute_module -tool map

    # Get compilation results
    set status [get_project_directory]
    puts "Project dir: $status"

    project_close
    puts "=== Done: $top_entity ==="
}

# Compile Full Adder
compile_project "C:/Users/USER/Documents/MIPS_Project/full_adder/full_adder_32bit" "full_adder_32bit"

# Compile MUX
compile_project "C:/Users/USER/Documents/MIPS_Project/mux4to1/mux4to1_32bit" "mux4to1_32bit"

# Compile ALU
compile_project "C:/Users/USER/Documents/MIPS_Project/alu/alu_32bit" "alu_32bit"

puts "All compilations complete"
