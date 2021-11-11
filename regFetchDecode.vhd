----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 12/2/2019
--
-- Purpose:
--     The first pipeline register, connecting IF and ID stages
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

entity regFetchDecode is
    Port ( inPC : in STD_LOGIC_VECTOR (31 downto 0);
           inInstruct : in STD_LOGIC_VECTOR (31 downto 0);
           outPC : out STD_LOGIC_VECTOR (31 downto 0);
           outInstruct : out STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC);
end regFetchDecode;

architecture Behavioral of regFetchDecode is

    -- Variables to store the memory
    signal sigPC : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal sigIn : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');

begin

    -- Write out stored data
    outPC <= sigPC;
    outInstruct <= sigIn;

    -- Process to write to registers on clock rising edge
    clkProcess : process(clk) is
    begin
        if rising_edge(clk) then
            sigPC <= inPC;
            sigIn <= inInstruct;
        end if;
    end process clkProcess;

end Behavioral;
