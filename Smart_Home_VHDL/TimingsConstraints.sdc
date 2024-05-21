
create_clock -name Clk_50MHz -period 20 [get_ports {Clk}]

set_false_path -from [get_ports {Rst rs232_rx_pin}]

set_false_path -to [get_ports {rs232_tx_pin}]