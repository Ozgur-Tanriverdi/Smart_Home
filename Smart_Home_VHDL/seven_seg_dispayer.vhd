

Library ieee;
USE ieee.std_logic_1164.all;

entity seven_seg_dispayer is
port( 

		--input
		i_Clock		:	in std_logic;
		i_Reset_n	:	in std_logic;
		i_Sev_seg_1	:	in std_logic_vector(3 downto 0); 		
		i_Sev_seg_2	:	in std_logic_vector(3 downto 0); 	
		i_Sev_seg_3	:	in std_logic_vector(3 downto 0); 
		i_Dv_n		:	in std_logic;
		
		--output
		o_Sev_seg_1	:	out std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_2	:	buffer  std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_3	:	out std_logic_vector(6 downto 0); 
		LED1        :  out std_logic;
		selection   :	in std_logic;
		input_buzzer:  out std_logic
		
	);
end seven_seg_dispayer;
		
architecture Behavioral of seven_seg_dispayer is

	-- Build an enumerated type for the statemachine
	type state_type is (idle, handle_in_data, display_seven_seg);
	-- Register to hold the current state
	signal state: state_type;

	signal 	sev_seg_1 : std_logic_vector(6 downto 0);
	signal 	sev_seg_2 : std_logic_vector(6 downto 0);
	signal 	sev_seg_3 : std_logic_vector(6 downto 0);
	signal distance_decimal : natural := 0;
	signal distance_decimal1 : natural := 0;
	constant showZero : std_logic_vector(6 downto 0) := "1000000"; -- 0x40
	constant showOne : std_logic_vector(6 downto 0)	:= "1111001";-- 0x79
	constant showTwo : std_logic_vector(6 downto 0)	:= "0100100";-- 0x24
	constant showThree : std_logic_vector(6 downto 0) := "0110000";-- 0x30
	constant showFour : std_logic_vector(6 downto 0) :=	"0011001";-- 0x19
	constant showFive : std_logic_vector(6 downto 0) := "0010010";-- 0x12
	constant showSex : std_logic_vector(6 downto 0) := "0000010"; -- 0x02
	constant showSeven : std_logic_vector(6 downto 0) := "1111000"; -- 0x38
	constant showEight : std_logic_vector(6 downto 0) := "0000000"; -- 0x00
	constant showNine : std_logic_vector(6 downto 0) := "0011000"; -- 0x18
	constant reset : std_logic_vector(6 downto 0) := "0000000"; -- 0x07	

	
-- pic of segmentet number on 7-segmentmentnummer on DE-10 Lite board:
--
--   -0
-- |5  |1
--   -6
-- |4  |2
--   -3
--
-- 0 to activate the segment, 1 to deactivate.
--

