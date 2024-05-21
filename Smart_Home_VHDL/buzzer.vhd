library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity buzzer is
    Port ( 
        clk_50 : in std_logic;
        reset : in std_logic;
        hilo : in std_logic;
        input : in std_logic; -- Yeni giriş portu
        waveform : out std_logic 
    );
end buzzer;

architecture Behavioral of buzzer is

    signal waveform_reg, waveform_next : std_logic;
    signal counter_reg, counter_next : std_logic_vector(15 downto 0);
    signal flip_tick : std_logic;
    signal active : std_logic; -- Sesin açık veya kapalı olma durumu

begin

    process (clk_50, reset, input) -- input portu eklendi
    begin
        if (reset = '1') then
            counter_reg <= (others => '0');
            waveform_reg <= '0';
            active <= '0'; -- Başlangıçta ses kapalı
        else 
            if (clk_50'event and clk_50 = '1') then 
                waveform_reg <= waveform_next;
                counter_reg <= counter_next;
            end if;
        end if;

        -- input portuna göre active sinyalini ayarla
        if input = '1' then
            active <= '1';
        else
            active <= '0';
        end if;
    end process;

    flip_tick <= '1' when (counter_reg(15 downto 13) = "111" and hilo = '0') or (counter_reg(15) = '1' and hilo = '1') else '0'; 
    
    waveform_next <= (waveform_reg xor flip_tick) and active;
    counter_next <= counter_reg + 1 when flip_tick = '0' else (others => '0');
    waveform <= waveform_reg;

end Behavioral;
