library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.all;
---------------------------------------------------------
entity top_tb is
	constant BusSize: integer:=16;
	constant m	: integer:=16;
	constant Awidth : integer:=6;	 
	constant RegSize: integer:=4;
	constant dept   : integer:=64;

	constant dataMemResult:	 	string(1 to 57) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\DTCMcontent.txt";
	constant dataMemLocation: 	string(1 to 54) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\DTCMinit.txt";
	constant progMemLocation: 	string(1 to 54) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\ITCMinit.txt";
end top_tb;
---------------------------------------------------------
architecture rtb of top_tb is

	SIGNAL done_FSM:					STD_LOGIC := '0';
	SIGNAL rst, ena, clk, TBactive, DTCM_tb_wr, ITCM_tb_wr: STD_LOGIC;	
	SIGNAL DTCM_tb_in, DTCM_tb_out: 			STD_LOGIC_VECTOR (BusSize-1 downto 0); 
	SIGNAL ITCM_tb_in: 					STD_LOGIC_VECTOR (BusSize-1 downto 0); 
	SIGNAL DTCM_tb_addr_in, ITCM_tb_addr_in:  		STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
	SIGNAL DTCM_tb_addr_out:				STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
	SIGNAL donePmemIn, doneDmemIn:				BOOLEAN;
	
begin
	
	TopUnit: top port map(	clk, rst, ena, done_FSM, ITCM_tb_in, DTCM_tb_in, DTCM_tb_out, TBactive,
							ITCM_tb_wr, DTCM_tb_wr, ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out);
						
    
	--------- start of stimulus section ------------------	
	
	--------- Rst
	gen_rst : process
	begin
	  rst <='1','0' after 100 ns;
	  wait;
	end process;
	
	------------ Clock
	gen_clk : process
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;
	
	--------- 	TB
	gen_TB : process
        begin
		 TBactive <= '1';
		 wait until donePmemIn and doneDmemIn;  
		 TBactive <= '0';
		 wait until done_FSM = '1';  
		 TBactive <= '1';	
        end process;	
	
				
				
	--------- reading from external Data Memory file and writing to RAM	(CPU Data Memory)
	LoadDataMem: process 
		file inDmemfile : text open read_mode is dataMemLocation;
		variable    	linetomem			: std_logic_vector(BusSize-1 downto 0);
		variable	good				: boolean;
		variable 	L 				: line;
		variable	TempAddresses			: std_logic_vector(Awidth-1 downto 0) ; 
	begin 
		doneDmemIn <= false;
		TempAddresses := (others => '0');
		while not endfile(inDmemfile) loop
			readline(inDmemfile,L);
			hread(L,linetomem,good);
			next when not good;
			DTCM_tb_wr <= '1';
			DTCM_tb_addr_in <= TempAddresses;
			DTCM_tb_in <= linetomem;
			wait until rising_edge(clk);
			TempAddresses := std_logic_vector((TempAddresses) + 1);
		end loop ;
		DTCM_tb_wr <= '0';
		doneDmemIn <= true;
		file_close(inDmemfile);
		wait;
	end process;
		
		
	--------- reading from external Program Memory file and writing to RAM	(CPU Program Memory)
	LoadProgramMem: process 
		file 		inPmemfile 		: text open read_mode is progMemLocation;
		variable    	linetomem		: std_logic_vector(BusSize-1 downto 0); 
		variable	good			: boolean;
		variable 	L 			: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
	begin 
		donePmemIn <= false;
		TempAddresses := (others => '0');
		while not endfile(inPmemfile) loop
			readline(inPmemfile,L);
			hread(L,linetomem,good);
			next when not good;
			ITCM_tb_wr <= '1';
			ITCM_tb_addr_in <= TempAddresses;
			ITCM_tb_in <= linetomem;
			wait until rising_edge(clk);
			TempAddresses := std_logic_vector((TempAddresses) + 1);
		end loop ;
		ITCM_tb_wr <= '0';
		donePmemIn <= true;
		file_close(inPmemfile);
		wait;
	end process;
	

	ena <= '1' when (doneDmemIn and donePmemIn) else '0';
	
		
	--------- Writing from Data memory (CPU) to external Data Memory file, after the program end (done_FSM = 1)
	WriteToDataMem: process 
		file 		outDmemfile 		: text open write_mode is dataMemResult;
		variable    	linetomem		: std_logic_vector(BusSize-1 downto 0);
		variable	good			: boolean;
		variable 	L 			: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
		variable 	counter			: integer;
	begin 
		wait until done_FSM = '1';  
		TempAddresses := (others => '0');
		counter := 0;
		while counter < 42 loop	
			DTCM_tb_addr_out <= TempAddresses;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			hwrite(L,DTCM_tb_out);
			writeline(outDmemfile,L);
			TempAddresses := std_logic_vector((TempAddresses) + 1);
			counter := counter +1;
		end loop ;
		file_close(outDmemfile);
		wait;
	end process;
		

end architecture rtb;

