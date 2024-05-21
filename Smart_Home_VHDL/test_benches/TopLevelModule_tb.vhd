library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevelModule_tb is
generic 
(
    RS232_DATA_BITS : integer := 8
);
end entity;


architecture rtl of TopLevelModule_tb is

    component TopLevelModule is
    generic 
    (
        RS232_DATA_BITS : integer := 8;
        SYS_CLK_FREQ    : integer := 50000000;
        BAUD_RATE       : integer := 115200
    );
    port
    (
        Clk             : in std_logic;
        Rst             : in std_logic;
        
        -- RS232 ports which connect to the PC's COMM port
        rs232_rx_pin    : in std_logic;
        rs232_tx_pin    : out std_logic
    );
    end component;
    
signal Clk                  : std_logic := '0';
signal Rst                  : std_logic;
signal rs232_rx_pin         : std_logic;
signal rs232_tx_pin         : std_logic;
signal TransmittedData      : std_logic_vector(RS232_DATA_BITS - 1 downto 0);
signal DataTransmittedToPC  : std_logic_vector(RS232_DATA_BITS - 1 downto 0);
        
begin
    
    Clk <= not Clk after 10ns;
    
    UUT : TopLevelModule
    generic map
    (
        RS232_DATA_BITS => RS232_DATA_BITS,
        SYS_CLK_FREQ    => 50000000,
        BAUD_RATE       => 115200
    )
    port map
    (
        Clk             => Clk,
        Rst             => Rst,
        
        -- RS232 ports which connect to the PC's COMM port
        rs232_rx_pin    => rs232_rx_pin,
        rs232_tx_pin    => rs232_tx_pin
    );

    
    SerialToParallel:process
    begin
        -- Waiting for the start bit
        wait until falling_edge(rs232_tx_pin);
        
        -- Waits until the middle of the start bit
        wait for 4.3us;
        
        for i in 1 to RS232_DATA_BITS loop
            -- Waits until the middle of the next bit
            wait for 8.7us;
            -- Capture the value of the next bit into TransmittedData
            TransmittedData(i-1) <= rs232_tx_pin;
        end loop;
        
        -- Last wait is to wait until the stop bit has been transmitted
        wait for 8.7us;
        DataTransmittedToPC <= TransmittedData;
    end process;
    
    TestProcess:process
    
        variable TransmitDataVector : std_logic_vector(RS232_DATA_BITS - 1 downto 0);
        
        procedure TRANSMIT_CHARACTER
        (
            constant TransmitData : in integer
        ) is
        begin
            TransmitDataVector := std_logic_vector(to_unsigned(TransmitData, RS232_DATA_BITS));
            -- Transmit Start Bit
            rs232_rx_pin <= '0';
            wait for 8.7us;
            
            -- Transmit Data Bits LSB first
            for i in 1 to RS232_DATA_BITS loop
                rs232_rx_pin <= TransmitDataVector(i-1);
                wait for 8.7us;
            end loop;
            
            -- Transmit Stop Bit
            rs232_rx_pin <= '1';
            wait for 8.7us;
        end procedure;
    
    begin
        Rst <= '1';
        rs232_rx_pin <= '1';
        wait for 100ns;
        Rst <= '0';
        wait for 100ns;
        
        --TRANSMIT_CHARACTER(33);
        for i in 0 to 255 loop
            TRANSMIT_CHARACTER(i);
            wait for 20us;
        end loop;
        
        
        wait;
    end process;
    
end rtl;