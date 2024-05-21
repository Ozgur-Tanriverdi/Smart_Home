library ieee;
use ieee.std_logic_1164.all;

entity TopLevelModule is
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
end entity;


architecture rtl of TopLevelModule is

    component UART_tx is
    generic 
    (
        RS232_DATA_BITS : integer;
        SYS_CLK_FREQ    : integer;
        BAUD_RATE       : integer
    );
    port
    (
       Clk          : in std_logic; -- 50MHz
       Rst          : in std_logic;
       
       TxStart      : in std_logic;
       TxData       : in std_logic_vector(RS232_DATA_BITS-1 downto 0);
       TxReady      : out std_logic;
       UART_tx_pin  : out std_logic
    );
    end component;
    
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
    
    type SMType is (IDLE, START_TRANSMITTER);
 
    signal SMVariable   : SMType;
    signal TxStart      : std_logic;
    signal TxReady      : std_logic;
    signal RxIRQ        : std_logic;
    signal RxData       : std_logic_vector(RS232_DATA_BITS - 1 downto 0);
    
begin
    
    
    UART_Transmitter : UART_tx
    generic map
    (
        RS232_DATA_BITS => RS232_DATA_BITS,
        SYS_CLK_FREQ    => SYS_CLK_FREQ,
        BAUD_RATE       => BAUD_RATE
    )
    port map
    (
       Clk          => Clk,
       Rst          => Rst,
       
       TxStart      => TxStart,
       TxData       => RxData,
       TxReady      => TxReady,
       UART_tx_pin  => rs232_tx_pin
    );

    
    
    UART_Receiver : UART_rx
    generic map
    (
        DATA_WIDTH      => RS232_DATA_BITS,
        SYS_CLK_FREQ    => SYS_CLK_FREQ,
        BAUD_RATE       => BAUD_RATE
    )
    port map
    (
        Clk          => Clk,
        Rst          => Rst,
        RS232_Rx     => rs232_rx_pin,
        RxIRQClear   => TxStart,
        RxIRQ        => RxIRQ,
        RxData       => RxData
    );
    
    
    StateMachineProcess:process(Rst, Clk)
    begin
        if Rst = '1' then
            SMVariable <= IDLE;
            TxStart <= '0';
        elsif rising_edge(CLk) then
        
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
    
end rtl;