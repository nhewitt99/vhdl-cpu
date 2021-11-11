----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/19/2019
--
-- Purpose:
--     This code is a simple testbench for the ALU
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

entity aluTB is
--  Port ( );
end aluTB;

architecture Behavioral of aluTB is

    -- Add the register file as a component
    component alu
    port(
        inA : in STD_LOGIC_VECTOR (31 downto 0);
        inB : in STD_LOGIC_VECTOR (31 downto 0);
        control : in STD_LOGIC_VECTOR (3 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0);
        zero : out STD_LOGIC;
        over : out STD_LOGIC;
        neg : out STD_LOGIC);
    end component;
    
    -- Signals to test it all
    signal inA : STD_LOGIC_VECTOR (31 downto 0) := x"00000001";
    signal inB : STD_LOGIC_VECTOR (31 downto 0) := x"00000002";
    signal control : STD_LOGIC_VECTOR (3 downto 0) := (others=>'0');
    signal output : STD_LOGIC_VECTOR (31 downto 0);
    signal zero : STD_LOGIC;
    signal over : STD_LOGIC;
    signal neg : STD_LOGIC;
    
    -- Signal to iterate through control signals
    signal ctrl : unsigned(3 downto 0) := (others=>'0');

begin
    -- Unit under test
    uut : alu port map(
            inA => inA,
            inB => inB,
            control => control,
            output => output,
            zero => zero,
            over => over,
            neg => neg);
            
    control <= std_logic_vector(ctrl);
            
    tb : process
    begin
        control_loop : for k in 0 to 10 loop
            wait for 2 ns;
            ctrl <= ctrl + 1;
        end loop control_loop;
        
        report "Loop done";
        wait;
        
    end process tb;

end Behavioral;
