library IEEE;
use ieee.std_logic_1164.all;
package aux_package is
--------------------------------------------------------- 
	component FA is
		PORT (xi, yi, cin: IN std_logic;
			      s, cout: OUT std_logic);
	end component;
---------------------------------------------------------	
component pc IS
	GENERIC(addersize : INTEGER := 6 ;
		offsetsize : INTEGER := 8 );
	PORT (PCin,clk :IN std_logic;
	      PCsel : IN std_logic_vector(1 DOWNTO 0);
	      IRoffset : IN std_logic_vector (offsetsize-1 DOWNTO 0);
	      PCout : OUT std_logic_vector ( addersize-1 DOWNTO 0) := "000000"
	      );
END component;
------------------------------------------------------
component RF is
generic( 	 Dwidth: integer:=16;
		 Awidth: integer:=4);
port(		clk,rst,WregEn: 	in std_logic;	
		WregData:		in std_logic_vector(Dwidth-1 downto 0);
		WregAddr,RregAddr:	in std_logic_vector(Awidth-1 downto 0);
		RregData: 		out std_logic_vector(Dwidth-1 downto 0)
);
end component;
------------------------------------------------------
component ProgMem is
generic( 	Dwidth: integer:=16;
		Awidth: integer:=6;
		dept:   integer:=64);
port(		clk,memEn: 		in std_logic;	
		WmemData:		in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	in std_logic_vector(Awidth-1 downto 0);
		RmemData: 		out std_logic_vector(Dwidth-1 downto 0)
);
end component;
------------------------------------------------------
component opcdecoder IS
	GENERIC(regsize : INTEGER := 4 );
	PORT (IRop : IN std_logic_vector ( regsize-1 DOWNTO 0);
	      st,ld,mov,done,add,sub,jmp,jc,jnc,andd,orr,xorr : OUT std_logic 
	      );
END component;
------------------------------------------------------
component ALU IS
	GENERIC(bussize : INTEGER := 16;
		regsize : INTEGER := 4 );
	PORT (A,B : IN std_logic_vector ( bussize-1 DOWNTO 0);
	      ALUFN : IN std_logic_vector (regsize-1 DOWNTO 0);
	      CFlag,ZFlag,NFlag : OUT std_logic;
	      C : OUT std_logic_vector ( bussize-1 DOWNTO 0)
	      );
END component;
------------------------------------------------------
component IR IS
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
END component;
------------------------------------------------------
component dataMem is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64);
port(	clk,memEn: in std_logic;	
		WmemData:	in std_logic_vector(Dwidth-1 downto 0);
		WmemAddr,RmemAddr:	
					in std_logic_vector(Awidth-1 downto 0);
		RmemData: 	out std_logic_vector(Dwidth-1 downto 0)
);
end component;
------------------------------------------------------
component BidirPin is
	generic( width: integer:=16 );
	port(   	Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:	in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 		std_logic_vector(width-1 downto 0)
	);
end component;
------------------------------------------------------
component Control IS
	PORT(
		st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag : in std_logic;
		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out : out std_logic;
		ALUFN : out std_logic_vector(3 downto 0);
		PCsel, RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);
		clk, rst, ena : in STD_LOGIC;
		done_FSM : out std_logic
	);
END component;
------------------------------------------------------
component Datapath is
generic( 	 bussize: integer:=16;	-- Bus Size
		 regsize: integer:=4; 	-- Register Size
		 Awidth:  integer:=6;  	-- Address Size
		 offsetsize 	: integer := 8;
		 immidsize	: integer := 8;		 
		 dept:    integer:=64); -- Program Memory Size
port(	
		-- Op Status Signals --
		st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr, CFlag, ZFlag, NFlag : out std_logic;	
		-- Control Signals --
		IRin, Imm1_in, Imm2_in, RFin, RFout, PCin, Ain, DTCM_wr,DTCM_addr_sel,DTCM_addr_out,DTCM_addr_in,DTCM_out : in std_logic;
		ALUFN : in std_logic_vector(3 downto 0);
		PCsel, RFaddr_wr,RFaddr_rd : in std_logic_vector(1 downto 0);	
		-- Test Bench Signals --
		ena, clk, rst 			  : in std_logic;
		ITCM_tb_wr	 		  : in std_logic;
		ITCM_tb_in			  : in std_logic_vector(bussize-1 DOWNTO 0);
		ITCM_tb_addr_in		     	  : in std_logic_vector(Awidth-1 downto 0);
		DTCM_tb_out			  : out std_logic_vector(bussize-1 DOWNTO 0);
		DTCM_tb_wr,TBactive 	  	  : in std_logic ;
		DTCM_tb_addr_in,DTCM_tb_addr_out  : in std_logic_vector(Awidth-1 downto 0);
		DTCM_tb_in			  : in std_logic_vector(bussize-1 DOWNTO 0)
);

end component;
------------------------------------------------------
component top IS
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
END component;
------------------------------------------------------
end aux_package;
	
	
	
	
	
	
	
	
	
	
	

