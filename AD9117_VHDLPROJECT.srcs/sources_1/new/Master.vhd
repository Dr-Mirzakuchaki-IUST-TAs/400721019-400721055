library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--To use clock wizard
Library UNISIM; 
use UNISIM.vcomponents.all;

entity Master is
    Port(
        --SPI inputs
        SCLK            : in    STD_LOGIC;
        Data_In         : in    STD_LOGIC_VECTOR (39 downto 0);
        Start           : in    STD_LOGIC;
        --SPI outputs
        CS_n            : out   STD_LOGIC;
        RW_CTL          : out   STD_LOGIC;
        --SPI inout
        SDIO            : inout STD_LOGIC;
        
        --Parallel inputs
        CLK_SYSn        : in    STD_LOGIC;
        I_DAC_I         : in    STD_LOGIC_VECTOR (13 downto 0);
        Q_DAC_I         : in    STD_LOGIC_VECTOR (13 downto 0);
        --Parrallel outputs
        Data_Bus_O      : out   STD_LOGIC_VECTOR (13 downto 0);
        DCLKIO_O        : out   std_logic    
    );
    --
end Master;
--
architecture Behavioral of Master is

--MMCM clock Wizard configuration
component DCLK_125MHz
port
 (
  -- Clock out ports
  DCLK_125MHz_P         : out    std_logic;
  DCLK_125MHz_P_90      : out    std_logic;
  CLK_SPI               : out    std_logic;
  -- Clock in ports
  DCLK_125MHz_IN        : in     std_logic
 );
end component;
    --internal signals for ODDR
    signal CLK_SYS              : STD_LOGIC := '0';
    signal Data_Bus_int         : STD_LOGIC_VECTOR (13 downto 0) := (others => '0');
    signal DCLKIO_INT           : STD_LOGIC := '0';
    signal DCLK_125MHz_P_I      : STD_LOGIC := '0';
    signal DCLK_125MHz_P_90_I   : STD_LOGIC := '0';
    
    
    --SPI Input/Output Register
    signal CS_n_INT     :   STD_LOGIC                       := '1';
    signal RW_CTL_INT   :   STD_LOGIC                       := '0';
    signal Data_In_INT  :   STD_LOGIC_VECTOR (31 downto 0)  := (others => '0');
    signal Start_INT    :   STD_LOGIC                       := '0';
    --

    --SPI Internal Signals
    signal RX_Data      :   STD_LOGIC_VECTOR (31 downto 0)  := (others => '0');
    signal Inst_Byte    :   STD_LOGIC_VECTOR (7 downto 0)   := (others => '0');
    signal CNT_Limit    :   unsigned (4 downto 0)           := (others => '0');
    signal Tx           :   STD_LOGIC                       := 'Z';

    --SPI Counter
    signal Bit_CNT      :   unsigned (4 downto 0)           := "00111";
    --

    --SPI State
    type    FSM is (idle, instruction, write_s, read_s, delay_instruction, delay_read);
    signal  State       : FSM                               := idle;
    --
begin

your_instance_name : DCLK_125MHz
   port map ( 
  -- Clock out ports  
   DCLK_125MHz_P    => DCLK_125MHz_P_I,
   DCLK_125MHz_P_90 => DCLK_125MHz_P_90_I,
   CLK_SPI          => CLK_SYS,
   -- Clock in ports
   DCLK_125MHz_IN   => CLK_SYSn
 );
 --ODDR instantiation for DCLKIO
 DCLKIO_ODDR_inst : ODDR
    generic map(
        DDR_CLK_EDGE => "OPPOSITE_EDGE",    -- "OPPOSITE_EDGE" or "SAME_EDGE" 
        INIT         => '0',                -- Initial value for Q port ('1' or '0')
        SRTYPE       => "SYNC")             -- Reset Type ("ASYNC" or "SYNC")
    port map (
        Q            => DCLKIO_INT,         -- 1-bit DDR output
        C            => DCLK_125MHz_P_90_I, -- 1-bit clock input
        CE           => '1',                -- 1-bit clock enable input
        D1           => '0',                -- 1-bit data input (positive edge)
        D2           => '1',                -- 1-bit data input (negative edge)
        R            => '0',                -- 1-bit reset input
        S            => '0'                 -- 1-bit set input
    );
  

--OBUF instantiation for DCLKIO
 OBUF_inst : OBUF
 generic map (
    DRIVE           => 12,
    IOSTANDARD      => "DEFAULT",
    SLEW            => "SLOW")
 port map (
    O               => DCLKIO_O,            -- Buffer output (connect directly to top-level port)
    I               => DCLKIO_INT           -- Buffer input 
 );

