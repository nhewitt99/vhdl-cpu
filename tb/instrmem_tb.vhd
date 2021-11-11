----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/27/2019
--
-- Purpose:
--     This code is a simple testbench for the instruction memory component
-- Inputs:
--     N/A
-- Outputs:
--     N/A
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instrMemTB is
--  Port ( );
end instrMemTB;

architecture Behavioral of instrMemTB is

    -- Add the register file as a component
    component instrMem
    port(
        addrRead : in STD_LOGIC_VECTOR (63 downto 0);
        instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    -- Signals to test it all
    signal read : STD_LOGIC_VECTOR (63 downto 0);
    signal instr : STD_LOGIC_VECTOR (31 downto 0);
    
    -- Signal to count for iteration
    signal count : unsigned(63 downto 0) := (others=>'0');

begin
    -- Unit under test
    uut : instrMem port map(
            addrRead => read,
            instruction => instr);
    
    read <= STD_LOGIC_VECTOR(count);
    
    tb : process
    begin
        
        readloop : for k in 0 to 2043 loop
            wait for 1 ns;
            count <= count + 1;
        end loop readloop;
        report "Loop done";
        wait;
        
    end process tb;

end Behavioral;