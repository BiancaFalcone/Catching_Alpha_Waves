
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: mb1_lmb
proc create_hier_cell_mb1_lmb { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mb1_lmb() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 lmb_bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create instance: lmb_bram_if_cntlr, and set properties
  set lmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 lmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
CONFIG.C_NUM_LMB {2} \
 ] $lmb_bram_if_cntlr

  # Create interface connections
  connect_bd_intf_net -intf_net Conn [get_bd_intf_pins dlmb_v10/LMB_Sl_0] [get_bd_intf_pins lmb_bram_if_cntlr/SLMB1]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins BRAM_PORTB] [get_bd_intf_pins lmb_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net lmb_bram_if_cntlr_BRAM_PORT [get_bd_intf_pins lmb_bram/BRAM_PORTA] [get_bd_intf_pins lmb_bram_if_cntlr/BRAM_PORT]
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_v10/LMB_Sl_0] [get_bd_intf_pins lmb_bram_if_cntlr/SLMB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_v10/SYS_Rst] [get_bd_pins lmb_bram_if_cntlr/LMB_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk] [get_bd_pins lmb_bram_if_cntlr/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mb_JE
proc create_hier_cell_mb_JE { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mb_JE() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_LITE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI1

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 7 -to 0 pmod2sw_data_in
  create_bd_pin -dir I -from 0 -to 0 s_axi_aresetn
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_data_out
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_tri_out

  # Create instance: mb4_PMOD_IO_Switch_IP, and set properties
  set mb4_PMOD_IO_Switch_IP [ create_bd_cell -type ip -vlnv xilinx.com:user:PMOD_IO_Switch_IP:1.0 mb4_PMOD_IO_Switch_IP ]

  # Create instance: mb4_gpio, and set properties
  set mb4_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 mb4_gpio ]
  set_property -dict [ list \
CONFIG.C_GPIO_WIDTH {8} \
 ] $mb4_gpio

  # Create instance: mb4_iic, and set properties
  set mb4_iic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 mb4_iic ]

  # Create instance: mb4_spi, and set properties
  set mb4_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 mb4_spi ]
  set_property -dict [ list \
CONFIG.C_USE_STARTUP {0} \
 ] $mb4_spi

  # Create interface connections
  connect_bd_intf_net -intf_net AXI_LITE_1 [get_bd_intf_pins AXI_LITE] [get_bd_intf_pins mb4_spi/AXI_LITE]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins mb4_PMOD_IO_Switch_IP/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI1_1 [get_bd_intf_pins S_AXI1] [get_bd_intf_pins mb4_iic/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins mb4_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net PMOD_IO_Switch_IP_0_miso_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/miso_i_in] [get_bd_pins mb4_spi/io1_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_mosi_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/mosi_i_in] [get_bd_pins mb4_spi/io0_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_scl_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/scl_i_in] [get_bd_pins mb4_iic/scl_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sda_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/sda_i_in] [get_bd_pins mb4_iic/sda_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_spick_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/spick_i_in] [get_bd_pins mb4_spi/sck_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_ss_i_in [get_bd_pins mb4_PMOD_IO_Switch_IP/ss_i_in] [get_bd_pins mb4_spi/ss_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pl_data_in [get_bd_pins mb4_PMOD_IO_Switch_IP/sw2pl_data_in] [get_bd_pins mb4_gpio/gpio_io_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_data_out [get_bd_pins sw2pmod_data_out] [get_bd_pins mb4_PMOD_IO_Switch_IP/sw2pmod_data_out]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_tri_out [get_bd_pins sw2pmod_tri_out] [get_bd_pins mb4_PMOD_IO_Switch_IP/sw2pmod_tri_out]
  connect_bd_net -net mb1_gpio_gpio_io_o [get_bd_pins mb4_PMOD_IO_Switch_IP/pl2sw_data_o] [get_bd_pins mb4_gpio/gpio_io_o]
  connect_bd_net -net mb1_gpio_gpio_io_t [get_bd_pins mb4_PMOD_IO_Switch_IP/pl2sw_tri_o] [get_bd_pins mb4_gpio/gpio_io_t]
  connect_bd_net -net mb1_iic_scl_o [get_bd_pins mb4_PMOD_IO_Switch_IP/scl_o_in] [get_bd_pins mb4_iic/scl_o]
  connect_bd_net -net mb1_iic_scl_t [get_bd_pins mb4_PMOD_IO_Switch_IP/scl_t_in] [get_bd_pins mb4_iic/scl_t]
  connect_bd_net -net mb1_iic_sda_o [get_bd_pins mb4_PMOD_IO_Switch_IP/sda_o_in] [get_bd_pins mb4_iic/sda_o]
  connect_bd_net -net mb1_iic_sda_t [get_bd_pins mb4_PMOD_IO_Switch_IP/sda_t_in] [get_bd_pins mb4_iic/sda_t]
  connect_bd_net -net mb1_spi_io0_o [get_bd_pins mb4_PMOD_IO_Switch_IP/mosi_o_in] [get_bd_pins mb4_spi/io0_o]
  connect_bd_net -net mb1_spi_io0_t [get_bd_pins mb4_PMOD_IO_Switch_IP/mosi_t_in] [get_bd_pins mb4_spi/io0_t]
  connect_bd_net -net mb1_spi_io1_o [get_bd_pins mb4_PMOD_IO_Switch_IP/miso_o_in] [get_bd_pins mb4_spi/io1_o]
  connect_bd_net -net mb1_spi_io1_t [get_bd_pins mb4_PMOD_IO_Switch_IP/miso_t_in] [get_bd_pins mb4_spi/io1_t]
  connect_bd_net -net mb1_spi_sck_o [get_bd_pins mb4_PMOD_IO_Switch_IP/spick_o_in] [get_bd_pins mb4_spi/sck_o]
  connect_bd_net -net mb1_spi_sck_t [get_bd_pins mb4_PMOD_IO_Switch_IP/spick_t_in] [get_bd_pins mb4_spi/sck_t]
  connect_bd_net -net mb1_spi_ss_o [get_bd_pins mb4_PMOD_IO_Switch_IP/ss_o_in] [get_bd_pins mb4_spi/ss_o]
  connect_bd_net -net mb1_spi_ss_t [get_bd_pins mb4_PMOD_IO_Switch_IP/ss_t_in] [get_bd_pins mb4_spi/ss_t]
  connect_bd_net -net pmod2sw_data_in_1 [get_bd_pins pmod2sw_data_in] [get_bd_pins mb4_PMOD_IO_Switch_IP/pmod2sw_data_in]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins mb4_PMOD_IO_Switch_IP/s00_axi_aclk] [get_bd_pins mb4_gpio/s_axi_aclk] [get_bd_pins mb4_iic/s_axi_aclk] [get_bd_pins mb4_spi/ext_spi_clk] [get_bd_pins mb4_spi/s_axi_aclk]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins mb4_PMOD_IO_Switch_IP/s00_axi_aresetn] [get_bd_pins mb4_gpio/s_axi_aresetn] [get_bd_pins mb4_iic/s_axi_aresetn] [get_bd_pins mb4_spi/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mb_JD
proc create_hier_cell_mb_JD { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mb_JD() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_LITE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI1

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 7 -to 0 pmod2sw_data_in
  create_bd_pin -dir I -from 0 -to 0 s00_axi_aresetn
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_data_out
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_tri_out

  # Create instance: mb3_PMOD_IO_Switch_IP, and set properties
  set mb3_PMOD_IO_Switch_IP [ create_bd_cell -type ip -vlnv xilinx.com:user:PMOD_IO_Switch_IP:1.0 mb3_PMOD_IO_Switch_IP ]

  # Create instance: mb3_gpio, and set properties
  set mb3_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 mb3_gpio ]
  set_property -dict [ list \
CONFIG.C_GPIO_WIDTH {8} \
 ] $mb3_gpio

  # Create instance: mb3_iic, and set properties
  set mb3_iic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 mb3_iic ]

  # Create instance: mb3_spi, and set properties
  set mb3_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 mb3_spi ]
  set_property -dict [ list \
CONFIG.C_USE_STARTUP {0} \
 ] $mb3_spi

  # Create interface connections
  connect_bd_intf_net -intf_net AXI_LITE_1 [get_bd_intf_pins AXI_LITE] [get_bd_intf_pins mb3_spi/AXI_LITE]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins mb3_PMOD_IO_Switch_IP/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI1_1 [get_bd_intf_pins S_AXI1] [get_bd_intf_pins mb3_iic/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins mb3_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net PMOD_IO_Switch_IP_0_miso_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/miso_i_in] [get_bd_pins mb3_spi/io1_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_mosi_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/mosi_i_in] [get_bd_pins mb3_spi/io0_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_scl_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/scl_i_in] [get_bd_pins mb3_iic/scl_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sda_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/sda_i_in] [get_bd_pins mb3_iic/sda_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_spick_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/spick_i_in] [get_bd_pins mb3_spi/sck_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_ss_i_in [get_bd_pins mb3_PMOD_IO_Switch_IP/ss_i_in] [get_bd_pins mb3_spi/ss_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pl_data_in [get_bd_pins mb3_PMOD_IO_Switch_IP/sw2pl_data_in] [get_bd_pins mb3_gpio/gpio_io_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_data_out [get_bd_pins sw2pmod_data_out] [get_bd_pins mb3_PMOD_IO_Switch_IP/sw2pmod_data_out]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_tri_out [get_bd_pins sw2pmod_tri_out] [get_bd_pins mb3_PMOD_IO_Switch_IP/sw2pmod_tri_out]
  connect_bd_net -net mb1_gpio_gpio_io_o [get_bd_pins mb3_PMOD_IO_Switch_IP/pl2sw_data_o] [get_bd_pins mb3_gpio/gpio_io_o]
  connect_bd_net -net mb1_gpio_gpio_io_t [get_bd_pins mb3_PMOD_IO_Switch_IP/pl2sw_tri_o] [get_bd_pins mb3_gpio/gpio_io_t]
  connect_bd_net -net mb1_iic_scl_o [get_bd_pins mb3_PMOD_IO_Switch_IP/scl_o_in] [get_bd_pins mb3_iic/scl_o]
  connect_bd_net -net mb1_iic_scl_t [get_bd_pins mb3_PMOD_IO_Switch_IP/scl_t_in] [get_bd_pins mb3_iic/scl_t]
  connect_bd_net -net mb1_iic_sda_o [get_bd_pins mb3_PMOD_IO_Switch_IP/sda_o_in] [get_bd_pins mb3_iic/sda_o]
  connect_bd_net -net mb1_iic_sda_t [get_bd_pins mb3_PMOD_IO_Switch_IP/sda_t_in] [get_bd_pins mb3_iic/sda_t]
  connect_bd_net -net mb1_spi_io0_o [get_bd_pins mb3_PMOD_IO_Switch_IP/mosi_o_in] [get_bd_pins mb3_spi/io0_o]
  connect_bd_net -net mb1_spi_io0_t [get_bd_pins mb3_PMOD_IO_Switch_IP/mosi_t_in] [get_bd_pins mb3_spi/io0_t]
  connect_bd_net -net mb1_spi_io1_o [get_bd_pins mb3_PMOD_IO_Switch_IP/miso_o_in] [get_bd_pins mb3_spi/io1_o]
  connect_bd_net -net mb1_spi_io1_t [get_bd_pins mb3_PMOD_IO_Switch_IP/miso_t_in] [get_bd_pins mb3_spi/io1_t]
  connect_bd_net -net mb1_spi_sck_o [get_bd_pins mb3_PMOD_IO_Switch_IP/spick_o_in] [get_bd_pins mb3_spi/sck_o]
  connect_bd_net -net mb1_spi_sck_t [get_bd_pins mb3_PMOD_IO_Switch_IP/spick_t_in] [get_bd_pins mb3_spi/sck_t]
  connect_bd_net -net mb1_spi_ss_o [get_bd_pins mb3_PMOD_IO_Switch_IP/ss_o_in] [get_bd_pins mb3_spi/ss_o]
  connect_bd_net -net mb1_spi_ss_t [get_bd_pins mb3_PMOD_IO_Switch_IP/ss_t_in] [get_bd_pins mb3_spi/ss_t]
  connect_bd_net -net pmod2sw_data_in_1 [get_bd_pins pmod2sw_data_in] [get_bd_pins mb3_PMOD_IO_Switch_IP/pmod2sw_data_in]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins mb3_PMOD_IO_Switch_IP/s00_axi_aclk] [get_bd_pins mb3_gpio/s_axi_aclk] [get_bd_pins mb3_iic/s_axi_aclk] [get_bd_pins mb3_spi/ext_spi_clk] [get_bd_pins mb3_spi/s_axi_aclk]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins s00_axi_aresetn] [get_bd_pins mb3_PMOD_IO_Switch_IP/s00_axi_aresetn] [get_bd_pins mb3_gpio/s_axi_aresetn] [get_bd_pins mb3_iic/s_axi_aresetn] [get_bd_pins mb3_spi/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mb_JC
proc create_hier_cell_mb_JC { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mb_JC() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_LITE
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI1

  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 7 -to 0 pmod2sw_data_in
  create_bd_pin -dir I -from 0 -to 0 s_axi_aresetn
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_data_out
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_tri_out

  # Create instance: mb2_PMOD_IO_Switch_IP, and set properties
  set mb2_PMOD_IO_Switch_IP [ create_bd_cell -type ip -vlnv xilinx.com:user:PMOD_IO_Switch_IP:1.0 mb2_PMOD_IO_Switch_IP ]

  # Create instance: mb2_gpio, and set properties
  set mb2_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 mb2_gpio ]
  set_property -dict [ list \
CONFIG.C_GPIO_WIDTH {8} \
 ] $mb2_gpio

  # Create instance: mb2_iic, and set properties
  set mb2_iic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 mb2_iic ]

  # Create instance: mb2_spi, and set properties
  set mb2_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 mb2_spi ]
  set_property -dict [ list \
CONFIG.C_USE_STARTUP {0} \
 ] $mb2_spi

  # Create interface connections
  connect_bd_intf_net -intf_net AXI_LITE_1 [get_bd_intf_pins AXI_LITE] [get_bd_intf_pins mb2_spi/AXI_LITE]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins mb2_PMOD_IO_Switch_IP/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI1_1 [get_bd_intf_pins S_AXI1] [get_bd_intf_pins mb2_iic/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins mb2_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net PMOD_IO_Switch_IP_0_miso_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/miso_i_in] [get_bd_pins mb2_spi/io1_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_mosi_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/mosi_i_in] [get_bd_pins mb2_spi/io0_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_scl_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/scl_i_in] [get_bd_pins mb2_iic/scl_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sda_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/sda_i_in] [get_bd_pins mb2_iic/sda_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_spick_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/spick_i_in] [get_bd_pins mb2_spi/sck_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_ss_i_in [get_bd_pins mb2_PMOD_IO_Switch_IP/ss_i_in] [get_bd_pins mb2_spi/ss_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pl_data_in [get_bd_pins mb2_PMOD_IO_Switch_IP/sw2pl_data_in] [get_bd_pins mb2_gpio/gpio_io_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_data_out [get_bd_pins sw2pmod_data_out] [get_bd_pins mb2_PMOD_IO_Switch_IP/sw2pmod_data_out]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_tri_out [get_bd_pins sw2pmod_tri_out] [get_bd_pins mb2_PMOD_IO_Switch_IP/sw2pmod_tri_out]
  connect_bd_net -net mb1_gpio_gpio_io_o [get_bd_pins mb2_PMOD_IO_Switch_IP/pl2sw_data_o] [get_bd_pins mb2_gpio/gpio_io_o]
  connect_bd_net -net mb1_gpio_gpio_io_t [get_bd_pins mb2_PMOD_IO_Switch_IP/pl2sw_tri_o] [get_bd_pins mb2_gpio/gpio_io_t]
  connect_bd_net -net mb1_iic_scl_o [get_bd_pins mb2_PMOD_IO_Switch_IP/scl_o_in] [get_bd_pins mb2_iic/scl_o]
  connect_bd_net -net mb1_iic_scl_t [get_bd_pins mb2_PMOD_IO_Switch_IP/scl_t_in] [get_bd_pins mb2_iic/scl_t]
  connect_bd_net -net mb1_iic_sda_o [get_bd_pins mb2_PMOD_IO_Switch_IP/sda_o_in] [get_bd_pins mb2_iic/sda_o]
  connect_bd_net -net mb1_iic_sda_t [get_bd_pins mb2_PMOD_IO_Switch_IP/sda_t_in] [get_bd_pins mb2_iic/sda_t]
  connect_bd_net -net mb1_spi_io0_o [get_bd_pins mb2_PMOD_IO_Switch_IP/mosi_o_in] [get_bd_pins mb2_spi/io0_o]
  connect_bd_net -net mb1_spi_io0_t [get_bd_pins mb2_PMOD_IO_Switch_IP/mosi_t_in] [get_bd_pins mb2_spi/io0_t]
  connect_bd_net -net mb1_spi_io1_o [get_bd_pins mb2_PMOD_IO_Switch_IP/miso_o_in] [get_bd_pins mb2_spi/io1_o]
  connect_bd_net -net mb1_spi_io1_t [get_bd_pins mb2_PMOD_IO_Switch_IP/miso_t_in] [get_bd_pins mb2_spi/io1_t]
  connect_bd_net -net mb1_spi_sck_o [get_bd_pins mb2_PMOD_IO_Switch_IP/spick_o_in] [get_bd_pins mb2_spi/sck_o]
  connect_bd_net -net mb1_spi_sck_t [get_bd_pins mb2_PMOD_IO_Switch_IP/spick_t_in] [get_bd_pins mb2_spi/sck_t]
  connect_bd_net -net mb1_spi_ss_o [get_bd_pins mb2_PMOD_IO_Switch_IP/ss_o_in] [get_bd_pins mb2_spi/ss_o]
  connect_bd_net -net mb1_spi_ss_t [get_bd_pins mb2_PMOD_IO_Switch_IP/ss_t_in] [get_bd_pins mb2_spi/ss_t]
  connect_bd_net -net pmod2sw_data_in_1 [get_bd_pins pmod2sw_data_in] [get_bd_pins mb2_PMOD_IO_Switch_IP/pmod2sw_data_in]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins mb2_PMOD_IO_Switch_IP/s00_axi_aclk] [get_bd_pins mb2_gpio/s_axi_aclk] [get_bd_pins mb2_iic/s_axi_aclk] [get_bd_pins mb2_spi/ext_spi_clk] [get_bd_pins mb2_spi/s_axi_aclk]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins mb2_PMOD_IO_Switch_IP/s00_axi_aresetn] [get_bd_pins mb2_gpio/s_axi_aresetn] [get_bd_pins mb2_iic/s_axi_aresetn] [get_bd_pins mb2_spi/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mb_JB
proc create_hier_cell_mb_JB { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mb_JB() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTB
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mbdebug_rtl:3.0 DEBUG
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M07_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M08_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M09_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M10_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M11_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M12_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M13_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M14_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M15_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M16_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M17_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M18_AXI

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 -type rst M04_ARESETN
  create_bd_pin -dir I -from 0 -to 0 -type rst aux_reset_in
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -from 0 -to 0 -type rst ext_reset_in
  create_bd_pin -dir I -type rst mb_debug_sys_rst
  create_bd_pin -dir O -from 0 -to 0 peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 peripheral_aresetn1
  create_bd_pin -dir O -from 0 -to 0 peripheral_aresetn2
  create_bd_pin -dir I -from 7 -to 0 pmod2sw_data_in
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_data_out
  create_bd_pin -dir O -from 7 -to 0 sw2pmod_tri_out

  # Create instance: mb1_PMOD_IO_Switch_IP, and set properties
  set mb1_PMOD_IO_Switch_IP [ create_bd_cell -type ip -vlnv xilinx.com:user:PMOD_IO_Switch_IP:1.0 mb1_PMOD_IO_Switch_IP ]

  # Create instance: mb1_gpio, and set properties
  set mb1_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 mb1_gpio ]
  set_property -dict [ list \
CONFIG.C_GPIO_WIDTH {8} \
 ] $mb1_gpio

  # Create instance: mb1_iic, and set properties
  set mb1_iic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 mb1_iic ]

  # Create instance: mb1_lmb
  create_hier_cell_mb1_lmb $hier_obj mb1_lmb

  # Create instance: mb1_spi, and set properties
  set mb1_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 mb1_spi ]
  set_property -dict [ list \
CONFIG.C_USE_STARTUP {0} \
 ] $mb1_spi

  # Create instance: mb_1, and set properties
  set mb_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.5 mb_1 ]
  set_property -dict [ list \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {1} \
CONFIG.C_I_LMB {1} \
 ] $mb_1

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {19} \
 ] $microblaze_0_axi_periph

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]
  set_property -dict [ list \
CONFIG.C_AUX_RESET_HIGH {1} \
 ] $rst_clk_wiz_1_100M

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M04_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins M05_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins M06_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins BRAM_PORTB] [get_bd_intf_pins mb1_lmb/BRAM_PORTB]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins mb_1/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins mb1_spi/AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins mb1_iic/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins mb1_PMOD_IO_Switch_IP/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins mb1_gpio/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins M07_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins M08_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins M09_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M10_AXI [get_bd_intf_pins M10_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M11_AXI [get_bd_intf_pins M11_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M11_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M12_AXI [get_bd_intf_pins M12_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M12_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M13_AXI [get_bd_intf_pins M13_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M13_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M14_AXI [get_bd_intf_pins M14_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M14_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M15_AXI [get_bd_intf_pins M15_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M15_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M16_AXI [get_bd_intf_pins M16_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M16_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M17_AXI [get_bd_intf_pins M17_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M17_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M18_AXI [get_bd_intf_pins M18_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M18_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins DEBUG] [get_bd_intf_pins mb_1/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins mb1_lmb/DLMB] [get_bd_intf_pins mb_1/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins mb1_lmb/ILMB] [get_bd_intf_pins mb_1/ILMB]

  # Create port connections
  connect_bd_net -net M04_ARESETN_1 [get_bd_pins M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN]
  connect_bd_net -net PMOD_IO_Switch_IP_0_miso_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/miso_i_in] [get_bd_pins mb1_spi/io1_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_mosi_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/mosi_i_in] [get_bd_pins mb1_spi/io0_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_scl_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/scl_i_in] [get_bd_pins mb1_iic/scl_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sda_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/sda_i_in] [get_bd_pins mb1_iic/sda_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_spick_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/spick_i_in] [get_bd_pins mb1_spi/sck_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_ss_i_in [get_bd_pins mb1_PMOD_IO_Switch_IP/ss_i_in] [get_bd_pins mb1_spi/ss_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pl_data_in [get_bd_pins mb1_PMOD_IO_Switch_IP/sw2pl_data_in] [get_bd_pins mb1_gpio/gpio_io_i]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_data_out [get_bd_pins sw2pmod_data_out] [get_bd_pins mb1_PMOD_IO_Switch_IP/sw2pmod_data_out]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_tri_out [get_bd_pins sw2pmod_tri_out] [get_bd_pins mb1_PMOD_IO_Switch_IP/sw2pmod_tri_out]
  connect_bd_net -net logic_1_dout [get_bd_pins ext_reset_in] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net mb1_gpio_gpio_io_o [get_bd_pins mb1_PMOD_IO_Switch_IP/pl2sw_data_o] [get_bd_pins mb1_gpio/gpio_io_o]
  connect_bd_net -net mb1_gpio_gpio_io_t [get_bd_pins mb1_PMOD_IO_Switch_IP/pl2sw_tri_o] [get_bd_pins mb1_gpio/gpio_io_t]
  connect_bd_net -net mb1_iic_scl_o [get_bd_pins mb1_PMOD_IO_Switch_IP/scl_o_in] [get_bd_pins mb1_iic/scl_o]
  connect_bd_net -net mb1_iic_scl_t [get_bd_pins mb1_PMOD_IO_Switch_IP/scl_t_in] [get_bd_pins mb1_iic/scl_t]
  connect_bd_net -net mb1_iic_sda_o [get_bd_pins mb1_PMOD_IO_Switch_IP/sda_o_in] [get_bd_pins mb1_iic/sda_o]
  connect_bd_net -net mb1_iic_sda_t [get_bd_pins mb1_PMOD_IO_Switch_IP/sda_t_in] [get_bd_pins mb1_iic/sda_t]
  connect_bd_net -net mb1_spi_io0_o [get_bd_pins mb1_PMOD_IO_Switch_IP/mosi_o_in] [get_bd_pins mb1_spi/io0_o]
  connect_bd_net -net mb1_spi_io0_t [get_bd_pins mb1_PMOD_IO_Switch_IP/mosi_t_in] [get_bd_pins mb1_spi/io0_t]
  connect_bd_net -net mb1_spi_io1_o [get_bd_pins mb1_PMOD_IO_Switch_IP/miso_o_in] [get_bd_pins mb1_spi/io1_o]
  connect_bd_net -net mb1_spi_io1_t [get_bd_pins mb1_PMOD_IO_Switch_IP/miso_t_in] [get_bd_pins mb1_spi/io1_t]
  connect_bd_net -net mb1_spi_sck_o [get_bd_pins mb1_PMOD_IO_Switch_IP/spick_o_in] [get_bd_pins mb1_spi/sck_o]
  connect_bd_net -net mb1_spi_sck_t [get_bd_pins mb1_PMOD_IO_Switch_IP/spick_t_in] [get_bd_pins mb1_spi/sck_t]
  connect_bd_net -net mb1_spi_ss_o [get_bd_pins mb1_PMOD_IO_Switch_IP/ss_o_in] [get_bd_pins mb1_spi/ss_o]
  connect_bd_net -net mb1_spi_ss_t [get_bd_pins mb1_PMOD_IO_Switch_IP/ss_t_in] [get_bd_pins mb1_spi/ss_t]
  connect_bd_net -net mb_1_reset_Dout [get_bd_pins aux_reset_in] [get_bd_pins rst_clk_wiz_1_100M/aux_reset_in]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mb_debug_sys_rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net pmod2sw_data_in_1 [get_bd_pins pmod2sw_data_in] [get_bd_pins mb1_PMOD_IO_Switch_IP/pmod2sw_data_in]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins clk] [get_bd_pins mb1_PMOD_IO_Switch_IP/s00_axi_aclk] [get_bd_pins mb1_gpio/s_axi_aclk] [get_bd_pins mb1_iic/s_axi_aclk] [get_bd_pins mb1_lmb/LMB_Clk] [get_bd_pins mb1_spi/ext_spi_clk] [get_bd_pins mb1_spi/s_axi_aclk] [get_bd_pins mb_1/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_0_axi_periph/M10_ACLK] [get_bd_pins microblaze_0_axi_periph/M11_ACLK] [get_bd_pins microblaze_0_axi_periph/M12_ACLK] [get_bd_pins microblaze_0_axi_periph/M13_ACLK] [get_bd_pins microblaze_0_axi_periph/M14_ACLK] [get_bd_pins microblaze_0_axi_periph/M15_ACLK] [get_bd_pins microblaze_0_axi_periph/M16_ACLK] [get_bd_pins microblaze_0_axi_periph/M17_ACLK] [get_bd_pins microblaze_0_axi_periph/M18_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins mb1_lmb/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins mb_1/Reset] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins peripheral_aresetn1] [get_bd_pins peripheral_aresetn2] [get_bd_pins mb1_PMOD_IO_Switch_IP/s00_axi_aresetn] [get_bd_pins mb1_gpio/s_axi_aresetn] [get_bd_pins mb1_iic/s_axi_aresetn] [get_bd_pins mb1_spi/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_0_axi_periph/M10_ARESETN] [get_bd_pins microblaze_0_axi_periph/M11_ARESETN] [get_bd_pins microblaze_0_axi_periph/M12_ARESETN] [get_bd_pins microblaze_0_axi_periph/M13_ARESETN] [get_bd_pins microblaze_0_axi_periph/M14_ARESETN] [get_bd_pins microblaze_0_axi_periph/M15_ARESETN] [get_bd_pins microblaze_0_axi_periph/M16_ARESETN] [get_bd_pins microblaze_0_axi_periph/M17_ARESETN] [get_bd_pins microblaze_0_axi_periph/M18_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set IIC_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_1 ]
  set Vaux6 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux6 ]
  set Vaux7 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux7 ]
  set Vaux14 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux14 ]
  set Vaux15 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux15 ]
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]
  set btns_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 btns_4bits ]
  set leds_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 leds_4bits ]
  set sws_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 sws_4bits ]

  # Create ports
  set pmodJB_data_in [ create_bd_port -dir I -from 7 -to 0 pmodJB_data_in ]
  set pmodJB_data_out [ create_bd_port -dir O -from 7 -to 0 pmodJB_data_out ]
  set pmodJB_tri_out [ create_bd_port -dir O -from 7 -to 0 pmodJB_tri_out ]
  set pmodJC_data_in [ create_bd_port -dir I -from 7 -to 0 pmodJC_data_in ]
  set pmodJC_data_out [ create_bd_port -dir O -from 7 -to 0 pmodJC_data_out ]
  set pmodJC_tri_out [ create_bd_port -dir O -from 7 -to 0 pmodJC_tri_out ]
  set pmodJD_data_in [ create_bd_port -dir I -from 7 -to 0 pmodJD_data_in ]
  set pmodJD_data_out [ create_bd_port -dir O -from 7 -to 0 pmodJD_data_out ]
  set pmodJD_tri_out [ create_bd_port -dir O -from 7 -to 0 pmodJD_tri_out ]
  set pmodJE_data_in [ create_bd_port -dir I -from 7 -to 0 pmodJE_data_in ]
  set pmodJE_data_out [ create_bd_port -dir O -from 7 -to 0 pmodJE_data_out ]
  set pmodJE_tri_out [ create_bd_port -dir O -from 7 -to 0 pmodJE_tri_out ]

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list \
CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_traceBuffer_v1_0_0, and set properties
  set axi_traceBuffer_v1_0_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axi_traceBuffer_v1_0:1.0 axi_traceBuffer_v1_0_0 ]

  # Create instance: bit8_logic_0, and set properties
  set bit8_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 bit8_logic_0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
