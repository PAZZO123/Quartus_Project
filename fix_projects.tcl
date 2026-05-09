# Fix all projects to use Cyclone IV E device family

proc fix_project {proj_path revision} {
    puts "Fixing: $proj_path"
    project_open -revision $revision "$proj_path"
    set_global_assignment -name FAMILY "Cyclone IV E"
    set_global_assignment -name DEVICE EP4CE115F29C7
    project_close
    puts "Fixed: $proj_path"
}

fix_project "C:/Users/USER/Documents/MIPS_Project/full_adder/full_adder_32bit" "full_adder_32bit"
fix_project "C:/Users/USER/Documents/MIPS_Project/mux4to1/mux4to1_32bit" "mux4to1_32bit"
fix_project "C:/Users/USER/Documents/MIPS_Project/alu/alu_32bit" "alu_32bit"
fix_project "C:/Users/USER/Documents/MIPS_Project/mips/mips_processor" "mips_processor"

puts "All projects updated to Cyclone IV E"
