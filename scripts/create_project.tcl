# Vivado create project script

set project_name "vivado_project"
set project_dir "./build/vivado"
set part_name "xc7a35tcpg236-1" ; # Change to your target part (e.g., Basys 3)

# Create project
create_project $project_name $project_dir -part $part_name -force

# Add RTL sources
add_files [glob -nocomplain ./rtl/*.v]
add_files [glob -nocomplain ./rtl/*.sv]

# Add constraints
add_files -fileset constrs_1 [glob -nocomplain ./xdc/*.xdc]

# Add simulation sources
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 [glob -nocomplain ./tb/*.v]
add_files -fileset sim_1 [glob -nocomplain ./tb/*.sv]

# Set top module
set_property top top [current_fileset]
set_property top top_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created successfully."
