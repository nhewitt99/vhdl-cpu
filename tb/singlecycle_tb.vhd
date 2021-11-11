----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/30/2019
--
-- Purpose:
--     Debug test bench for single cycle.
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

entity singlecycletb is
--  Port ( );
end singlecycletb;

architecture Behavioral of singlecycletb is

    -- Add the register file as a component
    component singlecycle
    port( clk : in STD_LOGIC;
          halt : out STD_LOGIC);
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal halt : STD_LOGIC := '0';

begin
    -- Unit under test
    uut : singlecycle port map(
            clk => clk,
            halt => halt);
            
    -- Process to test.
    tb : process
    begin
    while true loop
        if halt = '1' then report "halt!"; exit; end if;
        
        -- 250ps period = 4GHz
        wait for 125 ps;
        clk <= '1';
        wait for 125 ps;
        clk <= '0';
    end loop;
    wait;
    end process tb;

end Behavioral;
