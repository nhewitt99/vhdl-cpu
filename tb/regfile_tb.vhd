----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/5/2019
--
-- Purpose:
--     This code is a simple testbench for the register file component
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

entity regFileTB is
--  Port ( );
end regFileTB;

architecture Behavioral of regFileTB is

    -- Add the register file as a component
    component regFile
    port(
        addrRead1 : in STD_LOGIC_VECTOR (4 downto 0);
        addrRead2 : in STD_LOGIC_VECTOR (4 downto 0);
        addrWrite : in STD_LOGIC_VECTOR (4 downto 0);
        dataRead1 : out STD_LOGIC_VECTOR (63 downto 0);
        dataRead2 : out STD_LOGIC_VECTOR (63 downto 0);
        dataWrite : in STD_LOGIC_VECTOR (63 downto 0);
        writeEn : in STD_LOGIC;
        clk : in STD_LOGIC);
    end component;
    
    -- Signals to test it all
    signal read1 : STD_LOGIC_VECTOR (4 downto 0);
    signal read2 : STD_LOGIC_VECTOR (4 downto 0);
    signal write : STD_LOGIC_VECTOR (4 downto 0);
    signal data1 : STD_LOGIC_VECTOR (63 downto 0);
    signal data2 : STD_LOGIC_VECTOR (63 downto 0);
    signal dataW : STD_LOGIC_VECTOR (63 downto 0);
    signal we : STD_LOGIC;
    signal clk : STD_LOGIC;
    
    -- Signal to count for iteration
    signal countW : unsigned(4 downto 0) := "00000";
    signal countR : unsigned(4 downto 0) := "00000";

begin
    -- Unit under test
    uut : regFile port map(
            addrRead1 => read1,
            addrRead2 => read2,
            addrWrite => write,
            dataRead1 => data1,
            dataRead2 => data2,
            dataWrite => dataW,
            writeEn => we,
            clk => clk);
            
    -- Connect counters to addresses
    read2 <= STD_LOGIC_VECTOR(countR);
    write <= STD_LOGIC_VECTOR(countW);
            
    -- Process to test. Write everything to 0,
    --   read it all, write all Fs, read it all
    tb : process
    begin
        read1 <= "00000";
        dataW <= x"0000000000000000";
        we <= '1';
        clk <= '0';
        
        write_loop : for k in 0 to 31 loop
            clk <= '1';
            wait for 1 ns;
            clk <= '0';
            wait for 1 ns;
            countW <= countW + 1;
        end loop write_loop;
        
        read_loop : for k in 0 to 31 loop
            wait for 1 ns;
            countR <= countR + 1;
        end loop read_loop;
        
        dataW <= x"FFFFFFFFFFFFFFFF";
        countW <= "00000";
        
        write_loop2 : for k in 0 to 31 loop
            clk <= '1';
            wait for 1 ns;
            clk <= '0';
            wait for 1 ns;
            countW <= countW + 1;
        end loop write_loop2;
        
        read_loop2 : for k in 0 to 31 loop
            wait for 1 ns;
            countR <= countR + 1;
        end loop read_loop2;
        
        report "Loop ended!";
        wait;
    end process tb;

end Behavioral;
