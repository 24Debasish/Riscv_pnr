###################################################################

# Created by write_sdc on Wed Jul 22 17:11:07 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA
create_clock [get_ports ms_riscv32_mp_clk_in]  -name clk  -period 3  -waveform {0 1.5}
