library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
--------------------------------------------------PORTS------------------------------------------------------------------------------------------
entity TopLevelModule is
  generic (
    RS232_DATA_BITS : integer := 8;
    SYS_CLK_FREQ    : integer := 50000000;
    BAUD_RATE       : integer := 9600;
	 sys_clk         : INTEGER := 50_000_000;
    pwm_freq        : INTEGER := 100_000;    
    bits_resolution : INTEGER := 8;          
    phases          : INTEGER := 1
	 
  );
  port (
    Clk             			: in std_logic;
    Rst             			: in std_logic;
    rs232_rx_pin    			: in std_logic;
    rs232_tx_pin    			: out std_logic;
	 enable      			   : IN  STD_LOGIC;                                    
    pwm_out   					: OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          
    pwm_n_out 					: OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);
	 sensor_reading_async	: in std_logic; --gpio1
	 sensor_writing			: inout std_logic; --gpio3
	 seven_segment1			: out std_logic_vector(6 downto 0);	--hex1
	 seven_segment2			: out std_logic_vector(6 downto 0); --hex0
	 i_Echo						:	in std_logic;-- Echo pulse back from sensor. Its one bit beacuse its only one pin.
	 o_Trigger					:	out std_logic;
	 o_Sev_seg_1				:	out std_logic_vector(6 downto 0); 	-- 7-segment display (Ones)
	 o_Sev_seg_2				:	out std_logic_vector(6 downto 0); 	-- 7-segment display (Tens)
	 o_Sev_seg_3				:	out std_logic_vector(6 downto 0); 	-- 7-segment display (Hundreds)
	 LED       		   		:  out std_logic;
	 hilo 						: in std_logic;
	 input 						: in std_logic;
	 waveform 					: out std_logic);
	 
	 
end entity;

architecture rtl of TopLevelModule is

