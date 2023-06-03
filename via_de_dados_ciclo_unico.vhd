-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;

entity via_de_dados_ciclo_unico is
	generic (
		-- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
		dp_ctrl_bus_width : natural := 17; -- tamanho do barramento de controle da via de dados (DP) em bits --JARL acrescenta 1?
		data_width        : natural := 32; -- tamanho do dado em bits
		pc_width          : natural := 32; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
		fr_addr_width     : natural := 8; -- tamanho da linha de endereços do banco de registradores em bits
		ula_ctrl_width    : natural := 3 -- tamanho da linha de controle da ULA
	);
	port (
		-- declare todas as portas da sua via_dados_ciclo_unico aqui.
		clock     : in std_logic;
		reset     : in std_logic;
		controle  : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
		instruct  : out std_logic_vector(data_width - 1 downto 0);
		saida     : out std_logic_vector(data_width - 1 downto 0)
	);
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

	-- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
	component pc is
		generic (
			pc_width : natural := 32
		);
		port (
			entrada : in std_logic_vector(pc_width - 1 downto 0);
			saida   : out std_logic_vector(pc_width - 1 downto 0);
			clk     : in std_logic;
			we      : in std_logic;
			reset   : in std_logic
		);
	end component;

	component somador is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component banco_registradores is
		generic (
			largura_dado : natural := 32;
			largura_ende : natural := 8
		);
		port (
			ent_rs_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rt_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_ende : in std_logic_vector((largura_ende - 1) downto 0);
			ent_rd_dado : in std_logic_vector((largura_dado - 1) downto 0);
			sai_rs_dado : out std_logic_vector((largura_dado - 1) downto 0);
			sai_rt_dado : out std_logic_vector((largura_dado - 1) downto 0);
			clk         : in std_logic;
			we          : in std_logic
		);
	end component;

	component ula is
		generic (
			largura_dado : natural := 32
		);
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			seletor   : in std_logic_vector(2 downto 0);
			saida     : out std_logic_vector((largura_dado - 1) downto 0);
			equal     : out std_logic
		);
	end component;

	component deslocador is
		generic (
		largura_dado : natural := 32;
		largura_qtde : natural := 5
	);

	port (
		ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
		ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
		ent_tipo_deslocamento : in std_logic_vector(1 downto 0);
		sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
	);
	end component;

	component deslocador_2 is
		generic (
		largura_dado : natural := 27;
		largura_qtde : natural := 5
	);

	port (
		ent_rs_dado           : in std_logic_vector((largura_dado - 1) downto 0);
		ent_rt_ende           : in std_logic_vector((largura_qtde - 1) downto 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
		ent_tipo_deslocamento : in std_logic_vector(1 downto 0);
		sai_rd_dado           : out std_logic_vector((largura_dado - 1) downto 0)
	);
	end component;

	component extensor is
		generic (
		largura_dado  : natural := 8;
		largura_saida : natural := 32
	);

	port (
		entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0);
		saida      : out std_logic_vector((largura_saida - 1) downto 0)
	);
	end component;

	component extensor_2 is
		generic (
		largura_dado  : natural := 25;
		largura_saida : natural := 27
	);

	port (
		entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0);
		saida      : out std_logic_vector((largura_saida - 1) downto 0)
	);
	end component;

	component multiplicador is
		generic (
			largura_dado : natural := 32
		);
	
		port (
			entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
			entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
			saida     : out std_logic_vector((2 * largura_dado - 1) downto 0)
		);
	end component;

	component mux21 is
		generic (
			largura_dado : natural := 32
		);
		port (
			dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent               : in std_logic;
			dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component mux21_8bits is
		generic (
			largura_dado : natural := 8
		);
		port (
			dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent               : in std_logic;
			dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component mux4_1 is
		generic (
			largura_dado : natural :=32
		);
		port (
			dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : in std_logic_vector((largura_dado - 1) downto 0);
			sele_ent                                       : in std_logic_vector(1 downto 0);
			dado_sai                                       : out std_logic_vector((largura_dado - 1) downto 0)
		);
	end component;

	component memd is
		generic (
        number_of_words : natural := 128; -- número de words que a sua memória é capaz de armazenar
        MD_DATA_WIDTH   : natural := 32; -- tamanho da palavra em bits
        MD_ADDR_WIDTH   : natural := 12 -- tamanho do endereco da memoria de dados em bits
    );
    port (
        clk                 : in std_logic;
        mem_write, mem_read : in std_logic; --sinais do controlador
        write_data_mem      : in std_logic_vector(MD_DATA_WIDTH - 1 downto 0);
        adress_mem          : in std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);
        read_data_mem       : out std_logic_vector(MD_DATA_WIDTH - 1 downto 0)
    );
	end component;

	component memi is
		generic (
		INSTR_WIDTH   : natural := 32; -- tamanho da instrucaoo em numero de bits
		MI_ADDR_WIDTH : natural := 12  -- tamanho do endereco da memoria de instrucoes em numero de bits (Total de instrucoes possíveis: 2^12)
	);
	port (
		clk       : in std_logic;
		reset     : in std_logic;
		Endereco  : in std_logic_vector(MI_ADDR_WIDTH - 1 downto 0);
		Instrucao : out std_logic_vector(INSTR_WIDTH - 1 downto 0)
	);
	end component;
	
	component registrador is
		generic (
		largura_dado : natural := 32
	);
	port (
        entrada_dados  : in std_logic_vector((largura_dado - 1) downto 0);
        WE, clk, reset : in std_logic;
        saida_dados    : out std_logic_vector((largura_dado - 1) downto 0)
	);

	end component;

	-- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
	-- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
	-- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
	-- componentes onde serão usados.
	-- Veja os exemplos abaixo:
	signal instrucao        : std_logic_vector(32 - 1 downto 0);
	signal aux_read_rs      : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_read_rt      : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_select_rd    : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_write_rd     : std_logic_vector(fr_addr_width - 1 downto 0);
	signal aux_data_in      : std_logic_vector(data_width - 1 downto 0);
	signal aux_data_outrs   : std_logic_vector(data_width - 1 downto 0);
	signal aux_data_outrt   : std_logic_vector(data_width - 1 downto 0);
	signal aux_entrada_b    : std_logic_vector(data_width - 1 downto 0);
	signal aux_out_ula      : std_logic_vector(data_width - 1 downto 0);
	signal aux_out_memd     : std_logic_vector(data_width - 1 downto 0);
	signal aux_out_dado     : std_logic_vector(data_width - 1 downto 0);
	signal out_LO           : std_logic_vector(data_width - 1 downto 0);
	signal out_HI           : std_logic_vector(data_width - 1 downto 0);
	signal out_reg_mult     : std_logic_vector(data_width - 1 downto 0);
	signal aux_reg_write    : std_logic;
	signal aux_men_write    : std_logic;
	signal aux_jalr         : std_logic;
	signal aux_equal        : std_logic;
	signal aux_jump_equal   : std_logic;
	signal aux_branch       : std_logic;
	signal aux_outmemi      : std_logic_vector(32 - 1 downto 0);
	signal saida_multiplicador  : std_logic_vector((2 * 32 - 1) downto 0);


	signal aux_ula_ctrl     : std_logic_vector(ula_ctrl_width - 1 downto 0);

	signal aux_pc_out       : std_logic_vector(pc_width - 1 downto 0);
	signal aux_prox_pc      : std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_select    : std_logic_vector(pc_width - 1 downto 0);
	signal aux_pc_beq       : std_logic_vector(pc_width - 1 downto 0);
	signal aux_jump_out     : std_logic_vector(pc_width - 1 downto 0);
	signal aux_dado_shifter : std_logic_vector(pc_width - 1 downto 0);
	signal aux_novo_pc      : std_logic_vector(pc_width - 1 downto 0);
	signal aux_shifter      : std_logic_vector(1 downto 0);
	signal aux_we           : std_logic;
	signal aux_mux_rd       : std_logic;	
	signal aux_mux_ula      : std_logic;
	signal aux_pc_jump      : std_logic;
	signal aux_select_HILO  : std_logic;
	signal aux_write_mult   : std_logic;
	signal aux_out_extensor : std_logic_vector(data_width - 1 downto 0);
	signal aux_imen_desloc  : std_logic_vector(data_width - 1 downto 0);
	signal aux_select_dado  : std_logic_vector(1 downto 0);
	signal aux_imem_jump    : std_logic_vector(24 downto 0);
	signal aux_end_desloc   : std_logic_vector(26 downto 0);
	signal aux_imem_jump_exten: std_logic_vector(26 downto 0);
	signal aux_jump_pc  : std_logic_vector(data_width - 1 downto 0);

begin

	-- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
	-- os sinais que você acabou de definir.
	-- Veja os exemplos abaixo:
	instrucao       <= aux_outmemi;
	aux_read_rs   	<= instrucao(31 downto 24);  
	aux_read_rt   	<= instrucao(23 downto 16); 
	aux_select_rd 	<= instrucao(15 downto 8); 
	aux_reg_write 	<= controle(9);            
	aux_men_write 	<= controle(2); 
	aux_jalr      	<= controle(13);
	aux_ula_ctrl  	<= controle(6 downto 4);   
	aux_we        	<= controle(16);            
	aux_mux_rd    	<= controle(8);            
	aux_mux_ula   	<= controle(7);   
	aux_branch    	<= controle(3);
	aux_select_HILO <= controle(14);
	aux_write_mult  <= controle(15);
	aux_pc_jump    	<= controle(10);
	aux_select_dado <= controle(1 downto 0);
	aux_imem_jump   <= instrucao(31 downto 7);
	aux_shifter     <= controle(12 downto 11);
	saida         	<= aux_out_dado;
	--instrucao     	<= aux_outmemi;

	-- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
	-- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
	-- que você atribuiu ao componente.
	-- Depois segue o port map do referido componente instanciado.
	-- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
	-- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
	-- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
	-- Veja os exemplos de instanciação a seguir:

	instancia_ula1 : component ula
  		port map(
			entrada_a => aux_data_outrs,
			entrada_b => aux_entrada_b,
			seletor   => aux_ula_ctrl,
			saida     => aux_out_ula,
			equal     => aux_equal
 		);

	instancia_banco_registradores : component banco_registradores
		port map(
			ent_rs_ende => aux_read_rs,
			ent_rt_ende => aux_read_rt,
			ent_rd_ende => aux_write_rd,
			ent_rd_dado => aux_data_in,
			sai_rs_dado => aux_data_outrs,
			sai_rt_dado => aux_data_outrt,
			clk         => clock,
			we          => aux_reg_write
		);

    instancia_pc : component pc
    	port map(
			entrada => aux_novo_pc,
			saida   => aux_pc_out,
			clk     => clock,
			we      => aux_we,
			reset   => reset
      	);

    instancia_somador : component somador
        port map(
			entrada_a => aux_pc_out,
			entrada_b => x"00000004",
			saida     => aux_prox_pc
        );

	instancia_memi : component memi
        port map(
			clk       => clock,
			reset     => reset,
			Endereco  => aux_pc_out (11 downto 0),
			Instrucao => aux_outmemi
        );

	instancia_memd : component memd
        port map(
			clk               => clock,
			mem_write 		  => aux_men_write,
			mem_read 		  => not aux_men_write,
			write_data_mem    => aux_out_ula,
			adress_mem        => aux_data_outrt(11 downto 0), 
			read_data_mem     => aux_out_memd 
        );

	instancia_mux_rd : component mux21_8bits
        port map(
			dado_ent_0   => aux_read_rt,
			dado_ent_1   => aux_select_rd,
        	sele_ent     => aux_mux_rd, 
    		dado_sai     => aux_write_rd
        );
	
	instancia_mux_ula : component mux21
        port map(
			dado_ent_0   => aux_data_outrt,
			dado_ent_1   => aux_out_extensor,
        	sele_ent     => aux_mux_ula, 
    		dado_sai     => aux_entrada_b
        );

	instancia_mux_jalr : component mux21
        port map(
			dado_ent_0   => aux_prox_pc,
			dado_ent_1   => aux_out_dado,
        	sele_ent     => aux_jalr,  
    		dado_sai     => aux_data_in
        );

	instancia_mux_jalr_pc : component mux21
        port map(
			dado_ent_0   => aux_jump_out,
			dado_ent_1   => aux_data_outrs,
        	sele_ent     => aux_jalr,  
    		dado_sai     => aux_novo_pc
        );

	instancia_mux1_pc : component mux21
        port map(
			dado_ent_0   => aux_prox_pc,
			dado_ent_1   => aux_pc_beq,
        	sele_ent     => aux_jump_equal,  
    		dado_sai     =>  aux_pc_select
        );

	instancia_mux_dado : component mux4_1
        port map(
			dado_ent_0 => aux_out_ula,
			dado_ent_1 => aux_out_memd, 
			dado_ent_2 => aux_dado_shifter,
			dado_ent_3 => out_reg_mult,
			sele_ent   => aux_select_dado,                                 
			dado_sai   => aux_out_dado                                   
        );

	instancia_deslocador_j : component deslocador
        port map(
			ent_rs_dado           => aux_out_extensor,
			ent_rt_ende           => "00010",
			ent_tipo_deslocamento =>  "01",
			sai_rd_dado           => aux_imen_desloc                  
        );
	
	instancia_deslocador: component deslocador
        port map(
			ent_rs_dado           => aux_data_outrs,
			ent_rt_ende           => aux_read_rt(4 downto 0),
			ent_tipo_deslocamento => aux_shifter,
			sai_rd_dado           => aux_dado_shifter                  
        );

	instancia_deslocador_jump : component deslocador_2

        port map(
			ent_rs_dado           => aux_imem_jump_exten,
			ent_rt_ende           => "00010",
			ent_tipo_deslocamento =>  "01",
			sai_rd_dado           => aux_end_desloc                  
        );

	instancia_extensor : component extensor
        port map(
			entrada_Rs => aux_read_rt,
			saida      => aux_out_extensor
        );

	instancia_extensor_jump : component extensor_2
        port map(
			entrada_Rs => aux_imem_jump,
			saida      => aux_imem_jump_exten
        );

		aux_jump_pc <= aux_out_dado(4 downto 0) & aux_end_desloc;

	instancia_somador_ext : component somador
        port map(
			entrada_a => aux_imen_desloc,
			entrada_b => aux_prox_pc,
			saida     => aux_pc_beq
        );
	
	instancia_mux2_pc : component mux21
        port map(
			dado_ent_0   => aux_pc_select,
			dado_ent_1   => aux_jump_pc,
        	sele_ent     => aux_pc_jump,  
    		dado_sai     => aux_jump_out 
        );

	instancia_multi : component multiplicador
        port map(
			entrada_a  => aux_data_outrs,
			entrada_b  => aux_data_outrt,
			saida      => saida_multiplicador
        );

	instancia_reg_LO : component registrador
        port map(
			entrada_dados  => saida_multiplicador(31 downto 0),
			WE             => aux_write_mult,
			clk            => clock,
			reset          => reset,
			saida_dados    => out_LO
        );

	instancia_reg_HI : component registrador
        port map(
			entrada_dados  => saida_multiplicador(63 downto 32),
			WE             => aux_write_mult,
			clk            => clock,
			reset          => reset,
			saida_dados    => out_HI
        );
	
	instancia_mux_HILO : component mux21
        port map(
			dado_ent_0   => out_LO,
			dado_ent_1   => out_HI,
        	sele_ent     => aux_select_HILO,  
    		dado_sai     =>  out_reg_mult
        );

	aux_jump_equal <= (aux_equal and aux_branch);
	instruct <= instrucao;
end architecture comportamento;