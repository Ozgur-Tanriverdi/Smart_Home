library ieee;
use ieee.std_logic_1164.all;

entity Sync is
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
end entity;


architecture rtl of Sync is

    signal SR : std_logic_vector(1 downto 0);
    
begin

    Synced <= SR(1);
    
    SynchornisationProcess:process(Rst, Clk)
    begin
        if Rst = '1' then
            SR <= (others => IDLE_STATE);
        elsif rising_edge(Clk) then
            SR(0) <= Async;
            SR(1) <= SR(0);
        end if;
    end process;

end rtl;