CONFIG.CONST_WIDTH {8} \
 ] $bit8_logic_0

  # Create instance: btns_gpio, and set properties
  set btns_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 btns_gpio ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_GPIO_WIDTH {4} \
 ] $btns_gpio

  # Create instance: logic_1, and set properties
  set logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_1 ]

  # Create instance: mb_1_reset, and set properties
  set mb_1_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 mb_1_reset ]
  set_property -dict [ list \
CONFIG.DIN_FROM {0} \
CONFIG.DIN_TO {0} \
CONFIG.DIN_WIDTH {6} \
 ] $mb_1_reset

  # Create instance: mb_JB
  create_hier_cell_mb_JB [current_bd_instance .] mb_JB

  # Create instance: mb_JC
  create_hier_cell_mb_JC [current_bd_instance .] mb_JC

  # Create instance: mb_JD
  create_hier_cell_mb_JD [current_bd_instance .] mb_JD

  # Create instance: mb_JE
  create_hier_cell_mb_JE [current_bd_instance .] mb_JE

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]
  set_property -dict [ list \
CONFIG.C_MB_DBG_PORTS {1} \
CONFIG.C_USE_UART {1} \
 ] $mdm_1

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650} \
CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50.000000} \
CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} \
CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_ENET0_RESET_ENABLE {0} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
CONFIG.PCW_GPIO_EMIO_GPIO_IO {6} \
CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0} \
CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_MIO_0_PULLUP {<Select>} \
CONFIG.PCW_MIO_10_PULLUP {<Select>} \
CONFIG.PCW_MIO_11_PULLUP {<Select>} \
CONFIG.PCW_MIO_12_PULLUP {<Select>} \
CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_16_PULLUP {enabled} \
CONFIG.PCW_MIO_16_SLEW {slow} \
CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_17_PULLUP {enabled} \
CONFIG.PCW_MIO_17_SLEW {slow} \
CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_18_PULLUP {enabled} \
CONFIG.PCW_MIO_18_SLEW {slow} \
CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_19_PULLUP {enabled} \
CONFIG.PCW_MIO_19_SLEW {slow} \
CONFIG.PCW_MIO_1_PULLUP {disabled} \
CONFIG.PCW_MIO_1_SLEW {fast} \
CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_20_PULLUP {enabled} \
CONFIG.PCW_MIO_20_SLEW {slow} \
CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_21_PULLUP {enabled} \
CONFIG.PCW_MIO_21_SLEW {slow} \
CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_22_PULLUP {enabled} \
CONFIG.PCW_MIO_22_SLEW {slow} \
CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_23_PULLUP {enabled} \
CONFIG.PCW_MIO_23_SLEW {slow} \
CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_24_PULLUP {enabled} \
CONFIG.PCW_MIO_24_SLEW {slow} \
CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_25_PULLUP {enabled} \
CONFIG.PCW_MIO_25_SLEW {slow} \
CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_26_PULLUP {enabled} \
CONFIG.PCW_MIO_26_SLEW {slow} \
CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
CONFIG.PCW_MIO_27_PULLUP {enabled} \
CONFIG.PCW_MIO_27_SLEW {slow} \
CONFIG.PCW_MIO_28_PULLUP {enabled} \
CONFIG.PCW_MIO_28_SLEW {slow} \
CONFIG.PCW_MIO_29_PULLUP {enabled} \
CONFIG.PCW_MIO_29_SLEW {slow} \
CONFIG.PCW_MIO_2_SLEW {fast} \
CONFIG.PCW_MIO_30_PULLUP {enabled} \
CONFIG.PCW_MIO_30_SLEW {slow} \
CONFIG.PCW_MIO_31_PULLUP {enabled} \
CONFIG.PCW_MIO_31_SLEW {slow} \
CONFIG.PCW_MIO_32_PULLUP {enabled} \
CONFIG.PCW_MIO_32_SLEW {slow} \
CONFIG.PCW_MIO_33_PULLUP {enabled} \
CONFIG.PCW_MIO_33_SLEW {slow} \
CONFIG.PCW_MIO_34_PULLUP {enabled} \
CONFIG.PCW_MIO_34_SLEW {slow} \
CONFIG.PCW_MIO_35_PULLUP {enabled} \
CONFIG.PCW_MIO_35_SLEW {slow} \
CONFIG.PCW_MIO_36_PULLUP {enabled} \
CONFIG.PCW_MIO_36_SLEW {slow} \
CONFIG.PCW_MIO_37_PULLUP {enabled} \
CONFIG.PCW_MIO_37_SLEW {slow} \
CONFIG.PCW_MIO_38_PULLUP {enabled} \
CONFIG.PCW_MIO_38_SLEW {slow} \
CONFIG.PCW_MIO_39_PULLUP {enabled} \
CONFIG.PCW_MIO_39_SLEW {slow} \
CONFIG.PCW_MIO_3_SLEW {fast} \
CONFIG.PCW_MIO_40_PULLUP {disabled} \
CONFIG.PCW_MIO_40_SLEW {fast} \
CONFIG.PCW_MIO_41_PULLUP {disabled} \
CONFIG.PCW_MIO_41_SLEW {fast} \
CONFIG.PCW_MIO_42_PULLUP {disabled} \
CONFIG.PCW_MIO_42_SLEW {fast} \
CONFIG.PCW_MIO_43_PULLUP {disabled} \
CONFIG.PCW_MIO_43_SLEW {fast} \
CONFIG.PCW_MIO_44_PULLUP {disabled} \
CONFIG.PCW_MIO_44_SLEW {fast} \
CONFIG.PCW_MIO_45_PULLUP {disabled} \
CONFIG.PCW_MIO_45_SLEW {fast} \
CONFIG.PCW_MIO_47_PULLUP {disabled} \
CONFIG.PCW_MIO_48_PULLUP {disabled} \
CONFIG.PCW_MIO_49_PULLUP {disabled} \
CONFIG.PCW_MIO_4_SLEW {fast} \
CONFIG.PCW_MIO_50_DIRECTION {<Select>} \
CONFIG.PCW_MIO_50_PULLUP {<Select>} \
CONFIG.PCW_MIO_51_DIRECTION {<Select>} \
CONFIG.PCW_MIO_51_PULLUP {<Select>} \
CONFIG.PCW_MIO_52_PULLUP {<Select>} \
CONFIG.PCW_MIO_52_SLEW {<Select>} \
CONFIG.PCW_MIO_53_PULLUP {<Select>} \
CONFIG.PCW_MIO_53_SLEW {<Select>} \
CONFIG.PCW_MIO_5_SLEW {fast} \
CONFIG.PCW_MIO_6_SLEW {fast} \
CONFIG.PCW_MIO_8_SLEW {fast} \
CONFIG.PCW_MIO_9_PULLUP {<Select>} \
CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
CONFIG.PCW_SD0_GRP_CD_IO {MIO 47} \
CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.176} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.159} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.162} \
CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.187} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {-0.073} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {-0.034} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {-0.03} \
CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {-0.082} \
CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525} \
CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K128M16 JT-125} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_USB0_RESET_ENABLE {0} \
CONFIG.PCW_USB0_RESET_IO {<Select>} \
CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_USE_DEBUG {0} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {8} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: swsleds_gpio, and set properties
  set swsleds_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 swsleds_gpio ]
  set_property -dict [ list \
CONFIG.C_ALL_INPUTS {1} \
CONFIG.C_ALL_OUTPUTS_2 {1} \
CONFIG.C_GPIO2_WIDTH {4} \
CONFIG.C_GPIO_WIDTH {4} \
CONFIG.C_IS_DUAL {1} \
 ] $swsleds_gpio

  # Create instance: tracebuffer_sel, and set properties
  set tracebuffer_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 tracebuffer_sel ]
  set_property -dict [ list \
CONFIG.DIN_FROM {5} \
CONFIG.DIN_TO {4} \
CONFIG.DIN_WIDTH {6} \
CONFIG.DOUT_WIDTH {2} \
 ] $tracebuffer_sel

  # Create instance: xadc_wiz_0, and set properties
  set xadc_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.2 xadc_wiz_0 ]
  set_property -dict [ list \
CONFIG.AVERAGE_ENABLE_VAUXP14_VAUXN14 {true} \
CONFIG.AVERAGE_ENABLE_VAUXP15_VAUXN15 {true} \
CONFIG.AVERAGE_ENABLE_VAUXP6_VAUXN6 {true} \
CONFIG.AVERAGE_ENABLE_VAUXP7_VAUXN7 {true} \
CONFIG.AVERAGE_ENABLE_VP_VN {true} \
CONFIG.BIPOLAR_VAUXP6_VAUXN6 {true} \
CONFIG.BIPOLAR_VAUXP7_VAUXN7 {true} \
CONFIG.CHANNEL_AVERAGING {16} \
CONFIG.CHANNEL_ENABLE_VAUXP14_VAUXN14 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP15_VAUXN15 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP6_VAUXN6 {true} \
CONFIG.CHANNEL_ENABLE_VAUXP7_VAUXN7 {true} \
CONFIG.CHANNEL_ENABLE_VP_VN {true} \
CONFIG.ENABLE_VCCDDRO_ALARM {false} \
CONFIG.ENABLE_VCCPAUX_ALARM {false} \
CONFIG.ENABLE_VCCPINT_ALARM {false} \
CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
CONFIG.OT_ALARM {false} \
CONFIG.POWER_DOWN_ADCB {true} \
CONFIG.SEQUENCER_MODE {Continuous} \
CONFIG.SINGLE_CHANNEL_SELECTION {TEMPERATURE} \
CONFIG.USER_TEMP_ALARM {false} \
CONFIG.VCCAUX_ALARM {false} \
CONFIG.VCCINT_ALARM {false} \
CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
 ] $xadc_wiz_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {4} \
 ] $xlconcat_0

  # Create instance: xup_mux_data_in, and set properties
  set xup_mux_data_in [ create_bd_cell -type ip -vlnv xilinx.com:XUP:xup_4_to_1_mux_vector:1.0 xup_mux_data_in ]
  set_property -dict [ list \
CONFIG.SIZE {8} \
 ] $xup_mux_data_in

  # Create instance: xup_mux_data_out, and set properties
  set xup_mux_data_out [ create_bd_cell -type ip -vlnv xilinx.com:XUP:xup_4_to_1_mux_vector:1.0 xup_mux_data_out ]
  set_property -dict [ list \
CONFIG.SIZE {8} \
 ] $xup_mux_data_out

  # Create instance: xup_mux_tri_out, and set properties
  set xup_mux_tri_out [ create_bd_cell -type ip -vlnv xilinx.com:XUP:xup_4_to_1_mux_vector:1.0 xup_mux_tri_out ]
  set_property -dict [ list \
CONFIG.SIZE {8} \
 ] $xup_mux_tri_out

  # Create interface connections
  connect_bd_intf_net -intf_net AXI_LITE_1 [get_bd_intf_pins mb_JB/M07_AXI] [get_bd_intf_pins mb_JC/AXI_LITE]
  connect_bd_intf_net -intf_net AXI_LITE_2 [get_bd_intf_pins mb_JB/M11_AXI] [get_bd_intf_pins mb_JD/AXI_LITE]
  connect_bd_intf_net -intf_net AXI_LITE_3 [get_bd_intf_pins mb_JB/M15_AXI] [get_bd_intf_pins mb_JE/AXI_LITE]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins mb_JB/M10_AXI] [get_bd_intf_pins mb_JC/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins mb_JB/M14_AXI] [get_bd_intf_pins mb_JD/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_3 [get_bd_intf_pins mb_JB/M18_AXI] [get_bd_intf_pins mb_JE/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI1_1 [get_bd_intf_pins mb_JB/M09_AXI] [get_bd_intf_pins mb_JC/S_AXI1]
  connect_bd_intf_net -intf_net S_AXI1_2 [get_bd_intf_pins mb_JB/M13_AXI] [get_bd_intf_pins mb_JD/S_AXI1]
  connect_bd_intf_net -intf_net S_AXI1_3 [get_bd_intf_pins mb_JB/M17_AXI] [get_bd_intf_pins mb_JE/S_AXI1]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins mb_JB/M08_AXI] [get_bd_intf_pins mb_JC/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_2 [get_bd_intf_pins mb_JB/M12_AXI] [get_bd_intf_pins mb_JD/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_3 [get_bd_intf_pins mb_JB/M16_AXI] [get_bd_intf_pins mb_JE/S_AXI]
  connect_bd_intf_net -intf_net Vaux14_1 [get_bd_intf_ports Vaux14] [get_bd_intf_pins xadc_wiz_0/Vaux14]
  connect_bd_intf_net -intf_net Vaux15_1 [get_bd_intf_ports Vaux15] [get_bd_intf_pins xadc_wiz_0/Vaux15]
  connect_bd_intf_net -intf_net Vaux6_1 [get_bd_intf_ports Vaux6] [get_bd_intf_pins xadc_wiz_0/Vaux6]
  connect_bd_intf_net -intf_net Vaux7_1 [get_bd_intf_ports Vaux7] [get_bd_intf_pins xadc_wiz_0/Vaux7]
  connect_bd_intf_net -intf_net Vp_Vn_1 [get_bd_intf_ports Vp_Vn] [get_bd_intf_pins xadc_wiz_0/Vp_Vn]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins mb_JB/BRAM_PORTB]
  connect_bd_intf_net -intf_net btns_gpio_GPIO [get_bd_intf_ports btns_4bits] [get_bd_intf_pins btns_gpio/GPIO]
  connect_bd_intf_net -intf_net mb_JB_M04_AXI [get_bd_intf_pins mb_JB/M04_AXI] [get_bd_intf_pins swsleds_gpio/S_AXI]
  connect_bd_intf_net -intf_net mb_JB_M05_AXI [get_bd_intf_pins btns_gpio/S_AXI] [get_bd_intf_pins mb_JB/M05_AXI]
  connect_bd_intf_net -intf_net mb_JB_M06_AXI [get_bd_intf_pins mb_JB/M06_AXI] [get_bd_intf_pins mdm_1/S_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mb_JB/DEBUG] [get_bd_intf_pins mdm_1/MBDEBUG_0]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_1 [get_bd_intf_ports IIC_1] [get_bd_intf_pins processing_system7_0/IIC_1]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins axi_traceBuffer_v1_0_0/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M07_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M07_AXI] [get_bd_intf_pins xadc_wiz_0/s_axi_lite]
  connect_bd_intf_net -intf_net swsleds_gpio_GPIO [get_bd_intf_ports sws_4bits] [get_bd_intf_pins swsleds_gpio/GPIO]
  connect_bd_intf_net -intf_net swsleds_gpio_GPIO2 [get_bd_intf_ports leds_4bits] [get_bd_intf_pins swsleds_gpio/GPIO2]

  # Create port connections
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_data_out [get_bd_ports pmodJB_data_out] [get_bd_pins mb_JB/sw2pmod_data_out] [get_bd_pins xup_mux_data_out/a]
  connect_bd_net -net PMOD_IO_Switch_IP_0_sw2pmod_tri_out [get_bd_ports pmodJB_tri_out] [get_bd_pins mb_JB/sw2pmod_tri_out] [get_bd_pins xup_mux_tri_out/a]
  connect_bd_net -net bit8_logic_0_dout [get_bd_pins bit8_logic_0/dout] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net logic_1_dout [get_bd_pins logic_1/dout] [get_bd_pins mb_JB/ext_reset_in]
  connect_bd_net -net mb_1_reset_Dout [get_bd_pins mb_1_reset/Dout] [get_bd_pins mb_JB/aux_reset_in]
  connect_bd_net -net mb_JB1_sw2pmod_data_out [get_bd_ports pmodJC_data_out] [get_bd_pins mb_JC/sw2pmod_data_out] [get_bd_pins xup_mux_data_out/b]
  connect_bd_net -net mb_JB1_sw2pmod_tri_out [get_bd_ports pmodJC_tri_out] [get_bd_pins mb_JC/sw2pmod_tri_out] [get_bd_pins xup_mux_tri_out/b]
  connect_bd_net -net mb_JB_peripheral_aresetn [get_bd_pins mb_JB/peripheral_aresetn] [get_bd_pins mb_JD/s00_axi_aresetn]
  connect_bd_net -net mb_JB_peripheral_aresetn1 [get_bd_pins mb_JB/peripheral_aresetn1] [get_bd_pins mb_JC/s_axi_aresetn]
  connect_bd_net -net mb_JB_peripheral_aresetn2 [get_bd_pins mb_JB/peripheral_aresetn2] [get_bd_pins mb_JE/s_axi_aresetn]
  connect_bd_net -net mb_JD_sw2pmod_data_out [get_bd_ports pmodJD_data_out] [get_bd_pins mb_JD/sw2pmod_data_out] [get_bd_pins xup_mux_data_out/c]
  connect_bd_net -net mb_JD_sw2pmod_tri_out [get_bd_ports pmodJD_tri_out] [get_bd_pins mb_JD/sw2pmod_tri_out] [get_bd_pins xup_mux_tri_out/c]
  connect_bd_net -net mb_JE_sw2pmod_data_out [get_bd_ports pmodJE_data_out] [get_bd_pins mb_JE/sw2pmod_data_out] [get_bd_pins xup_mux_data_out/d]
  connect_bd_net -net mb_JE_sw2pmod_tri_out [get_bd_ports pmodJE_tri_out] [get_bd_pins mb_JE/sw2pmod_tri_out] [get_bd_pins xup_mux_tri_out/d]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mb_JB/mb_debug_sys_rst] [get_bd_pins mdm_1/Debug_SYS_Rst]
  connect_bd_net -net pmod2sw_data_in_1 [get_bd_ports pmodJB_data_in] [get_bd_pins mb_JB/pmod2sw_data_in] [get_bd_pins xup_mux_data_in/a]
  connect_bd_net -net pmod2sw_data_in_2 [get_bd_ports pmodJC_data_in] [get_bd_pins mb_JC/pmod2sw_data_in] [get_bd_pins xup_mux_data_in/b]
  connect_bd_net -net pmod2sw_data_in_3 [get_bd_ports pmodJD_data_in] [get_bd_pins mb_JD/pmod2sw_data_in] [get_bd_pins xup_mux_data_in/c]
  connect_bd_net -net pmod2sw_data_in_4 [get_bd_ports pmodJE_data_in] [get_bd_pins mb_JE/pmod2sw_data_in] [get_bd_pins xup_mux_data_in/d]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_traceBuffer_v1_0_0/s00_axi_aclk] [get_bd_pins btns_gpio/s_axi_aclk] [get_bd_pins mb_JB/clk] [get_bd_pins mb_JC/clk] [get_bd_pins mb_JD/clk] [get_bd_pins mb_JE/clk] [get_bd_pins mdm_1/S_AXI_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk] [get_bd_pins swsleds_gpio/s_axi_aclk] [get_bd_pins xadc_wiz_0/s_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net processing_system7_0_GPIO_O [get_bd_pins mb_1_reset/Din] [get_bd_pins processing_system7_0/GPIO_O] [get_bd_pins tracebuffer_sel/Din]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_traceBuffer_v1_0_0/s00_axi_aresetn] [get_bd_pins btns_gpio/s_axi_aresetn] [get_bd_pins mb_JB/M04_ARESETN] [get_bd_pins mdm_1/S_AXI_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn] [get_bd_pins swsleds_gpio/s_axi_aresetn] [get_bd_pins xadc_wiz_0/s_axi_aresetn]
  connect_bd_net -net tracebuffer_sel_Dout [get_bd_pins tracebuffer_sel/Dout] [get_bd_pins xup_mux_data_in/sel] [get_bd_pins xup_mux_data_out/sel] [get_bd_pins xup_mux_tri_out/sel]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_traceBuffer_v1_0_0/MONITOR_DATAIN] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xup_mux_data_in_y [get_bd_pins xlconcat_0/In2] [get_bd_pins xup_mux_data_in/y]
  connect_bd_net -net xup_mux_data_out_y [get_bd_pins xlconcat_0/In0] [get_bd_pins xup_mux_data_out/y]
  connect_bd_net -net xup_mux_tri_out_y [get_bd_pins xlconcat_0/In1] [get_bd_pins xup_mux_tri_out/y]

  # Create address segments
  create_bd_addr_seg -range 0x8000 -offset 0x40000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_traceBuffer_v1_0_0/s00_axi/reg0] SEG_axi_traceBuffer_v1_0_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs xadc_wiz_0/s_axi_lite/Reg] SEG_xadc_wiz_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40010000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs btns_gpio/S_AXI/Reg] SEG_btns_gpio_Reg
  create_bd_addr_seg -range 0x8000 -offset 0x0 [get_bd_addr_spaces mb_JB/mb_1/Instruction] [get_bd_addr_segs mb_JB/mb1_lmb/lmb_bram_if_cntlr/SLMB/Mem] SEG_lmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x8000 -offset 0x0 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JB/mb1_lmb/lmb_bram_if_cntlr/SLMB1/Mem] SEG_lmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x10000 -offset 0x44A00000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JB/mb1_PMOD_IO_Switch_IP/S00_AXI/S00_AXI_reg] SEG_mb1_PMOD_IO_Switch_IP_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x40000000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JB/mb1_gpio/S_AXI/Reg] SEG_mb1_gpio_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40800000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JB/mb1_iic/S_AXI/Reg] SEG_mb1_iic_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A10000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JB/mb1_spi/AXI_LITE/Reg] SEG_mb1_spi_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A20000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JC/mb2_PMOD_IO_Switch_IP/S00_AXI/S00_AXI_reg] SEG_mb2_PMOD_IO_Switch_IP_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x40030000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JC/mb2_gpio/S_AXI/Reg] SEG_mb2_gpio_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40810000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JC/mb2_iic/S_AXI/Reg] SEG_mb2_iic_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A30000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JC/mb2_spi/AXI_LITE/Reg] SEG_mb2_spi_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A40000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JD/mb3_PMOD_IO_Switch_IP/S00_AXI/S00_AXI_reg] SEG_mb3_PMOD_IO_Switch_IP_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x40040000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JD/mb3_gpio/S_AXI/Reg] SEG_mb3_gpio_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40820000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JD/mb3_iic/S_AXI/Reg] SEG_mb3_iic_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A50000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JD/mb3_spi/AXI_LITE/Reg] SEG_mb3_spi_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A60000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JE/mb4_PMOD_IO_Switch_IP/S00_AXI/S00_AXI_reg] SEG_mb4_PMOD_IO_Switch_IP_S00_AXI_reg
  create_bd_addr_seg -range 0x10000 -offset 0x40050000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JE/mb4_gpio/S_AXI/Reg] SEG_mb4_gpio_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40830000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JE/mb4_iic/S_AXI/Reg] SEG_mb4_iic_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A70000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mb_JE/mb4_spi/AXI_LITE/Reg] SEG_mb4_spi_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x41400000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs mdm_1/S_AXI/Reg] SEG_mdm_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x40060000 [get_bd_addr_spaces mb_JB/mb_1/Data] [get_bd_addr_segs swsleds_gpio/S_AXI/Reg] SEG_swsleds_gpio_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port btns_4bits -pg 1 -y 1030 -defaultsOSRD
