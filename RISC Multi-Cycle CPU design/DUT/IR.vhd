LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------
ENTITY IR IS
	GENERIC(bussize : INTEGER := 16 ;
		offsetsize : INTEGER := 8;
		regsize : INTEGER := 4 ;
		immidsize : INTEGER := 8 );
	PORT (IRin :IN std_logic;
	      programmemin : IN std_logic_vector (bussize-1 DOWNTO 0);
	      RFadder_wr,RFadder_rd : IN std_logic_vector (1 DOWNTO 0);
	      reg_rd,reg_wr : OUT std_logic_vector (regsize-1 DOWNTO 0);
	      offset : OUT std_logic_vector (offsetsize-1 DOWNTO 0);
	      imm : OUT std_logic_vector (immidsize -1 DOWNTO 0);
	      IRop : OUT std_logic_vector ( regsize-1 DOWNTO 0)
	      );
END IR;
--------------------------------------------------------
ARCHITECTURE dataflow2 OF IR IS
	signal IRreg : std_logic_vector (bussize-1 DOWNTO 0);
BEGIN

IRreg <= programmemin when IRin = '1' else IRreg;

IRop <= IRreg(bussize-1 DOWNTO bussize-regsize);

reg_wr <= IRreg(3*regsize-1 DOWNTO 2*regsize) when RFadder_wr="10" else
	  IRreg(2*regsize-1 DOWNTO regsize) when RFadder_wr="01" else
	  IRreg(regsize-1 DOWNTO 0) when RFadder_wr="00" else
	  unaffected;

reg_rd <= IRreg(3*regsize-1 DOWNTO 2*regsize) when RFadder_rd="10" else
	  IRreg(2*regsize-1 DOWNTO regsize) when RFadder_rd="01" else
	  IRreg(regsize-1 DOWNTO 0) when RFadder_rd="00" else
	  unaffected;

offset <= IRreg(offsetsize-1 DOWNTO 0);
imm <= IRreg (immidsize-1 DOWNTO 0);

END dataflow2;