begin

	svens_seg: process(i_Clock, i_Reset_n)
	
		begin
			if i_Reset_n = '0' then
				sev_seg_1 <= (others => '0');
			 	sev_seg_2 <= (others => '0');
			 	sev_seg_3 <= (others => '0');
				o_Sev_seg_1 <= (others => '0');
				o_Sev_seg_2 <= (others => '0');
				o_Sev_seg_3 <= (others => '0');
				state <= idle;
			
			elsif rising_edge(i_Clock) then
			
				case state is
					
					when idle =>
						
						if i_Dv_n = '0' then	
							state <= handle_in_data;
						else
							state <= idle;
						end if;
					
					
					when handle_in_data =>
						distance_decimal <= 0;
						case i_Sev_seg_1 is
								when "0000" => sev_seg_1 <= showZero;
								when "0001" => sev_seg_1 <= showOne;
								when "0010" => sev_seg_1 <= showTwo;
								when "0011" => sev_seg_1 <= showThree;
								when "0100" => sev_seg_1 <= showFour;
								when "0101" => sev_seg_1 <= showFive;
								when "0110" => sev_seg_1 <= showSex;
								when "0111" => sev_seg_1 <= showSeven;
								when "1000" => sev_seg_1 <= showEight;
								when "1001" => sev_seg_1 <= showNine;
								when others => sev_seg_1 <= reset;
						end case;	
							

						case i_Sev_seg_2 is
								when "0000" => sev_seg_2 <= showZero;
								when "0001" => sev_seg_2 <= showOne;
								when "0010" => sev_seg_2 <= showTwo;
								when "0011" => sev_seg_2 <= showThree;
								when "0100" => sev_seg_2 <= showFour;
								when "0101" => sev_seg_2 <= showFive;
								when "0110" => sev_seg_2 <= showSex;
								when "0111" => sev_seg_2 <= showSeven;
								when "1000" => sev_seg_2 <= showEight;
								when "1001" => sev_seg_2 <= showNine;
								when others => sev_seg_2 <= reset;
						end case;
											
						case i_Sev_seg_3 is
								when "0000" => sev_seg_3 <= showZero;
								when "0001" => sev_seg_3 <= showOne;
								when "0010" => sev_seg_3 <= showTwo;
								when "0011" => sev_seg_3 <= showThree;
								when "0100" => sev_seg_3 <= showFour;
								when "0101" => sev_seg_3 <= showFive;
								when "0110" => sev_seg_3 <= showSex;
								when "0111" => sev_seg_3 <= showSeven;
								when "1000" => sev_seg_3 <= showEight;
								when "1001" => sev_seg_3 <= showNine;
								when others => sev_seg_3 <= reset;
						end case;
						
						case i_Sev_seg_1 is
							  when "0000" => distance_decimal <= distance_decimal + 0;
							  when "0001" => distance_decimal <= distance_decimal + 1;
							  when "0010" => distance_decimal <= distance_decimal + 2;
							  when "0011" => distance_decimal <= distance_decimal + 3;
							  when "0100" => distance_decimal <= distance_decimal + 4;
							  when "0101" => distance_decimal <= distance_decimal + 5;
							  when "0110" => distance_decimal <= distance_decimal + 6;
							  when "0111" => distance_decimal <= distance_decimal + 7;
							  when "1000" => distance_decimal <= distance_decimal + 8;
							  when "1001" => distance_decimal <= distance_decimal + 9;
							  when others => null; -- Varsayılan değer
						 end case;

						 -- Onlar basamağı
						 case i_Sev_seg_2 is
							  when "0000" => distance_decimal <= distance_decimal + 0;
							  when "0001" => distance_decimal <= distance_decimal + 10;
							  when "0010" => distance_decimal <= distance_decimal + 20;
							  when "0011" => distance_decimal <= distance_decimal + 30;
							  when "0100" => distance_decimal <= distance_decimal + 40;
							  when "0101" => distance_decimal <= distance_decimal + 50;
							  when "0110" => distance_decimal <= distance_decimal + 60;
							  when "0111" => distance_decimal <= distance_decimal + 70;
							  when "1000" => distance_decimal <= distance_decimal + 80;
							  when "1001" => distance_decimal <= distance_decimal + 90;
							  when others => null; -- Varsayılan değer
						 end case;

						 -- Yüzler basamağı
						 case i_Sev_seg_3 is
							  when "0000" => distance_decimal <= distance_decimal + 0;
							  when "0001" => distance_decimal <= distance_decimal + 100;
							  when "0010" => distance_decimal <= distance_decimal + 200;
							  when "0011" => distance_decimal <= distance_decimal + 300;
							  when "0100" => distance_decimal <= distance_decimal + 400;
							  when "0101" => distance_decimal <= distance_decimal + 500;
							  when "0110" => distance_decimal <= distance_decimal + 600;
							  when "0111" => distance_decimal <= distance_decimal + 700;
							  when "1000" => distance_decimal <= distance_decimal + 800;
							  when "1001" => distance_decimal <= distance_decimal + 900;
							  when others => null; -- Varsayılan değer
						 end case;
						 
						 
						if i_Dv_n = '1' then
							state <= display_seven_seg;
						else
							state<= idle;
						end if;
							
					when display_seven_seg =>
						o_Sev_seg_1 <= sev_seg_1;
						o_Sev_seg_2 <= sev_seg_2;
						o_Sev_seg_3 <= sev_seg_3;
						
						distance_decimal1 <= distance_decimal;
						
					   case selection is
							when '0' => --0
								if o_Sev_seg_2 = "1111001" then
									LED1 <= '1'; -- LED'i yansıt
									input_buzzer <= '0';
								else
									LED1 <= '0'; -- LED'i söndür
									input_buzzer <= '0';
								end if;
							when '1' => --1
								if o_Sev_seg_2 = "1111001" then
									input_buzzer <= '1'; -- LED'i yansıt
									LED1 <= '0';
								else
									input_buzzer <= '0'; -- LED'i söndür
									LED1 <= '0';
								end if;
							when others => --Default
								input_buzzer <= '0';
								LED1 <= '0'; -- LED'i söndür
						end case;
						
						if i_Dv_n = '0' then
							state <= handle_in_data;
						else
							state <= display_seven_seg;
						end if;
						
				end case;	
				
			end if;

			
		end process;
		
		

			
end Behavioral;
