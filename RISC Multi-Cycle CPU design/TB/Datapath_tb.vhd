library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use ieee.numeric_std.all;

---------------------------------------------------------
entity Datapath_tb is
	constant BusSize : integer := 16;
	constant Awidth:  integer:=6;  	
	constant RegSize: integer:=4; 	
	constant m: 	  integer:=16 ;
	constant dept      : integer:=64;
	
	constant dataMemResult:	 	string(1 to 65) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\DTCMcontentDatapath.txt";
	constant dataMemLocation: 	string(1 to 62) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\DTCMinitDatapath.txt";
	constant progMemLocation: 	string(1 to 62) :=
	"C:\Users\Amir\OneDrive\Desktop\lab3\files\ITCMinitDatapath.txt";  
end Datapath_tb;
----------
architecture tb_behav of Datapath_tb is

signal		st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag:  std_logic;
signal		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_out, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in :  std_logic;
signal		ALUFN :  std_logic_vector(3 downto 0);
signal 		PCsel, RFaddr_wr,RFaddr_rd :  std_logic_vector(1 downto 0);
SIGNAL done_FSM:					STD_LOGIC := '0';
SIGNAL rst, ena, clk, TBactive, DTCM_tb_wr, ITCM_tb_wr: STD_LOGIC;	
SIGNAL DTCM_tb_in, DTCM_tb_out: 			STD_LOGIC_VECTOR (BusSize-1 downto 0); 
SIGNAL ITCM_tb_in: 					STD_LOGIC_VECTOR (BusSize-1 downto 0); 
SIGNAL DTCM_tb_addr_in, ITCM_tb_addr_in:  		STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
SIGNAL DTCM_tb_addr_out:				STD_LOGIC_VECTOR (Awidth-1 DOWNTO 0);
SIGNAL donePmemIn, doneDmemIn:				BOOLEAN;
begin 

DataPathUnit: Datapath generic map(bussize,regsize,Awidth)  port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag, 
								     IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
								     ALUFN, PCsel,RFaddr_wr,RFaddr_rd, ena, clk, rst, 
								     ITCM_tb_wr,ITCM_tb_in,ITCM_tb_addr_in,DTCM_tb_out,DTCM_tb_wr,TBactive, DTCM_tb_addr_in, DTCM_tb_addr_out, DTCM_tb_in);
								


--------- Clock
gen_clk : process
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;

--------- Rst
gen_rst : process
        begin
		  rst <='1','0' after 100 ns;
		  wait;
        end process;	
--------- TB
gen_TB : process
	begin
	 TBactive <= '1';
	 wait until donePmemIn and doneDmemIn;  
	 TBactive <= '0';
	 wait until done_FSM = '1';  
	 TBactive <= '1';	
	end process;	
	
	
--------- Reading from text file and initializing the data memory data--------------
LoadDataMem:process 
	file inDmemfile : text open read_mode is dataMemLocation;
	variable    	linetomem			: std_logic_vector(BusSize-1 downto 0);
	variable	good				: boolean;
	variable 	L 				: line;
	variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; 
begin 
		doneDmemIn <= false;
		TempAddresses := (others => '0');
		while not endfile(inDmemfile) loop
			readline(inDmemfile,L);
			hread(L,linetomem,good);
			next when not good;
			DTCM_tb_wr <='1';
			DTCM_tb_addr_in <= TempAddresses;
			DTCM_tb_in <= linetomem;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			TempAddresses := std_logic_vector((TempAddresses) + 1);
		end loop ;
		DTCM_tb_wr <= '0';
		doneDmemIn <= true;
		file_close(inDmemfile);
		wait;
	end process;
	
	
--------- Reading from text file and initializing the program memory instructions	
LoadProgramMem:process 
	file inPmemfile : text open read_mode is progMemLocation;
	variable    linetomem			: std_logic_vector(BusSize-1 downto 0);
	variable	good				: boolean;
	variable 	L 					: line;
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


--------- Start Test Bench ---------------------
StartTb : process
	begin
	
		wait until donePmemIn and doneDmemIn;  

------------- Reset ------------------------		
		wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "11";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------	
		wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '1';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '0';
					RFaddr_wr<= "10";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '1';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------	
		wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '1';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '0';
					RFaddr_wr<= "10";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '1';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------	
		wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '1';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '0';
					RFaddr_wr<= "10";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '1';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0010";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '1';
					RFaddr_wr<= "10";
					RFaddr_rd<= "00";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0001";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '1';
					RFaddr_wr<= "10";
					RFaddr_rd<= "00";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '1';
					RFout	 <= '1';
					RFaddr_wr<= "10";
					RFaddr_rd<= "00";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "10";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '1';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "10";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '1';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '1';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "10";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '1';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';		
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1010";
					Ain	 <= '1';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "01";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "0000";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '1';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '1';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '1';
					RFaddr_wr<= "11";
					RFaddr_rd<= "10";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '1';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '1';
					PCin	 <= '0';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='0';
---------------------------------------------------
			wait until clk'EVENT and clk='1';
					ALUFN	 <= "1011";
					Ain	 <= '0';
					RFin	 <= '0';
					RFout	 <= '0';
					RFaddr_wr<= "11";
					RFaddr_rd<= "11";
					IRin	 <= '0';
					PCin	 <= '1';
					PCsel	 <= "01";
					Imm1_in	 <= '0';
					Imm2_in	 <= '0';
					DTCM_wr	 <= '0';
					DTCM_out <= '0';
					DTCM_addr_sel <= '0';
					DtCM_addr_out <= '0';
					DTCM_addr_in  <= '0';
					done_FSM      <='1';
					wait;
		
	end process;	
	
	
	--------- Writing from Data memory to external text file, after the program ends (done_FSM = 1).
	
	WriteToDataMem:process 
		file outDmemfile : text open write_mode is dataMemResult;
		variable    linetomem			: STD_LOGIC_VECTOR(BusSize-1 downto 0);
		variable	good				: BOOLEAN;
		variable 	L 					: LINE;
		variable	TempAddresses		: STD_LOGIC_VECTOR(Awidth-1 downto 0) ; 
		variable 	counter				: INTEGER;
	begin 
		wait until done_FSM = '1';  
		TempAddresses := (others => '0');
		counter := 0;
		while counter < 6 loop	
			DTCM_tb_addr_out <= TempAddresses;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			linetomem := DTCM_tb_out;
			hwrite(L,linetomem);
			writeline(outDmemfile,L);
			TempAddresses := std_logic_vector((TempAddresses) + 1);
			counter := counter +1;
		end loop ;
		file_close(outDmemfile);
		wait;
	end process;


end tb_behav;