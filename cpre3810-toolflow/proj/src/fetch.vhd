library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
  port (
    -- clocking
    i_CLK        : in  std_logic;
    i_RST        : in  std_logic;                     -- active-high reset

    -- control inputs
    i_UseNextAdr : in  std_logic;                   
    i_Stall      : in  std_logic;                    
    i_NextAdr    : in  std_logic_vector(31 downto 0);

    -- instruction memory interface (byte address)
    o_IMemAdr    : out std_logic_vector(31 downto 0);
    i_IMemData   : in  std_logic_vector(31 downto 0);

    -- outputs
    o_PC         : out std_logic_vector(31 downto 0);
    o_PCplus4    : out std_logic_vector(31 downto 0);
    o_Instr      : out std_logic_vector(31 downto 0) 
  );
end entity;

architecture structural of fetch is
  -- component declarations (from Lab 1/2) 
  component adder_n
    generic (N : integer := 32);
    port (
      iA   : in  std_logic_vector(N-1 downto 0);
      iB   : in  std_logic_vector(N-1 downto 0);
      oSum : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mux2t1_n
    generic (N : integer := 32);
    port (
      i_S  : in  std_logic;                           -- 0 -> i_D0, 1 -> i_D1
      i_D0 : in  std_logic_vector(N-1 downto 0);
      i_D1 : in  std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component reg_n
    generic (N : integer := 32);
    port (
      i_CLK : in  std_logic;
      i_RST : in  std_logic;                          -- active-high reset
      i_WE  : in  std_logic;                          -- write enable
      i_D   : in  std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  --  internal signals 
  signal s_PC       : std_logic_vector(31 downto 0);
  signal s_PCplus4  : std_logic_vector(31 downto 0);
  signal s_NextSeq  : std_logic_vector(31 downto 0);
  signal s_NextPC   : std_logic_vector(31 downto 0);
begin
  -- [Adder] Compute PC+4
  u_add_pc4 : adder_n
    port map (
      iA   => s_PC,
      iB   => x"00000004",
      oSum => s_PCplus4
    );

  -- [Redirect MUX] Select sequential (PC+4) vs redirect target (branch/jump)
  u_mux_next : mux2t1_n
    port map (
      i_S  => i_UseNextAdr,  -- 0: s_PCplus4, 1: i_NextAdr
      i_D0 => s_PCplus4,
      i_D1 => i_NextAdr,
      o_O  => s_NextSeq
    );

  -- [Stall MUX] Hold current PC when i_Stall='1'
  u_mux_stall : mux2t1_n
    port map (
      i_S  => i_Stall,       -- 0: update (s_NextSeq), 1: hold (s_PC)
      i_D0 => s_NextSeq,
      i_D1 => s_PC,
      o_O  => s_NextPC
    );

  -- [PC Register] Update PC on rising edge / reset to 0x400000 (RARS default)
  pc_process : process(i_CLK, i_RST)
  begin
    if (i_RST = '1') then
      s_PC <= x"00400000";  -- Reset PC to RARS default address
    elsif (rising_edge(i_CLK)) then
      if (i_Stall = '0') then  -- Only update if not stalled
        s_PC <= s_NextPC;
      end if;
    end if;
  end process;

  -- [Outputs / IMEM]
  o_PC      <= s_PC;
  o_PCplus4 <= s_PCplus4;
  o_IMemAdr <= s_PC;            -- byte address into instruction memory
  o_Instr   <= i_IMemData;      -- pass-through instruction word
end architecture;