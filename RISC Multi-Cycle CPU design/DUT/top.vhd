library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;
---------------------------------------------------------------
ENTITY top IS
	generic( BusSize: integer:=16;	-- Data Memory In Data Size
		 m: 	  integer:=16;  -- Program Memory In Data Size
		 Awidth:  integer:=6;
		 RegSize:  integer:=4);  	-- Address Size
	PORT(
		clk, rst, ena  : in STD_LOGIC;
		done_FSM : out std_logic;	
		
		-- Test Bench
		ITCM_tb_in  						: in std_logic_vector(m-1 downto 0);
		DTCM_tb_in 						: in std_logic_vector(BusSize-1 downto 0);
		DTCM_tb_out 						: out std_logic_vector(BusSize-1 downto 0);
		TBactive	   					: in std_logic;
		ITCM_tb_wr, DTCM_tb_wr 					: in std_logic;
		ITCM_tb_addr_in, DTCM_tb_addr_in, DTCM_tb_addr_out 	: in std_logic_vector(Awidth-1 downto 0)
	);
END top;
---------------------------------------------------------------
ARCHITECTURE behav OF top IS

signal		st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag:  std_logic;
signal		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_out, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in :  std_logic;
signal		ALUFN :  std_logic_vector(3 downto 0);
signal 		PCsel, RFaddr_wr,RFaddr_rd :  std_logic_vector(1 downto 0);


BEGIN

ControlUnit: Control 	port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag,
								IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
								ALUFN, PCsel, RFaddr_wr, RFaddr_rd,
								clk, rst, ena, done_FSM
								);

DataPathUnit: Datapath generic map(bussize,regsize,Awidth)  port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag, 
								     IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
								     ALUFN, PCsel,RFaddr_wr,RFaddr_rd, ena, clk, rst, 
								     ITCM_tb_wr,ITCM_tb_in,ITCM_tb_addr_in,DTCM_tb_out,DTCM_tb_wr,TBactive, DTCM_tb_addr_in, DTCM_tb_addr_out, DTCM_tb_in);
								

end behav;
