LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------
ENTITY pc IS
	GENERIC(addersize : INTEGER := 6 ;
		offsetsize : INTEGER := 8 );
	PORT (PCin,clk :IN std_logic;
	      PCsel : IN std_logic_vector(1 DOWNTO 0);
	      IRoffset : IN std_logic_vector (offsetsize-1 DOWNTO 0);
	      PCout : OUT std_logic_vector ( addersize-1 DOWNTO 0) := "000000"
	      );
END pc;
--------------------------------------------------------
ARCHITECTURE dataflow1 OF pc IS
	signal currpc,nextpc : std_logic_vector (addersize-1 DOWNTO 0) := (others => '0');
	constant rstadder : std_logic_vector (addersize-1 DOWNTO 0) := (others => '0');
BEGIN
	process (clk) BEGIN
		if (clk'event and clk ='1') then
			if (PCin = '1') then
				currpc <= nextpc ;
			end if ; 
		end if ;
	end process ;

	nextpc <= currpc + 1 when PCsel = "01" else
		  rstadder   when PCsel = "11" else 
		  currpc + 1 + SXT(IRoffset , addersize) when PCsel = "10" else
		  nextpc ;

	PCout <= currpc ;

END dataflow1;
