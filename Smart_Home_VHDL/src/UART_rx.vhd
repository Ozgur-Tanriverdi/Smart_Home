library ieee;
use ieee.std_logic_1164.all;

entity UART_rx is
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
end entity;


architecture rtl of UART_rx is

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
    
    component BaudClkGenerator is
    generic 
    (
        NUMBER_OF_CLOCKS    : integer;
        SYS_CLK_FREQ        : integer;
        BAUD_RATE           : integer;
        UART_RX             : boolean  -- True if BaudClkGenerator is used in the UART Rx module, false otherwise.
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
    
    component ShiftRegister is
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
    end component;
    
    type SMDataType is (IDLE, COLLECT_RS232_DATA, ASSERT_IRQ);
    
    signal SMStateVariable          : SMDataType;
    signal RS232_Rx_Synced          : std_logic;
    signal Start                    : std_logic;
    signal BaudClk                  : std_logic;
    signal Ready                    : std_logic;
    signal FallingEdge              : std_logic;
    signal RS232_Rx_Synced_Delay    : std_logic;
 
begin

    Sync_Rx : Sync
    generic map
    (
        IDLE_STATE  => '1'
    )
    port map
    (
        Clk     => Clk,
        Rst     => Rst,
        Async   => RS232_Rx,
        Synced  => RS232_Rx_Synced
    );

    
    BaudClkGenerator_Rx : BaudClkGenerator
    generic map
    (
        NUMBER_OF_CLOCKS    => DATA_WIDTH + 1,
        SYS_CLK_FREQ        => SYS_CLK_FREQ,
        BAUD_RATE           => BAUD_RATE,
        UART_RX             => true
    )
    port map
    (
        Clk     => Clk,
        Rst     => Rst,
        
        Start   => Start,
        BaudClk => BaudClk,
        Ready   => Ready
    );

    
    ShiftRegister_Rx : ShiftRegister
    generic map
    (
        CHAIN_LENGTH    => DATA_WIDTH,
        SHIFT_DIRECTION => 'R' -- 'L' generates a shift to the left. 'R' generates a shift to the right
    )
    port map
    (
        Clk     => Clk,
        Rst     => Rst,
        
        ShiftEn => BaudClk,
        Din     => RS232_Rx_Synced,
        Dout    => RxData
    );


    FallingEdgeDetect:process(Rst,Clk)
    begin
        if Rst = '1' then
            FallingEdge <= '0';
            RS232_Rx_Synced_Delay <= '1';
        elsif rising_edge(Clk) then
            RS232_Rx_Synced_Delay <= RS232_Rx_Synced;
            
            if RS232_Rx_Synced = '0' and RS232_Rx_Synced_Delay = '1' then
                FallingEdge <= '1';
            else
                FallingEdge <= '0';
            end if;
            
        end if;
    end process;
    
    
    RxStateMachine:process(Rst,Clk)
    begin
        if Rst = '1' then
            Start <= '0';
            RxIRQ <= '0';
            SMStateVariable <= IDLE;
        elsif rising_edge(Clk) then
        
            if RxIRQClear = '1' then
                RxIRQ <= '0';
            end if;
        
            case SMStateVariable is
                
                when IDLE =>
                    if FallingEdge = '1' then
                        Start <= '1';
                    else
                        Start <= '0';
                    end if;
                    
                    if Ready = '0' then
                        SMStateVariable <= COLLECT_RS232_DATA;
                    end if;
                    
                when COLLECT_RS232_DATA =>
                    Start <= '0';
                    if Ready = '1' then
                        SMStateVariable <= ASSERT_IRQ;
                    end if;
                    
                when ASSERT_IRQ =>
                    RxIRQ <= '1';
                    SMStateVariable <= IDLE;
                    
                when others => 
                    SMStateVariable <= IDLE;
                    
            end case;
            
        end if;
    end process;
    
end rtl;