LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------
ENTITY ALU IS
	GENERIC(bussize : INTEGER := 16;
		regsize : INTEGER := 4 );
	PORT (A,B : IN std_logic_vector ( bussize-1 DOWNTO 0);
	      ALUFN : IN std_logic_vector (regsize-1 DOWNTO 0);
	      CFlag,ZFlag,NFlag : OUT std_logic;
	      C : OUT std_logic_vector ( bussize-1 DOWNTO 0)
	      );
END ALU;
--------------------------------------------------------
ARCHITECTURE dataflow4 OF ALU IS
signal reg,s_out,and_out,or_out,xor_out : std_logic_vector (bussize-1 DOWNTO 0) := (others =>'0');
signal B_temp : std_logic_vector (bussize-1 DOWNTO 0) ;
signal cin : std_logic ;
constant zerovec : std_logic_vector (bussize-1 DOWNTO 0) := (others =>'0');

BEGIN
cin <= '1' when (ALUFN ="0001") else '0';


B_bar : for i in 0 to bussize-1 generate
	B_temp(i) <= (B(i) xor '1') when (ALUFN="0001") else 
			B(i);
end generate;

first : FA port map(A(0),B_temp(0),cin,s_out(0),reg(0));

rest : for i in 1 to bussize-1 generate
	chain : FA port map(A(i),B_temp(i),reg(i-1),s_out(i),reg(i));
end generate;

andd: for i in 0 to bussize-1 generate
            and_out(i) <= (A(i) and B(i));
        end generate;

orr: for i in 0 to bussize-1 generate
            or_out(i) <= (A(i) or B(i));
        end generate;

xorr: for i in 0 to bussize-1 generate
            xor_out(i) <= (A(i) xor B(i));
        end generate;


CFlag <= reg(bussize-1) when (ALUFN="0001" or ALUFN="0000") else '0' when (ALUFN= "0010" or ALUFN= "0011" or ALUFN= "0100") else unaffected;
NFlag <= s_out(bussize-1) when (ALUFN="0001" or ALUFN="0000") else
	 and_out(bussize-1) when ALUFN= "0010"  else
	 or_out(bussize-1) when ALUFN= "0011"  else
	 xor_out(bussize-1) when ALUFN= "0100" else
	 unaffected;
ZFlag <= unaffected when (ALUFN = "1011") else '1' when (s_out=zerovec) else '0';

C <= 	B when ALUFN = "1010" else
     	s_out when (ALUFN ="0000" or ALUFN="0001") else
	and_out when ALUFN= "0010" else
	or_out when ALUFN= "0011" else
	xor_out when ALUFN= "0100" else
	(others => '0');
END dataflow4;

