LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------
ENTITY opcdecoder IS
	GENERIC(regsize : INTEGER := 4 );
	PORT (IRop : IN std_logic_vector ( regsize-1 DOWNTO 0);
	      st,ld,mov,done,add,sub,jmp,jc,jnc,andd,orr,xorr : OUT std_logic 
	      );
END opcdecoder;
--------------------------------------------------------
ARCHITECTURE dataflow3 OF opcdecoder IS
BEGIN
add <= '1' when IRop = "0000" else '0' ;
sub <= '1' when IRop = "0001" else '0' ;
andd <= '1' when IRop = "0010" else '0' ;
orr <= '1' when IRop = "0011" else '0' ;
xorr <= '1' when IRop = "0100" else '0' ;
jmp <= '1' when IRop = "0111" else '0' ;
jc <= '1' when IRop = "1000" else '0' ;
jnc <= '1' when IRop = "1001" else '0' ;
mov <= '1' when IRop = "1100" else '0' ;
ld <= '1' when IRop = "1101" else '0' ;
st <= '1' when IRop = "1110" else '0' ;
done <= '1' when IRop = "1111" else '0' ;
END dataflow3;