--ODDR instantiation for I and Q Data
 Data_Bus_Gen : for i in 13 downto 0 generate

   Data_Bus_ODDR_inst : ODDR
   generic map(
      DDR_CLK_EDGE  => "OPPOSITE_EDGE",     -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT          => '0',                 -- Initial value for Q port ('1' or '0')
      SRTYPE        => "SYNC")              -- Reset Type ("ASYNC" or "SYNC")
   port map (
      Q             => Data_Bus_Int(i),     -- 1-bit DDR output
      C             => DCLK_125MHz_P_I,     -- 1-bit clock input
      CE            => '1',                 -- 1-bit clock enable input
      D1            => I_DAC_I(i),          -- 1-bit data input (positive edge)
      D2            => Q_DAC_I(i),          -- 1-bit data input (negative edge)
      R             => '0',                 -- 1-bit reset input
      S             => '0'                  -- 1-bit set input
   );
  
 end generate Data_Bus_Gen;                 -- End of ODDR_inst instantiation

 --OBUF instantiation for I and Q Data
 Data_Bus_OBUF_Gen : for i in 13 downto 0 generate

   OBUF_inst : OBUF
   generic map (
      DRIVE         => 12,
      IOSTANDARD    => "DEFAULT",
      SLEW          => "SLOW")
   port map (
      O             => Data_Bus_O(i),       -- Buffer output (connect directly to top-level port)
      I             => Data_Bus_Int(i)      -- Buffer input 
   );

   end generate Data_Bus_OBUF_Gen;          -- End of ODDR_inst instantiation
    --
    CS_n        <= CS_n_INT;
    RW_CTL      <= RW_CTL_INT;
    SDIO        <= Tx when RW_CTL_INT = '0' else 'Z';
    ---
    process (CLK_SYS)
    begin
        --
        if (rising_edge (CLK_SYS)) then
            --
            Data_In_INT     <= Data_In (31 downto 0);
            Inst_Byte       <= Data_In (39 downto 32);
            Start_INT       <= Start;
            --
            case State is
                --
                when idle =>
                    --
                    RW_CTL_INT      <= '0';
                    Tx              <= 'Z';
                    Bit_CNT         <= "00111";
                    Rx_Data         <= (others => '0');
                    --
                    if (Start_INT = '1') then
                        --
                        State       <= delay_instruction;
                        CS_n_INT    <= '0';
                        --
                        case to_integer (unsigned(Inst_Byte(6 downto 5))) is
                            --
                            when 0  =>
                            --
                                CNT_Limit       <= to_unsigned (24, 5);
                            --
                            when 1  =>
                            --
                                CNT_Limit       <= to_unsigned (16, 5);
                            --
                            when 2  =>
                                CNT_Limit       <= to_unsigned (8, 5);
                            --
                            when others =>
                                CNT_Limit       <= to_unsigned (0, 5);
                            --
                        end case;
                    else
                        --
                        State       <= idle;
                        CS_n_INT    <= '1';
                        CNT_Limit   <= (others => '0');
                        --
                    end if;
                    --
                when delay_instruction =>
                    State           <= instruction;
                    RW_CTL_INT      <= '0';
                    CS_n_INT        <= '0';
                    Tx              <= Inst_Byte (to_integer(Bit_CNT));
                    Bit_CNT         <= Bit_CNT - 1;
                    CNT_Limit       <= CNT_Limit;
                    Rx_Data         <= (others => '0');
                    --
                when instruction    =>
                    RW_CTL_INT      <= '0';
                    CS_n_INT        <= '0';
                    Tx              <= Inst_Byte (to_integer(Bit_CNT));
                    Rx_Data         <= (others => '0');
                    --
                    if (Bit_CNT /= 0) then
                        State       <= instruction;
                        Bit_CNT     <= Bit_CNT -1;
                    else
                        Bit_CNT     <= (others => '1');
                        if (Inst_Byte(7) = '0') then
                            State   <= write_S;
                        else
                            State   <= delay_read;
                        end if;
                    end if;
                when write_S    =>
                    RW_CTL_INT      <= '0';
                    CS_n_INT        <= '0';
                    Tx              <= Data_In_INT (to_integer(Bit_CNT));
                    Rx_Data         <=  (others => '0');
                    --
                    if (Bit_CNT /= CNT_Limit) then
                        State       <= write_S;
                        Bit_CNT     <= Bit_CNT - 1;
                        CNT_Limit   <= CNT_Limit;
                        --
                    else
                        State       <= idle;
                        Bit_CNT     <= "00111";
                        CNT_Limit   <= (others => '0');
                    end if;
                when delay_read =>
                    State       <= read_S;
                    RW_CTL_INT  <= '1';
                    CS_n_INT    <= '0';
                    Tx          <= 'Z';
                    Bit_CNT     <= Bit_CNT - 1;
                    CNT_Limit   <= CNT_Limit;
                    Rx_Data (to_integer(Bit_CNT))   <= SDIO;
                when others =>
                    RW_CTL_INT  <= '1';
                    CS_n_INT    <= '0';
                    Tx          <= 'Z';
                    CNT_Limit   <= CNT_Limit;
                    Rx_Data (to_integer(Bit_CNT)) <= SDIO;
                    --
                    if (Bit_CNT /= CNT_Limit) then
                        State   <= read_S;
                        Bit_CNT <= Bit_CNT - 1;
                    else
                        State   <= idle;
                        Bit_CNT <= "00111";
                    end if;
                end case;
            end if;
        end process;
    end Behavioral;