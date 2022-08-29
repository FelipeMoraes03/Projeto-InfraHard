--------------------------------------------------------------------------------
-- Title		: Mem�ria da CPU
-- Project		: CPU Multi-ciclo
--------------------------------------------------------------------------------
-- File			: Memoria.vhd
-- Author		: Emannuel Gomes Mac�do <egm@cin.ufpe.br>
--				  Fernando Raposo Camara da Silva <frcs@cin.ufpe.br>
--				  Pedro Machado Manh�es de Castro <pmmc@cin.ufpe.br>
--				  Rodrigo Alves Costa <rac2@cin.ufpe.br>
-- Organization : Universidade Federal de Pernambuco
-- Created		: 26/07/2002
-- Last update	: 23/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade respons�vel pela leitura e escrita em mem�ria.
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
-- Date				: 23/11/2002
-- Modifier			: Marcus Vinicius Lima e Machado <mvlm@cin.ufpe.br>
--				  	  Paulo Roberto Santana Oliveira Filho <prsof@cin.ufpe.br>
--					  Viviane Cristina Oliveira Aureliano <vcoa@cin.ufpe.br>
-- Description		:
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 2
-- Revision Number	: 2
-- Version			: 1.2
-- Date				: 31/01/2021
-- Modifier			: André Soares da Silva Filho <assf@cin.ufpe.br>
-- Description		: Simplified the code to work better in ModelSim 20.1.1
--					  -Retirada biblioteca STD_LOGIC_ARITH que conflita com a mais recente NUMERIC_STD
--------------------------------------------------------------------------------

package ram_constants is
	constant DATA_WIDTH : INTEGER := 8;
	constant ADDR_WIDTH : INTEGER := 8;
	constant INIT_FILE  : STRING  := "instrucoes.mif";
end ram_constants;

--*************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
-- USE ieee.std_logic_arith.all;						-- Retirado na versão 1.2
USE IEEE.NUMERIC_STD.ALL;

library lpm;
use lpm.lpm_components.all;

library work;
use work.ram_constants.all;
--*************************************************************************

--Short name: mem
ENTITY Memoria IS
	PORT(
		Address	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Endere�o de mem�ria a ser lido
		Clock	: IN  STD_LOGIC;						-- Clock do sistema
		Wr		: IN  STD_LOGIC;						-- Indica se a mem�ria ser� lida (0) ou escrita (1)
		Datain	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Valor lido da mem�ria quando Wr = 0
		Dataout	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		-- Valor a ser escrito quando Wr = 1
   );
END Memoria;

-- Arquitetura que define o comportamento da mem�ria
-- Simulation
ARCHITECTURE behavioral_arch OF Memoria IS

    signal addS0		: STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
	signal addS1		: STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
	signal addS2		: STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
	signal addS3		: STD_LOGIC_VECTOR (ADDR_WIDTH-1 DOWNTO 0);
    signal dataoutS		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal datainS		: STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal dataoutS0	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal dataoutS1	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal dataoutS2	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal dataoutS3	: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal datainS0		: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal datainS1		: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
	signal datainS2		: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
    signal datainS3		: STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
	signal wrS			: STD_LOGIC;
	signal clockS		: STD_LOGIC;
    signal add0			: integer;
	signal add2			: integer;
	signal add1			: integer;
	signal add3			: integer;
    signal addu			: unsigned(7 downto 0);

BEGIN

-- C�lculo dos 4 endere�os (inteiros) a serem lidos devido ao endere�amento por byte
      add0 <= TO_INTEGER(unsigned(Address(7 downto 0)));      
      add1 <= add0 + 1;
      add2 <= add0 + 2;
      add3 <= add0 + 3;

-- Convers�o dos endere�os no formato STD_LOGIC_VECTOR
	  addS0 <= STD_LOGIC_VECTOR(to_unsigned(add0, ADDR_WIDTH));
      addS1 <= STD_LOGIC_VECTOR(to_unsigned(add1, ADDR_WIDTH));
      addS2 <= STD_LOGIC_VECTOR(to_unsigned(add2, ADDR_WIDTH));
      addS3 <= STD_LOGIC_VECTOR(to_unsigned(add3, ADDR_WIDTH));
	
	-- Convers�o do dado (entrada) no formato STD_LOGIC_VECTOR
    datainS <= datain;

	wrS <= wr;

	clockS <= clock;

	-- Convers�o de dado (sa�da) para bit_vector
	dataout <= dataoutS;

-- Distribui��o dos vetores de dados para os bancos de mem�ria      
    datainS0 <= datainS(7 downto 0);
    datainS1 <= datainS(15 downto 8);
    datainS2 <= datainS(23 downto 16);
    datainS3 <= datainS(31 downto 24);
	
	dataoutS(7 downto 0) <= dataoutS0;
  	dataoutS(15 downto 8) <= dataoutS1;
    dataoutS(23 downto 16) <= dataoutS2;
    dataoutS(31 downto 24) <= dataoutS3;
	

-- Bancos de mem�rias (cada banco possui 256 bytes)
	MEM: lpm_ram_dq
	GENERIC MAP (lpm_widthad => ADDR_WIDTH, lpm_width => DATA_WIDTH, lpm_file => INIT_FILE)
	PORT MAP (data => datainS0, Address => addS0, we => wrS, inclock => clockS, outclock => clockS, q => dataoutS0);

	MEM_plus_One: lpm_ram_dq
	GENERIC MAP (lpm_widthad => ADDR_WIDTH, lpm_width => DATA_WIDTH, lpm_file => INIT_FILE)
	PORT MAP (data => datainS1, Address => addS1, we => wrS, inclock => clockS, outclock => clockS, q => dataoutS1);

	MEM_plus_Two: lpm_ram_dq
	GENERIC MAP (lpm_widthad => ADDR_WIDTH, lpm_width => DATA_WIDTH, lpm_file => INIT_FILE)
	PORT MAP (data => datainS2, Address => addS2, we => wrS, inclock => clockS, outclock => clockS, q => dataoutS2);

    MEM_plus_Three: lpm_ram_dq
	GENERIC MAP (lpm_widthad => ADDR_WIDTH, lpm_width => DATA_WIDTH, lpm_file => INIT_FILE)
	PORT MAP (data => datainS3, Address => addS3, we => wrS, inclock => clockS, outclock => clockS, q => dataoutS3);

	END behavioral_arch;