--------------------------------------------------------------------------------
-- Title		: Banco de Registradores
-- Project		: CPU Multi-ciclo
--------------------------------------------------------------------------------
-- File			: Banco_reg.vhd
-- Author		: Emannuel Gomes Mac�do (egm@cin.ufpe.br)
--				  Fernando Raposo Camara da Silva (frcs@cin.ufpe.br)
--				  Pedro Machado Manh�es de Castro (pmmc@cin.ufpe.br)
--				  Rodrigo Alves Costa (rac2@cin.ufpe.br)
-- Organization : Universidade Federal de Pernambuco
-- Created		: 29/07/2002
-- Last update	: 21/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade que armazena o conjunto de registradores da cpu, no
-- qual pode ser efetuado leitura e escrita de dados.
--------------------------------------------------------------------------------
-- Copyright (c) notice
--		Universidade Federal de Pernambuco (UFPE).
--		CIn - Centro de Informatica.
--		Developed by computer science undergraduate students.
--		This code may be used for educational and non-educational purposes as 
--		long as its copyright notice remains unchanged. 
--------------------------------------------------------------------------------
-- Revisions		: 1
-- Revision Number	: 1.0
-- Version			: 1.1
-- Date				: 21/11/2002
-- Modifier			: Marcus Vinicius Lima e Machado (mvlm@cin.ufpe.br)
--				  	  Paulo Roberto Santana Oliveira Filho (prsof@cin.ufpe.br)
--					  Viviane Cristina Oliveira Aureliano (vcoa@cin.ufpe.br)
-- Description		:
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 1
-- Revision Number	: 1.1
-- Version			: 1.2
-- Date				: 18/08/2008
-- Modifier			: Jo�o Paulo Fernandes Barbosa (jpfb@cin.ufpe.br)
-- Description		: Entradas e sa�das e os sinais internos passaram a ser do
--					  Std_Logic.	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 1
-- Revision Number	: 2
-- Version			: 1.3
-- Date				: 01/02/2021
-- Modifier			: André Soares da Silva Filho <assf@cin.ufpe.br>
-- Description		: Refatoração do código para funcionamento no ModelSim 20.1.1
--					  e sintetização do código:
--					  -Transformação do Banco de registradores em um array de STD_LOGIC_VECTOR
--					  -Uso da biblioteca nativa NUMERIC_STD para melhorar leitura
--					  -A transformação do sinais ReadReg1, ReadReg2 e WriteReg em unsigned para inteiro
--					   evita erros de compilação no modelsim 20.1.1 uma vez que os casos anteriores
--					   cobriam apenas parte das possibilidades, pois STD_LOGIC tem 9 possibilidades e não
--					   apenas duas (0,1) como estamos acostumados a aprender no básico.	
--------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;										-- v 1.3

--Short name: breg
ENTITY Banco_reg IS
		PORT(
			Clk			: IN	STD_LOGIC;						-- Clock do banco de registradores
			Reset		: IN	STD_LOGIC;						-- Reinicializa o conteudo dos registradores
			RegWrite	: IN	STD_LOGIC;						-- Indica se a opera��o � de escrita ou leitura
			ReadReg1	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #1 a ser lido
			ReadReg2	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #2 a ser lido
			WriteReg	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador a ser escrito
			WriteData 	: IN	STD_LOGIC_VECTOR (31 downto 0);	-- Indica o dado a ser escrito
			ReadData1	: OUT	STD_LOGIC_VECTOR (31 downto 0);	-- Mostra a informa�ao presente no registrador #1
			ReadData2	: OUT	STD_LOGIC_VECTOR (31 downto 0)	-- Mostra a informa��o presente no registrador #2
			);
END Banco_reg ;

-- Arquitetura que define comportamento do Banco de Registradores
-- Simulation
ARCHITECTURE behavioral_arch OF Banco_reg IS
	
	-- Declarando tipo de banco de registradores
	TYPE 	REG_CLUSTER	is array 	(0 to 31)	of 	STD_LOGIC_VECTOR	(31 downto 0);
	
	-- Declarando banco de registradores
	SIGNAL 	Cluster 	: 			REG_CLUSTER;	

	BEGIN
	
	-- selecao do primeiro registrador
	ReadData1 <= Cluster(to_integer(unsigned(ReadReg1)));		

	-- selecao do segundo registrador 
	ReadData2 <= Cluster(to_integer(unsigned(ReadReg2)));

	--  Clocked Process
	PROCESS (Clk,Reset)
		BEGIN			
------------------------------------------- Reset inicializa o conjunto de registradores
			IF(Reset = '1') THEN
				FOR I IN 0 TO 31 LOOP
					Cluster(I) <= "00000000000000000000000000000000";
				END LOOP;			
------------------------------------------ In�cio do processo relacionado ao clock 
			ELSIF (Clk = '1' AND clk'EVENT) THEN
				IF(RegWrite = '1') THEN
					Cluster(to_integer(unsigned(WriteReg))) <= WriteData;
				END IF;
			END IF;
------------------------------------------ Fim do processo relacionado ao clock 
	END PROCESS;
------------------------------------------ Fim da Arquitetura 
END behavioral_arch;