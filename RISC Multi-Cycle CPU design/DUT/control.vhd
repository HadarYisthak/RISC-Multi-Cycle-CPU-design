LIBRARY ieee;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;
------------------- Control FSM Unit --------------------------
-- A synchronized Mealy Output Machine for a Multi-cycle CPU
-- Inputs: Clk, Rst, Ena, Status signals
-- Output: Control signals, done flag
-- PCsel: 00 -  unaffected; 01 - PC + 1; 10 - PC + 1 + offset; 11 - zeros
-- RFAddr: 00 - rc; 01 - rb; 10 - ra; 11 - unaffected
---------------------------------------------------------------
ENTITY Control IS
	PORT(
		st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag : in std_logic;
		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out : out std_logic;
		ALUFN : out std_logic_vector(3 downto 0);
		PCsel, RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);
		clk, rst, ena : in STD_LOGIC;
		done_FSM : out std_logic
	);
END Control;
---------------------------------------------------------------
ARCHITECTURE behav OF Control IS
	TYPE state IS (	RtypeState, ItypeState_0, ItypeState_11, ItypeState_12,ItypeState_122, Fetch, Decode, Reset);
	SIGNAL prv_state, nxt_state: state;
	SIGNAL temp: STD_LOGIC;
	
BEGIN


---------------  Process for The state status
-- Update status only on rising edge and with enable=1
	sync_process : process(clk, rst)
	begin
		if (rst='1') then
			prv_state <= Reset;
		elsif (clk'EVENT AND clk='1' and ena = '1') then
			prv_state <= nxt_state;
		end if;
	end process;

--------------- Process for the main FSM
	Main_FSM : process(prv_state, st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr,xorr, CFlag, ZFlag, NFlag)
	begin
		case prv_state is
			------ Reset -------
			when Reset =>
				if done = '0' then
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
					nxt_state <= Fetch;
				end if;
			------ Fetch -------
			when Fetch =>
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
					nxt_state <= Decode;
			------ Decode ------
			when Decode =>
  				-- Common signal defaults here
  				ALUFN	 <= "1011";
  				Ain	 <= '0';
  				RFin	 <= '0';
  				RFout	 <= '0';
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
				
				-- Update state given status
				-- Rtype
				if (add = '1' or sub = '1' or andd = '1' or orr='1' or xorr='1') then 
					Ain 	<= '1';
					RFout	 <= '1';
					ALUFN	<= "1010";
					nxt_state <=  RtypeState;
				-- Jtype
				elsif (jmp = '1' or jc = '1' or jnc = '1') then -- TBD
					if (jmp = '1') or (jc = '1' and Cflag = '1') or  (jnc = '1' and Cflag = '0')  then -- TBD 
						PCsel <= "10"; 
					end if;
					PCin <= '1';
					nxt_state <= Fetch;
				-- Itype
				elsif mov = '1' then
					RFin	 <= '1';
					PCin	 <= '1';	
					RFaddr_wr<= "10";
					ALUFN	 <="1010";   
					Imm1_in	 <= '1';
					nxt_state <= Fetch;
				elsif (ld = '1' or st = '1') then	
					Ain	 <= '1';
					RFout	 <= '1';	
					ALUFN	 <="1010";						
					nxt_state <= ItypeState_0;
				elsif done = '1' then
					PCin	 <= '1';
					done_FSM <= '1';
					nxt_state <= Reset;
				else
					nxt_state <= Fetch;
				end if;
  

			------ RtypeState First Cycle ------
			when RtypeState =>		
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
				nxt_state <= Fetch;		
				--- Update OPC ---
				if add = '1' then 
					ALUFN <= "0000";
				elsif sub = '1' then
					ALUFN <= "0001";
				elsif andd = '1' then
					ALUFN <= "0010";
				elsif orr = '1' then
					ALUFN <= "0011";
				elsif xorr = '1' then
					ALUFN <= "0100";
				else
					ALUFN <= "1011";
				end if;	

			------ ItypeState First Cycle ------
			when ItypeState_0 =>
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
				done_FSM      <='0';	
				if st = '1' then
					DTCM_addr_in <= '1';
					DTCM_addr_out <= '0';
					nxt_state <= ItypeState_11;
				elsif ld = '1' then
					DTCM_addr_out <= '1';
					DTCM_addr_in  <= '0';
					nxt_state <= ItypeState_12;
				end if;
				
			------ ItypeState Second Cycle ------
			when ItypeState_11 =>
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
				nxt_state <= Fetch;	
			when ItypeState_12 =>
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
				nxt_state <= ItypeState_122;	
			when ItypeState_122 =>
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
				nxt_state <= Fetch;

					
		end case;
	end process;

end behav;	

