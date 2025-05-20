LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;
--------------------------------------------------------
entity Datapath is
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

end Datapath;
--------------------------------------------------------
ARCHITECTURE dataflow OF Datapath IS

-- Program Memory
signal PM_dataout     : std_logic_vector(bussize-1 downto 0);
signal PM_readaddr    : std_logic_vector(Awidth-1 downto 0) := (others => '0');

-- Data Memory
signal DM_dataout, DM_datain  : std_logic_vector(bussize-1 downto 0);
signal DM_wren                : std_logic;
signal DM_writeaddr, DM_readaddr : std_logic_vector(Awidth-1 downto 0);

-- Register File
signal RF_writeaddr, RF_readaddr : std_logic_vector(regsize-1 downto 0);
signal RF_datain, RF_dataout     : std_logic_vector(bussize-1 downto 0);

-- ALU
signal A, B : std_logic_vector(bussize-1 downto 0):= (others => '0') ;

-- IR Outputs
signal IR_offset : std_logic_vector(offsetsize-1 downto 0);
signal IR_imm    : std_logic_vector(immidsize-1 downto 0);
signal IR_op     : std_logic_vector(regsize-1 downto 0);

-- Buses
signal BUS_A,ALU_out, BUS_B : std_logic_vector(bussize-1 downto 0);

-- Immediate Logic
signal Immidiate   : std_logic_vector(bussize-1 downto 0);

-- Internal mux signals for DM addressing
signal DM_mux_writeaddr, DM_mux_readaddr : std_logic_vector(Awidth-1 downto 0);
signal DM_mux_writeplus, DM_mux_readplus : std_logic_vector(Awidth-1 downto 0);

BEGIN

-- Module Instantiations
ProgMemModule: progMem 
    generic map(bussize, Awidth, dept)
    port map(clk, ITCM_tb_wr, ITCM_tb_in, ITCM_tb_addr_in, PM_readaddr, PM_dataout);

DataMemModule: dataMem 
    generic map(bussize, Awidth, dept)
    port map(clk, DM_wren, DM_datain, DM_writeaddr, DM_readaddr, DM_dataout);

RegFileModule: RF 
    generic map(bussize, regsize)
    port map(clk, rst, RFin, RF_datain, RF_writeaddr, RF_readaddr, RF_dataout);

ALUModule: ALU 
    generic map(bussize, regsize)
    port map(A, BUS_B, ALUFN, CFlag, ZFlag, NFlag, ALU_out);

opcdecModule: opcdecoder 
    generic map(regsize)
    port map(IR_op, st, ld, mov, done, add, sub, jmp, jc, jnc, andd, orr, xorr);

pclogic: pc 
    generic map(Awidth, offsetsize)
    port map(PCin, clk, PCsel, IR_offset, PM_readaddr);

IRModule: IR 
    generic map(bussize, offsetsize, regsize, immidsize)
    port map(IRin, PM_dataout, RFaddr_wr, RFaddr_rd, RF_readaddr, RF_writeaddr, IR_offset, IR_imm, IR_op);

-- Bi-Directional Bus Connections
BusConnectionToRF: BidirPin 
    generic map(bussize) 
    port map(RF_dataout, RFout, open, BUS_B);

BusConnectionToDataMem: BidirPin 
    generic map(bussize) 
    port map(DM_dataout, DTCM_out, open, BUS_B);

BusConnectionToImm1: BidirPin 
    generic map(bussize) 
    port map(Immidiate, Imm1_in, open, BUS_B);

BusConnectionToImm2: BidirPin 
    generic map(bussize) 
    port map(Immidiate, Imm2_in, open, BUS_B);

Immidiate <= SXT(IR_imm, bussize) when Imm1_in = '1' else
             "000000000000" & IR_imm(3 downto 0) when Imm2_in = '1' else
             unaffected;

-- TB Muxes
DM_wren      <= DTCM_tb_wr    when TBactive = '1' else DTCM_wr;
DM_datain    <= DTCM_tb_in    when TBactive = '1' else BUS_B;
DM_writeaddr <= DTCM_tb_addr_in  when TBactive = '1' else DM_mux_writeaddr;
DM_readaddr  <= DTCM_tb_addr_out when TBactive = '1' else DM_mux_readaddr;
DTCM_tb_out  <= DM_dataout;

-- Register File Data In
BUS_A <= ALU_out;
RF_datain <= BUS_A;



-- ALU Register
process(clk)
begin
    if rising_edge(clk) then
        if Ain = '1' then
            A <= BUS_A;
        end if;
    end if;
end process;

-- Data Memory Address Update
process(clk)
begin
    if rising_edge(clk) then
        if DTCM_addr_out = '1' then
            if DTCM_addr_sel = '1' then
                DM_mux_readaddr <= BUS_B(Awidth-1 downto 0);
            else
                DM_mux_readaddr <= BUS_A(Awidth-1 downto 0);
            end if;
        end if;
        if DTCM_addr_in = '1' then
            if DTCM_addr_sel = '1' then
                DM_mux_writeaddr <= BUS_B(Awidth-1 downto 0);
            else
                DM_mux_writeaddr <= BUS_A(Awidth-1 downto 0);
            end if;
        end if;
    end if;
end process;





END dataflow;

