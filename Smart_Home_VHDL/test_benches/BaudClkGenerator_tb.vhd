library ieee;
use ieee.std_logic_1164.all;

entity BaudClkGenerator_tb is
end entity;

architecture rtl of BaudClkGenerator_tb is

    component BaudClkGenerator is
    generic 
    (
        NUMBER_OF_CLOCKS    : integer;
        SYS_CLK_FREQ        : integer;
        BAUD_RATE           : integer
    );
    port
    (
        Clk : in std_logic; -- 50MHz
        Rst : in std_logic;
        
        Start   : in std_logic;
        BaudClk : out std_logic;
        Ready   : out std_logic
    );
    end component;

    signal Clk : std_logic := '0';
    signal Rst : std_logic;
    signal Start : std_logic;
    signal BaudClk : std_logic;
    signal Ready : std_logic;
    
begin

    Clk <= not Clk after 10ns;
    
    UUT : BaudClkGenerator
    generic map
    (
        NUMBER_OF_CLOCKS    => 10,
        SYS_CLK_FREQ        => 50000000,
        BAUD_RATE           => 115200
    )
    port map
    (
        Clk => Clk,
        Rst => Rst,
        
        Start   => Start,
        BaudClk => BaudClk,
        Ready   => Ready
    );
    
    
    main:process
    begin
        Rst <= '1';
        Start <= '0';
        wait for 100ns;
        Rst <= '0';
        
        wait until rising_edge(Clk);
        Start <= '1';
        wait until rising_edge(Clk);
        Start <= '0';
        
        wait;
    end process;


end rtl;