
# (C) 2001-2016 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 15.0 145 win32 2016.04.19.19:47:24

# ----------------------------------------
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="cam_soc"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="C:/altera/15.0/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/error_adapter_0/
mkdir -p ./libraries/avalon_st_adapter/
mkdir -p ./libraries/crosser/
mkdir -p ./libraries/rsp_mux_001/
mkdir -p ./libraries/rsp_mux/
mkdir -p ./libraries/rsp_demux_001/
mkdir -p ./libraries/rsp_demux/
mkdir -p ./libraries/cmd_mux_001/
mkdir -p ./libraries/cmd_mux/
mkdir -p ./libraries/cmd_demux_001/
mkdir -p ./libraries/cmd_demux/
mkdir -p ./libraries/router_003/
mkdir -p ./libraries/router_002/
mkdir -p ./libraries/router_001/
mkdir -p ./libraries/router/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_agent/
mkdir -p ./libraries/nios2_qsys_0_data_master_agent/
mkdir -p ./libraries/jtag_uart_0_avalon_jtag_slave_translator/
mkdir -p ./libraries/nios2_qsys_0_data_master_translator/
mkdir -p ./libraries/cpu/
mkdir -p ./libraries/rst_controller/
mkdir -p ./libraries/irq_mapper/
mkdir -p ./libraries/mm_interconnect_0/
mkdir -p ./libraries/to_sw_sig/
mkdir -p ./libraries/to_sw_port/
mkdir -p ./libraries/to_hw_port/
mkdir -p ./libraries/sysid_qsys_0/
mkdir -p ./libraries/sdram_pll/
mkdir -p ./libraries/sdram/
mkdir -p ./libraries/onchip_memory2_0/
mkdir -p ./libraries/nios2_qsys_0/
mkdir -p ./libraries/led/
mkdir -p ./libraries/jtag_uart_0/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/cycloneive_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_ociram_default_contents.dat ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_ociram_default_contents.hex ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_ociram_default_contents.mif ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_a.dat ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_a.hex ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_a.mif ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_b.dat ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_b.hex ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_rf_ram_b.mif ./
  cp -f $QSYS_SIMDIR/submodules/cam_soc_onchip_memory2_0.hex ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" -work altera_ver      
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"          -work lpm_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"             -work sgate_ver       
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
  vlogan +v2k -sverilog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneive_atoms.v"  -work cycloneive_ver  
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv" -work error_adapter_0                             
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_avalon_st_adapter.v"                  -work avalon_st_adapter                           
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_avalon_st_handshake_clock_crosser.v"                     -work crosser                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_avalon_st_clock_crosser.v"                               -work crosser                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_avalon_st_pipeline_base.v"                               -work crosser                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                    -work rsp_mux_001                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_rsp_mux_001.sv"                       -work rsp_mux_001                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                    -work rsp_mux                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_rsp_mux.sv"                           -work rsp_mux                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_rsp_demux_001.sv"                     -work rsp_demux_001                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_rsp_demux.sv"                         -work rsp_demux                                   
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                    -work cmd_mux_001                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_cmd_mux_001.sv"                       -work cmd_mux_001                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_arbitrator.sv"                                    -work cmd_mux                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_cmd_mux.sv"                           -work cmd_mux                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_cmd_demux_001.sv"                     -work cmd_demux_001                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_cmd_demux.sv"                         -work cmd_demux                                   
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_router_003.sv"                        -work router_003                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_router_002.sv"                        -work router_002                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_router_001.sv"                        -work router_001                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0_router.sv"                            -work router                                      
  vlogan +v2k           "$QSYS_SIMDIR/submodules/altera_avalon_sc_fifo.v"                                        -work jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_slave_agent.sv"                                   -work jtag_uart_0_avalon_jtag_slave_agent         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_burst_uncompressor.sv"                            -work jtag_uart_0_avalon_jtag_slave_agent         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_master_agent.sv"                                  -work nios2_qsys_0_data_master_agent              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_slave_translator.sv"                              -work jtag_uart_0_avalon_jtag_slave_translator    
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/altera_merlin_master_translator.sv"                             -work nios2_qsys_0_data_master_translator         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu.v"                                     -work cpu                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_debug_slave_sysclk.v"                  -work cpu                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_debug_slave_tck.v"                     -work cpu                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_debug_slave_wrapper.v"                 -work cpu                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0_cpu_test_bench.v"                          -work cpu                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/altera_reset_controller.v"                                      -work rst_controller                              
  vlogan +v2k           "$QSYS_SIMDIR/submodules/altera_reset_synchronizer.v"                                    -work rst_controller                              
  vlogan +v2k -sverilog "$QSYS_SIMDIR/submodules/cam_soc_irq_mapper.sv"                                          -work irq_mapper                                  
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_mm_interconnect_0.v"                                    -work mm_interconnect_0                           
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_to_sw_sig.v"                                            -work to_sw_sig                                   
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_to_sw_port.v"                                           -work to_sw_port                                  
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_to_hw_port.v"                                           -work to_hw_port                                  
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_sysid_qsys_0.vo"                                        -work sysid_qsys_0                                
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_sdram_pll.vo"                                           -work sdram_pll                                   
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_sdram.v"                                                -work sdram                                       
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_onchip_memory2_0.v"                                     -work onchip_memory2_0                            
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_nios2_qsys_0.v"                                         -work nios2_qsys_0                                
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_led.v"                                                  -work led                                         
  vlogan +v2k           "$QSYS_SIMDIR/submodules/cam_soc_jtag_uart_0.v"                                          -work jtag_uart_0                                 
  vlogan +v2k           "$QSYS_SIMDIR/cam_soc.v"                                                                                                                   
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
