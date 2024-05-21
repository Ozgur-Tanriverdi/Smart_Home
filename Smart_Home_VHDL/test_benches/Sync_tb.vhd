library ieee;
use ieee.std_logic_1164.all;

entity Sync_tb is
end entity;


architecture rtl of Sync_tb is

    component Sync is
    generic 
    (
        IDLE_STATE  : std_logic
    );
    port
    (
        Clk     : in std_logic;
        Rst     : in std_logic;
        Async   : in std_logic;
        Synced  : out std_logic
    );
    end component;
    
signal Clk     : std_logic:= '0';
signal Rst     : std_logic;
signal Async   : std_logic;
signal Synced  : std_logic;
        
begin

    Clk <= not Clk after 10ns;

    UUT : Sync
    generic map
    (
        IDLE_STATE  => '1'
    )
    port map
    (
        Clk     => Clk,
        Rst     => Rst,
        Async   => Async,
        Synced  => Synced
    );


    TestProcess:process
    begin
        Rst <= '1';
        Async <= '1';
        wait for 100ns;
        Rst <= '0';
        wait for 100ns;
        wait for 3ns;
        Async <= '0';
    
    
    
        wait;
    end process;


end rtl;