library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister is
generic 
(
    CHAIN_LENGTH    : integer;
    SHIFT_DIRECTION : character -- 'L' generates a shift to the left. 'R' generates a shift to the right
);
port
(
    Clk         : in std_logic;
    Rst         : in std_logic;
    
    ShiftEn     : in std_logic;
    Din         : in std_logic;
    Dout        : out std_logic_vector(CHAIN_LENGTH - 1 downto 0)
);
end entity;

architecture rtl of ShiftRegister is

    signal SR : std_logic_vector(CHAIN_LENGTH - 1 downto 0);

begin

    Dout <= SR;

    SHIFT_TO_THE_RIGHT : if SHIFT_DIRECTION = 'R' generate
    -- Shift SR to the right (when the serial data is transmitted LSB first)
    
        ShiftProcess:process(Rst, Clk)
        begin
            if Rst = '1' then
                SR <= (others => '0');
            elsif rising_edge(Clk) then
                if ShiftEn = '1' then
                    SR <= Din & SR(SR'left downto 1);
                end if;
            end if;
        end process;
        
    end generate;

    SHIFT_TO_THE_LEFT : if SHIFT_DIRECTION = 'L' generate
    -- Shift SR to the left (when the serial data is transmitted MSB first)
    
        ShiftProcess:process(Rst, Clk)
        begin
            if Rst = '1' then
                SR <= (others => '0');
            elsif rising_edge(Clk) then
                if ShiftEn = '1' then
                    SR <= SR(SR'left - 1 downto 0) & Din;
                end if;
            end if;
        end process;
        
    end generate;

    

end rtl;