----------------------------------------------------COMPONENT--------------------------------------------------------------------------------

  component risingedge_detector is
	 port 
	 (
		clk		: in std_logic;
		rst		: in std_logic;
		input 	: in std_logic;
		output 	: out std_logic
	 );
  end component;

  component dht_sensor is
    port (
        clk     					: in  std_logic;
		  rst		 					: in  std_logic;
		  start						: in  std_logic;
		  sensor_reading_async	: in std_logic;
		  sensor_writing  		: inout std_logic:='Z';
		  data_out					: out std_logic_vector(7 downto 0);
		  data_flag					: out std_logic
			);
  end component;

  component seven_seg is
    port (
        input          : in  std_logic_vector(7 downto 0);   -- 8-bit binary input
        seven_segment1 : out std_logic_vector(6 downto 0);  -- First 7-segment display output
        seven_segment2 : out std_logic_vector(6 downto 0)   -- Second 7-segment display output     
    );
  end component;

  component pwm

  GENERIC(
      sys_clk         : INTEGER ; --system clock frequency in Hz
      pwm_freq        : INTEGER ;    --PWM switching frequency in Hz
      bits_resolution : INTEGER ;          --bits of resolution setting the duty cycle
      phases          : INTEGER );         --number of output pwms and phases
    PORT(
      clk       : IN  STD_LOGIC;                                    --system clock
      reset_n   : IN  STD_LOGIC;                                    --asynchronous reset
      ena       : IN  STD_LOGIC;                                    --latches in new duty cycle
      duty      : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); --duty cycle
      pwm_out   : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0);          --pwm outputs
      pwm_n_out : OUT STD_LOGIC_VECTOR(phases-1 DOWNTO 0));

  end component;

  component UART_tx is
    generic (
      RS232_DATA_BITS : integer;
      SYS_CLK_FREQ    : integer;
      BAUD_RATE       : integer
    );
    port (
      Clk          : in std_logic;
      Rst          : in std_logic;
      TxStart      : in std_logic;
      TxData       : in std_logic_vector(RS232_DATA_BITS-1 downto 0);
      TxReady      : out std_logic;
      UART_tx_pin  : out std_logic
    );
  end component;

  component UART_rx is
    generic (
      DATA_WIDTH      : integer;
      SYS_CLK_FREQ    : integer;
      BAUD_RATE       : integer
    );
    port (
      Clk         : in std_logic;
      Rst         : in std_logic;
      RS232_Rx    : in std_logic;
      RxIRQClear  : in std_logic;
      RxIRQ       : out std_logic;
      RxData      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component;
  
  component buzzer
	Port ( 
			  clk_50 : in std_logic;
			  reset : in std_logic;
			  hilo : in std_logic;
			  input : in std_logic; -- Yeni giriş portu
			  waveform : out std_logic 
		 );
  end component;

  component HCSR04_sensor_interface
	 port
	 (
		-- Input ports
		i_Clock			: in std_logic;
		i_Reset_n		: in std_logic;
		i_Echo			: in std_logic;--measurement pulse from sensor. En bit eftersom det är ett pinne i sensor som skickar echo signal
		
		--Output ports
		o_Trigger		: out std_logic;
		o_Sen_interface_Ones	: out std_logic_vector(3 downto 0);
		o_Sen_interface_Tens	: out std_logic_vector(3 downto 0);
		o_Sen_interface_Hundreds	: out std_logic_vector(3 downto 0);
		o_DV_n			: out std_logic
	);
  end component;
	
  component seven_seg_dispayer
		port
		(
		--input
		i_Clock		: in std_logic;
		i_Reset_n	: in std_logic;
		i_Sev_seg_1	: in std_logic_vector(3 downto 0); 		
		i_Sev_seg_2	: in std_logic_vector(3 downto 0); 	
		i_Sev_seg_3	: in std_logic_vector(3 downto 0); 
		i_Dv_n		: in std_logic;
		
		--output
		o_Sev_seg_1	: out std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_2	: out std_logic_vector(6 downto 0); 	-- 7-segment display
		o_Sev_seg_3	: out std_logic_vector(6 downto 0); 	-- 7-segment displa
		LED1        : out std_logic;
		input_buzzer: out std_logic;
		selection 	: in std_logic
		);
	end component;

--------------------------------------------------------------SIGNALS-----------------------------------------------------------------------
  
  type SMType is (IDLE, START_TRANSMITTER);

  signal SMVariable   			: SMType;
  signal TxStart      			: std_logic;
  signal TxReady      			: std_logic;
  signal RxIRQ        			: std_logic;
  signal N_reset		 			: std_logic;
  signal dht_start				: std_logic;
  signal dht_interrupt			: std_logic;
  signal temp_temp_2				: integer range 0 to 60:=0;
  signal temp_temp				: integer range 0 to 60:=0;
  signal measured_temp  		: std_logic_vector(7 downto 0);
  signal count						: integer range 0 to 75000001:=0;
  signal actual_measured_temp : std_logic_vector(7 downto 0);
  signal RxData       			: std_logic_vector(RS232_DATA_BITS - 1 downto 0);
  signal duty         			: STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0);
  
  signal dv_HCSR04_sev_seg		: std_logic;
  signal buzzer_in 				: std_logic;
  signal selection				: std_logic;
  signal top_i_BCD_1				: std_logic_vector(3 downto 0);
  signal top_i_BCD_2				: std_logic_vector(3 downto 0);
  signal top_i_BCD_3				: std_logic_vector(3 downto 0);
  signal to_sev_display_1		: std_logic_vector(3 downto 0);
  signal to_sev_display_2		: std_logic_vector(3 downto 0);
  signal to_sev_display_3		: std_logic_vector(3 downto 0);
  signal reset_n_t1,reset_n_in	: std_logic;
  signal echo_pulse_t1,echo_pulse_t2, echo_pulse_in	: std_logic;

