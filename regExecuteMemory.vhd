----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 12/2/2019
--
-- Purpose:
--     The third pipeline register, connecting EX and MEM stages
-- Inputs / Outputs:
--     Each in/out pair corresponds to a signal necessary to pass between the
--     pipeline stages. Outputs are simply set to inputs on a rising clock cycle.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regExecuteMemory is
    Port ( inPC : in STD_LOGIC_VECTOR (31 downto 0);
           inALUout : in STD_LOGIC_VECTOR (31 downto 0);
           inData2 : in STD_LOGIC_VECTOR (31 downto 0);
           inImm : in STD_LOGIC_VECTOR (31 downto 0);
           inWriteAddr : in STD_LOGIC_VECTOR (4 downto 0);
           inRegWrite : in STD_LOGIC;
           inZero : in STD_LOGIC;
           inLink : in STD_LOGIC;
           inBranch : in STD_LOGIC;
           inBranchR : in STD_LOGIC;
           inUncond : in STD_LOGIC;
           inAbsolute : in STD_LOGIC;
           inDataWrite : in STD_LOGIC;
           inMemToReg : in STD_LOGIC;
           
           outPC : out STD_LOGIC_VECTOR (31 downto 0);
           outALUout : out STD_LOGIC_VECTOR (31 downto 0);
           outData2 : out STD_LOGIC_VECTOR (31 downto 0);
           outImm : out STD_LOGIC_VECTOR (31 downto 0);
           outWriteAddr : out STD_LOGIC_VECTOR (4 downto 0);
           outRegWrite : out STD_LOGIC;
           outZero : out STD_LOGIC;
           outLink : out STD_LOGIC;
           outBranch : out STD_LOGIC;
           outBranchR : out STD_LOGIC;
           outUncond : out STD_LOGIC;
           outAbsolute : out STD_LOGIC;
           outDataWrite : out STD_LOGIC;
           outMemToReg : out STD_LOGIC;
           
           clk : in STD_LOGIC);
end regExecuteMemory;

architecture Behavioral of regExecuteMemory is

    -- Variables to store the memory
    signal sigPC : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigALUout : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigD2 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigImm : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigWriteAddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal sigRegWrite : STD_LOGIC := '0';
    signal sigZero : STD_LOGIC := '0';
    signal sigLink : STD_LOGIC := '0';
    signal sigBranch : STD_LOGIC := '0';
    signal sigBranchR : STD_LOGIC := '0';
    signal sigUncond : STD_LOGIC := '0';
    signal sigAbsolute : STD_LOGIC := '0';
    signal sigDataWrite : STD_LOGIC := '0';
    signal sigMemToReg : STD_LOGIC := '0';

begin

    -- Write out stored data
    outPC <= sigPC;
    outALUout <= sigALUout;
    outData2 <= sigD2;
    outImm <= sigImm;
    outRegWrite <= sigRegWrite;
    outWriteAddr <= sigWriteAddr;
    outZero <= sigZero;
    outLink <= sigLink;
    outBranch <= sigBranch;
    outBranchR <= sigBranchR;
    outUncond <= sigUncond;
    outAbsolute <= sigAbsolute;
    outDataWrite <= sigDataWrite;
    outMemToReg <= sigMemToReg;

    -- Process to write to registers on clock rising edge
    clkProcess : process(clk) is
    begin
        if rising_edge(clk) then
            sigPC <= inPC;
            sigALUout <= inALUout;
            sigD2 <= inData2;
            sigImm <= inImm;
            sigRegWrite <= inRegWrite;
            sigWriteAddr <= inWriteAddr;
            sigZero <= inZero;
            sigLink <= inLink;
            sigBranch <= inBranch;
            sigBranchR <= inBranchR;
            sigUncond <= inUncond;
            sigAbsolute <= inAbsolute;
            sigDataWrite <= inDataWrite;
            sigMemToReg <= inMemToReg;
        end if;
    end process clkProcess;

end Behavioral;