preplace port DDR -pg 1 -y 920 -defaultsOSRD
preplace port Vp_Vn -pg 1 -y 1500 -defaultsOSRD
preplace port sws_4bits -pg 1 -y 840 -defaultsOSRD
preplace port leds_4bits -pg 1 -y 860 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 940 -defaultsOSRD
preplace port Vaux6 -pg 1 -y 1520 -defaultsOSRD
preplace port IIC_1 -pg 1 -y 960 -defaultsOSRD
preplace port Vaux14 -pg 1 -y 1560 -defaultsOSRD
preplace port Vaux7 -pg 1 -y 1540 -defaultsOSRD
preplace port Vaux15 -pg 1 -y 1580 -defaultsOSRD
preplace portBus pmodJE_data_in -pg 1 -y 700 -defaultsOSRD
preplace portBus pmodJB_tri_out -pg 1 -y 780 -defaultsOSRD
preplace portBus pmodJE_data_out -pg 1 -y 400 -defaultsOSRD
preplace portBus pmodJD_data_in -pg 1 -y 620 -defaultsOSRD
preplace portBus pmodJB_data_out -pg 1 -y 340 -defaultsOSRD
preplace portBus pmodJB_data_in -pg 1 -y 580 -defaultsOSRD
preplace portBus pmodJC_data_out -pg 1 -y 60 -defaultsOSRD
preplace portBus pmodJE_tri_out -pg 1 -y 420 -defaultsOSRD
preplace portBus pmodJD_data_out -pg 1 -y 360 -defaultsOSRD
preplace portBus pmodJC_tri_out -pg 1 -y 190 -defaultsOSRD
preplace portBus pmodJC_data_in -pg 1 -y 600 -defaultsOSRD
preplace portBus pmodJD_tri_out -pg 1 -y 380 -defaultsOSRD
preplace inst xup_mux_data_in -pg 1 -lvl 2 -y 680 -defaultsOSRD -resize 220 140
preplace inst rst_processing_system7_0_100M -pg 1 -lvl 2 -y 1200 -defaultsOSRD
preplace inst swsleds_gpio -pg 1 -lvl 7 -y 850 -defaultsOSRD
preplace inst xadc_wiz_0 -pg 1 -lvl 4 -y 1550 -defaultsOSRD
preplace inst mb_1_reset -pg 1 -lvl 5 -y 310 -defaultsOSRD
preplace inst bit8_logic_0 -pg 1 -lvl 2 -y 480 -defaultsOSRD
preplace inst xup_mux_tri_out -pg 1 -lvl 2 -y 90 -defaultsOSRD -resize 220 140
preplace inst mb_JB -pg 1 -lvl 6 -y 550 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 3 -y 450 -defaultsOSRD
preplace inst mb_JC -pg 1 -lvl 7 -y 180 -defaultsOSRD -resize 300 196
preplace inst logic_1 -pg 1 -lvl 5 -y 410 -defaultsOSRD
preplace inst mb_JD -pg 1 -lvl 7 -y 460 -defaultsOSRD -resize 300 196
preplace inst mdm_1 -pg 1 -lvl 5 -y 550 -defaultsOSRD
preplace inst mb_JE -pg 1 -lvl 7 -y 670 -defaultsOSRD -resize 300 196
preplace inst btns_gpio -pg 1 -lvl 7 -y 1030 -defaultsOSRD
preplace inst xup_mux_data_out -pg 1 -lvl 2 -y 340 -defaultsOSRD
preplace inst tracebuffer_sel -pg 1 -lvl 1 -y 750 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 3 -y 1220 -defaultsOSRD
preplace inst axi_bram_ctrl_1 -pg 1 -lvl 5 -y 840 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 2 -y 970 -defaultsOSRD
preplace inst axi_traceBuffer_v1_0_0 -pg 1 -lvl 4 -y 1300 -defaultsOSRD
preplace netloc btns_gpio_GPIO 1 7 1 NJ
preplace netloc Vaux6_1 1 0 4 NJ 1520 NJ 1520 NJ 1520 NJ
preplace netloc processing_system7_0_DDR 1 2 6 NJ 920 NJ 920 NJ 920 NJ 920 NJ 920 NJ
preplace netloc S_AXI_1 1 6 1 2080
preplace netloc xup_mux_tri_out_y 1 2 1 710
preplace netloc pmod2sw_data_in_3 1 0 7 NJ 620 200 780 NJ 750 NJ 750 NJ 750 NJ 800 2220
preplace netloc S_AXI_2 1 6 1 2150
preplace netloc mb_JB_M06_AXI 1 4 3 1350 220 NJ 220 2060
preplace netloc pmod2sw_data_in_4 1 0 7 NJ 700 220 770 NJ 770 NJ 770 NJ 770 NJ 810 2240
preplace netloc mb_JD_sw2pmod_data_out 1 1 7 270 240 NJ 240 NJ 240 NJ 240 NJ 240 NJ 290 2580
preplace netloc S_AXI_3 1 6 1 2150
preplace netloc xup_mux_data_out_y 1 2 1 690
preplace netloc processing_system7_0_GPIO_O 1 0 5 20 800 NJ 800 720 310 NJ 310 NJ
preplace netloc Vaux7_1 1 0 4 NJ 1540 NJ 1540 NJ 1540 NJ
preplace netloc S_AXI1_1 1 6 1 2090
preplace netloc processing_system7_0_axi_periph_M07_AXI 1 3 1 1040
preplace netloc processing_system7_0_M_AXI_GP0 1 2 1 N
preplace netloc Vp_Vn_1 1 0 4 NJ 1500 NJ 1500 NJ 1500 NJ
preplace netloc S_AXI1_2 1 6 1 2170
preplace netloc processing_system7_0_FCLK_RESET0_N 1 1 2 280 1110 670
preplace netloc mb_1_reset_Dout 1 5 1 NJ
preplace netloc PMOD_IO_Switch_IP_0_sw2pmod_data_out 1 1 7 250 210 NJ 210 NJ 210 NJ 210 NJ 210 2110 340 NJ
preplace netloc S_AXI1_3 1 6 1 2130
preplace netloc swsleds_gpio_GPIO2 1 7 1 NJ
preplace netloc processing_system7_0_IIC_1 1 2 6 NJ 960 NJ 960 NJ 960 NJ 960 NJ 960 NJ
preplace netloc processing_system7_0_axi_periph_M02_AXI 1 3 2 1040 820 NJ
preplace netloc rst_processing_system7_0_100M_peripheral_aresetn 1 2 5 700 950 1070 860 1340 480 1630 830 2070
preplace netloc mb_JB1_sw2pmod_tri_out 1 1 7 260 180 NJ 30 NJ 30 NJ 30 NJ 30 NJ 30 2630
preplace netloc processing_system7_0_axi_periph_M06_AXI 1 3 1 N
preplace netloc xup_mux_data_in_y 1 2 1 690
preplace netloc xlconcat_0_dout 1 3 1 1050
preplace netloc mb_JE_sw2pmod_tri_out 1 1 7 280 200 NJ 40 NJ 40 NJ 40 NJ 40 NJ 40 2620
preplace netloc swsleds_gpio_GPIO 1 7 1 NJ
preplace netloc Vaux14_1 1 0 4 NJ 1560 NJ 1560 NJ 1560 NJ
preplace netloc processing_system7_0_FIXED_IO 1 2 6 NJ 940 NJ 940 NJ 940 NJ 940 NJ 940 NJ
preplace netloc S00_AXI_1 1 6 1 2100
preplace netloc mb_JB_peripheral_aresetn 1 6 1 2210
preplace netloc mb_JE_sw2pmod_data_out 1 1 7 280 250 NJ 250 NJ 250 NJ 250 NJ 250 NJ 310 2590
preplace netloc logic_1_dout 1 5 1 NJ
preplace netloc S00_AXI_2 1 6 1 2190
preplace netloc mb_JB_M04_AXI 1 6 1 2160
preplace netloc mb_JB1_sw2pmod_data_out 1 1 7 260 220 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 2610
preplace netloc S00_AXI_3 1 6 1 2120
preplace netloc AXI_LITE_1 1 6 1 2070
preplace netloc mb_JB_M05_AXI 1 6 1 2140
preplace netloc mb_JB_peripheral_aresetn1 1 6 1 2180
preplace netloc rst_processing_system7_0_100M_interconnect_aresetn 1 2 1 680
preplace netloc processing_system7_0_FCLK_CLK0 1 1 6 270 1290 720 910 1060 840 1350 630 1680 820 2200
preplace netloc PMOD_IO_Switch_IP_0_sw2pmod_tri_out 1 1 7 240 790 NJ 790 NJ 790 NJ 760 NJ 790 2070 780 NJ
preplace netloc AXI_LITE_2 1 6 1 2130
preplace netloc microblaze_0_debug 1 5 1 1640
preplace netloc axi_bram_ctrl_1_BRAM_PORTA 1 5 1 1660
preplace netloc mb_JB_peripheral_aresetn2 1 6 1 2230
preplace netloc pmod2sw_data_in_1 1 0 6 NJ 580 220 590 NJ 590 NJ 590 NJ 620 1620
preplace netloc mdm_1_debug_sys_rst 1 5 1 1670
preplace netloc mb_JD_sw2pmod_tri_out 1 1 7 270 190 NJ 60 NJ 60 NJ 60 NJ 60 NJ 60 2600
preplace netloc bit8_logic_0_dout 1 2 1 NJ
preplace netloc Vaux15_1 1 0 4 NJ 1580 NJ 1580 NJ 1580 NJ
preplace netloc AXI_LITE_3 1 6 1 2190
preplace netloc tracebuffer_sel_Dout 1 1 1 210
preplace netloc pmod2sw_data_in_2 1 0 7 NJ 600 230 230 NJ 200 NJ 200 NJ 200 NJ 200 NJ
levelinfo -pg 1 0 110 480 890 1200 1490 1880 2410 2650 -top 0 -bot 1670
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