-------------------------------------------------PORTMAP--------------------------------------------------------------------------- 
begin
  
  UART_Transmitter 				  : UART_tx 					 generic map (RS232_DATA_BITS=>RS232_DATA_BITS,SYS_CLK_FREQ=>SYS_CLK_FREQ,BAUD_RATE=>BAUD_RATE)
																			 port map 	  (Clk=>Clk,Rst=>Rst,TxStart=>TxStart,TxData=>RxData,TxReady=>TxReady,UART_tx_pin=>rs232_tx_pin);

  UART_Receiver 					  : UART_rx 					 generic map (DATA_WIDTH=>RS232_DATA_BITS,SYS_CLK_FREQ=> SYS_CLK_FREQ,BAUD_RATE=>BAUD_RATE)
																			 port map (Clk=>Clk,Rst=>Rst,RS232_Rx=>rs232_rx_pin,RxIRQClear=>TxStart,RxIRQ=>RxIRQ,RxData=>RxData);
	 
  inst_pwm 							  : pwm 							 generic map (sys_clk=>sys_clk,pwm_freq=>pwm_freq,bits_resolution=>bits_resolution,phases=>phases)          
																			 port map(clk=>Clk,reset_n=>N_reset,ena=>enable,duty=>duty,pwm_out=>pwm_out,pwm_n_out=>pwm_n_out);

	sensor							  :dht_sensor 					 port map(Clk=>clk,Rst=>rst,start=>dht_start,sensor_reading_async=>sensor_reading_async,sensor_writing=>sensor_writing,data_out=>measured_temp,data_flag=>dht_interrupt);

	measured_temp_hex 			  :seven_seg  					 port map(input=>actual_measured_temp,seven_segment1=>seven_segment1,seven_segment2=>seven_segment2);
	
	inst_HCSR04_sensor_interface : HCSR04_sensor_interface port map(i_Clock=>Clk,i_Reset_n=>reset_n_in,i_Echo=>echo_pulse_in,o_Trigger=>o_Trigger,o_Sen_interface_Ones=>to_sev_display_1,o_Sen_interface_Tens=>to_sev_display_2,o_Sen_interface_Hundreds=>to_sev_display_3,o_DV_n=>dv_HCSR04_sev_seg);
	
	inst_seven_seg_dispayer 	  : seven_seg_dispayer 		 port map(i_Clock=>Clk,i_Reset_n=>reset_n_in,i_Sev_seg_1	=>to_sev_display_1,i_Sev_seg_2=>to_sev_display_2,i_Sev_seg_3=>to_sev_display_3, i_Dv_n=>dv_HCSR04_sev_seg,o_Sev_seg_1=>o_Sev_seg_1,o_Sev_seg_2=>o_Sev_seg_2,o_Sev_seg_3=>o_Sev_seg_3,LED1=>LED,selection =>selection,input_buzzer=>buzzer_in);
	
	inst_buzzer 					  : buzzer 						 port map(clk_50=>Clk,reset=>Rst,hilo=>hilo,input=>buzzer_in,waveform=>waveform );
	
	N_reset <= Not Rst;
	
	temp_temp <=to_integer(unsigned(measured_temp));

	temp_temp_2<=temp_temp-3;

	actual_measured_temp<=std_logic_vector(to_unsigned(temp_temp_2, 8));

-----------------------------------------------------PROCESS---------------------------------------------------------------------------------		


	generate_clk_dht:process(Rst,Clk)
	begin
		if Rst='1' then
			count<=0;
			dht_start<='0';
		elsif rising_edge(Clk) then
			dht_start<='0';
			count<=count+1;
				if count= 75000000 then
					dht_start<='1';
					count<=0;
				end if;
		end if;
	end process;

  
  StateMachineProcess: process(Rst, Clk)
  begin
    if Rst = '1' then
      SMVariable <= IDLE;
      TxStart <= '0';
    elsif rising_edge(Clk) then
      case SMVariable is
        when IDLE =>
          if RxIRQ = '1' and TxReady = '1' then
            SMVariable <= START_TRANSMITTER;
            TxStart <= '1';
          end if;
        when START_TRANSMITTER =>
          TxStart <= '0';
          SMVariable <= IDLE;
        when others =>
          SMVariable <= IDLE;
      end case;
    end if;
  end process;

	PWM_Speed : process(Clk)
		begin
			 if Rst = '1' then
				  duty <= (others => '0'); -- Reset durumunda tüm LED'leri kapat
			 elsif rising_edge(Clk) then
				  case RxData is
						when "00110001" =>
							 duty <= "10000000";
						when "00110010" =>
							 duty <= "11000000";
						when "00110011" =>
							 duty <= "11100000";
						when "00110100" =>
							 duty <= "11110000";
						when "00110101" =>
							 duty <= "11111000";
						when "00110110" =>
							 duty <= "11111100";
						when "00110111" =>
							 duty <= "11111110";
						when "00111000" =>
							 duty <= "11111111";
						when "00110000" =>
							 selection <= '0';
							 duty <= "10000000";
						when "00111001" =>
							 selection <= '1';
							 duty <= "10000000";
						when others =>
							 duty <= "10000000";
				  end case;
			 end if;
	end process;

	reset_n_meta_stability:process(Clk,Rst)
		begin
			if N_reset = '0' then
				reset_n_t1 <= '0';
				reset_n_in <= '0';
			elsif rising_edge(Clk) then
				reset_n_t1 <= '1';
				reset_n_in <= reset_n_t1;
			end if;
	end process reset_n_meta_stability;
	
	echo_pulse_meta_stability:process(Clk,reset_n_in)
		begin
		
			if reset_n_in = '0' then
				echo_pulse_t1 <= '0';
				echo_pulse_t2 <= '0';
				echo_pulse_in <= '0';
			elsif rising_edge(Clk) then
				echo_pulse_t1 <= i_Echo;
				echo_pulse_t2 <= echo_pulse_t1;
				echo_pulse_in <= echo_pulse_t2;
			end if;
				
	end process echo_pulse_meta_stability;

end rtl;
