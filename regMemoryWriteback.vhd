----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 12/2/2019
--
-- Purpose:
--     The fourth pipeline register, connecting MEM and WB stages
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

entity regMemoryWriteback is
    Port ( inPC : in STD_LOGIC_VECTOR (31 downto 0);
           inALUout : in STD_LOGIC_VECTOR (31 downto 0);
           inMemData : in STD_LOGIC_VECTOR (31 downto 0);
           inWriteAddr : in STD_LOGIC_VECTOR (4 downto 0);
           inRegWrite : in STD_LOGIC;
           inLink : in STD_LOGIC;
           inMemToReg : in STD_LOGIC;
           
           outPC : out STD_LOGIC_VECTOR (31 downto 0);
           outALUout : out STD_LOGIC_VECTOR (31 downto 0);
           outMemData : out STD_LOGIC_VECTOR (31 downto 0);
           outWriteAddr : out STD_LOGIC_VECTOR (4 downto 0);
           outRegWrite : out STD_LOGIC;
           outLink : out STD_LOGIC;
           outMemToReg : out STD_LOGIC;
           
           clk : in STD_LOGIC);
end regMemoryWriteback;

architecture Behavioral of regMemoryWriteback is

    -- Variables to store the memory
    signal sigPC : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigALUout : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigMemData : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigWriteAddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal sigRegWrite : STD_LOGIC := '0';
    signal sigLink : STD_LOGIC := '0';
    signal sigMemToReg : STD_LOGIC := '0';

begin

    -- Write out stored data
    outPC <= sigPC;
    outALUout <= sigALUout;
    outMemData <= sigMemData;
    outRegWrite <= sigRegWrite;
    outWriteAddr <= sigWriteAddr;
    outLink <= sigLink;
    outMemToReg <= sigMemToReg;

    -- Process to write to registers on clock rising edge
    clkProcess : process(clk) is
    begin
        if rising_edge(clk) then
            sigPC <= inPC;
            sigALUout <= inALUout;
            sigMemData <= inMemData;
            sigRegWrite <= inRegWrite;
            sigWriteAddr <= inWriteAddr;
            sigLink <= inLink;
            sigMemToReg <= inMemToReg;
        end if;
    end process clkProcess;

end Behavioral;
