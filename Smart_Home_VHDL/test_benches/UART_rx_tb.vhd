library ieee;
use ieee.std_logic_1164.all;

entity UART_rx_tb is
end entity;


architecture rtl of UART_rx_tb is

    component UART_rx is
    generic 
    (
        DATA_WIDTH      : integer;
        SYS_CLK_FREQ    : integer;
        BAUD_RATE       : integer
    );
    port
    (
        Clk         : in std_logic;
        Rst         : in std_logic;
        RS232_Rx    : in std_logic; -- Serial asynchronous signal transmitted by the COMM port of our PC.
        RxIRQClear  : in std_logic;
        RxIRQ       : out std_logic;
        RxData      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
    end component;

signal Clk         : std_logic := '0';
signal Rst         : std_logic;
signal RS232_Rx    : std_logic;
signal RxIRQClear  : std_logic;
signal RxIRQ       : std_logic;
signal RxData      : std_logic_vector(7 downto 0);

signal PCData      : std_logic_vector(7 downto 0) := x"AA";

begin

    Clk <= not Clk after 10ns;
    
    UUT : UART_rx
    generic map
    (
        DATA_WIDTH      => 8,
        SYS_CLK_FREQ    => 50000000,
        BAUD_RATE       => 115200
    ) 
    port map
    (
        Clk         => Clk,
        Rst         => Rst,
        RS232_Rx    => RS232_Rx,
        RxIRQClear  => RxIRQClear,
        RxIRQ       => RxIRQ,
        RxData      => RxData
    );
    
    
    TestProcess:process
    begin
        Rst <= '1';
        RS232_Rx <= '1';
        RxIRQClear <= '0';
        wait for 100ns;
        Rst <= '0';
        wait for 100ns;
        
        -- Transmit Start Bit
        RS232_Rx <= '0';
        wait for 8.7us;
        
        -- Transmit Data Bits LSB first
        RS232_Rx <= PCData(0);
        wait for 8.7us;
        RS232_Rx <= PCData(1);
        wait for 8.7us;
        RS232_Rx <= PCData(2);
        wait for 8.7us;
        RS232_Rx <= PCData(3);
        wait for 8.7us;
        RS232_Rx <= PCData(4);
        wait for 8.7us;
        RS232_Rx <= PCData(5);
        wait for 8.7us;
        RS232_Rx <= PCData(6);
        wait for 8.7us;
        RS232_Rx <= PCData(7);
        wait for 8.7us;
        
        -- Transmit Stop Bit
        RS232_Rx <= '1';
        wait for 8.7us;
        
        wait for 50ns;
        
        wait until rising_edge(Clk);
        RxIRQClear <= '1';
        wait until rising_edge(Clk);
        RxIRQClear <= '0';
        
        wait;
    end process;
    
    
end rtl;