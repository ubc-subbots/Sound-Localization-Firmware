set_global_assignment -entity "sdram" -library "lib_sdram" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "sdram" -library "lib_sdram" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "sdram" -library "lib_sdram" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_sdram" -name SPD_FILE [file join $::quartus(sip_path) "../sdram.spd"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "../../sdram.qsys"]

set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "sdram.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_synchronizer.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.sdc"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_clock_0.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_avalon_reset_from_locked_signal.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_clock_0_sys_pll.vo"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_SDRAM.v"]
set_global_assignment -library "lib_sdram" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_SDRAM_test_component.v"]
