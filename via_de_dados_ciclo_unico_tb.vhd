library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity via_de_dados_ciclo_unico_tb is
end;

architecture bench of via_de_dados_ciclo_unico_tb is

  component via_de_dados_ciclo_unico
      port (
      clock : in std_logic;
		reset     : in std_logic;
      controle : in std_logic_vector( 17 - 1 downto 0);
      instrucao : in std_logic_vector(32 - 1 downto 0);
      pc_out : out std_logic_vector(32- 1 downto 0);
      saida : out std_logic_vector(32 - 1 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 20 ns;

  --Ports
  signal clock : std_logic;
  signal reset : std_logic;
  signal controle : std_logic_vector(17- 1 downto 0);
  signal instrucao : std_logic_vector(32 - 1 downto 0);
  signal pc_out : std_logic_vector(32 - 1 downto 0);
  signal saida : std_logic_vector(32 - 1 downto 0);

begin

  via_de_dados_ciclo_unico_inst : via_de_dados_ciclo_unico
    port map (
      clock => clock,
		reset => reset,
      controle => controle,
      instrucao => instrucao,
      pc_out => pc_out,
      saida => saida
    );

--   clk_process : process
--   begin
--   clock <= '1';
--   wait for clk_period/2;
--    wait for 10 ns;
--   clock <= '0';
--  wait for clk_period/2;
--    wait for 10 ns;
--   end process clk_process;

	stimulus: process
	begin
	
	controle <= "10011101010000000";
	instrucao <= "00000000000000100000000010001011";
	reset <= '0';
	wait;
	end process stimulus;
	
	clock <= not clock after clk_period/2;
	
end;
