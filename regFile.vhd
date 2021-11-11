----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/27/2019
--
-- Purpose:
--     This component is a two-port register file allowing asynchronous read and
--     synchronous write capabilities. The file is 32x64 and uses active-high logic.
-- Inputs: 
--     addrRead1 - 5 bit vector specifying a register to read from
--     addrRead2 - 5 bit vector specifying a second register to read from
--     addrWrite - 5 bit vector specifying which register to write into
--     dataWrite - 32 bit vector containing data to write into addrWrite location
--     writeEn - Boolean, true allows writing to file
--     clk - Clock signal for writes, rising edge active
-- Outputs:
--     dataRead1 - 32 bit vector of data stored at addrRead1 location
--     dataRead2 - 32 bit vector of data stored at addrRead2 location
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regFile is
    Port ( addrRead1 : in STD_LOGIC_VECTOR (4 downto 0);
           addrRead2 : in STD_LOGIC_VECTOR (4 downto 0);
           addrWrite : in STD_LOGIC_VECTOR (4 downto 0);
           dataRead1 : out STD_LOGIC_VECTOR (31 downto 0);
           dataRead2 : out STD_LOGIC_VECTOR (31 downto 0);
           dataWrite : in STD_LOGIC_VECTOR (31 downto 0);
           writeEn : in STD_LOGIC;
           clk : in STD_LOGIC);
end regFile;

architecture Behavioral of regFile is

    -- Variables to store the memory
    type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others=>(others=>'0'));

begin

    -- Combinatorially write out the correct register
    dataRead1 <= ram(to_integer(unsigned(addrRead1)));
    dataRead2 <= ram(to_integer(unsigned(addrRead2)));

    -- Process to write to registers on clock rising edge
    clkProcess : process(clk) is
    begin
        if rising_edge(clk) and (writeEn = '1') then
            if unsigned(addrWrite) /= 31 then
                ram(to_integer(unsigned(addrWrite))) <= dataWrite;
                report "Register " & integer'image(to_integer(unsigned(addrWrite)))
                    & " written with " & integer'image(to_integer(signed(dataWrite)));
            end if;
        end if;
    end process clkProcess;

end Behavioral;
