library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
---------------------------------------------------------
-- A test bench which checks the Control unit. 
---------------------------------------------------------
entity Control_tb is

end Control_tb;
---------------------------------------------------------
architecture Ctb of Control_tb is
	signal		clk, rst, ena, st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag:  std_logic;
	signal		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out :  std_logic;
	signal		ALUFN :  std_logic_vector(3 downto 0);
	signal 		PCsel, RFaddr_wr, RFaddr_rd :  std_logic_vector(1 downto 0);
	SIGNAL 		done_FSM:			STD_LOGIC := '0';
	
---------------------------------------------------------
begin
ControlUnit: Control 	port map(st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag,
				 IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
				 ALUFN, PCsel, RFaddr_wr, RFaddr_rd,
				 clk, rst, ena, done_FSM
				 );
    
	--------- start of stimulus section ------------------	
	
		gen_rst : process	-- reset process
        begin
		  rst <='1','0' after 100 ns;	-- reset at the begining of the system
		  wait;
        end process; 
		
		
        gen_clk : process	-- Clk process (duty cycle of 50% and period of 100 ns)
        begin
		  clk <= '1';
		  wait for 50 ns;
		  clk <= not clk;
		  wait for 50 ns;
        end process;
		ena <= '1';

		--------------- Commands ---------------------
		
		add_cmd : process
        begin
		  add <='0', '1' after 120 ns, '0' after 400 ns;
		  wait;
        end process; 
		
		and_cmd : process
        begin
		  andd <='0','1' after 420 ns, '0' after 700 ns;
		  wait;
        end process;
		
		jnc_cmd : process
        begin
		  jnc <='0','1' after 720 ns, '0' after 900 ns;
		  CFlag<='0','1' after 920 ns, '0' after 1100 ns;
		  wait;
        end process;
		
		
		jc_cmd : process
        begin
		  jc <='0','1' after 920 ns, '0' after 1100 ns;
		  wait;
        end process;
		
		
		jmp_cmd : process
        begin
		  jmp <='0','1' after 1120 ns, '0' after 1300 ns;
		  wait;
        end process;
		
		sub_cmd : process
        begin
		  sub <='0','1' after 1320 ns, '0' after 1600 ns;
		  wait;
        end process;
		
		mov_cmd : process
        begin
		  mov <='0','1' after 1620 ns, '0' after 1800 ns;
		  wait;
        end process;
		
		ld_cmd : process
        begin
		  ld <='0','1' after 1820 ns, '0' after 2300 ns;
		  wait;
        end process;
		
		st_cmd : process
        begin
		  st <='0','1' after 2320 ns ,'0' after 2700 ns;
		  wait;
        end process;
	
	or_cmd : process
        begin
		  orr <='0','1' after 2720 ns ,'0' after 3000 ns;
		  wait;
        end process;

	xor_cmd : process
        begin
		  xorr <='0','1' after 3020 ns ,'0' after 3300 ns;
		  wait;
        end process;

	done_cmd : process
        begin
		  done <='0','1' after 3320 ns ;
		  wait;
        end process;
		
		
end architecture Ctb;
