-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Deslocador de barril com entrada e saída de dados genérica.
-- entrada com a quantidade de bits a ser deslocada como log2 da entrada genérica.
-- de acordo com o sinal de seleção faz as seguintes operações:
-- "00" deslocamento lógico para a direita
-- "01" deslocamento lógico para a esquerda
-- "10" deslocamento de rotação para a direita
-- "11" copia o conteúdo de rs para rd, equivale a uma rotação total do número de bits do deslocador para a direita
-- os dois bits que selecionam o tipo de deslocamento são os 2 bits menos significativos do opcode (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deslocador_extensor is
	generic (
		largura_entrada : natural;
		largura_saida : natural
	);

	port (
		entrada      : in std_logic_vector((largura_entrada - 1) downto 0);
		saida        : out std_logic_vector((largura_saida - 1) downto 0)
	);
end deslocador_extensor;

architecture comportamental of deslocador_extensor is
begin
	saida <= (others => entrada(largura_entrada-1));
	genstage : for ii in 0 to largura_entrada generate
		saida(ii + 2) <= entrada(ii); 
	end generate;
end comportamental;