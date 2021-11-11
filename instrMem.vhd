----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/28/2019
--
-- Purpose:
--     This component acts as the instruction memory for the CPU. It is asynchronous
--     and is allocated in 8-bit blocks. Its current implementation has 2KB of 
--     addressable memory (for simulation purposes) but could be expanded to 2^32 bytes.
-- Inputs: 
--     addrRead - 32 bit vector specifying which byte to read
-- Outputs:
--     instruction - 32 bit vector for the current instruction's 4 bytes
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instrMem is
    Port ( addrRead : in STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end instrMem;

architecture Behavioral of instrMem is

    -- Variables to store the memory
    type ram_type is array (0 to 2047) of bit_vector(7 downto 0);
    --signal ram : ram_type := (others=>(others=>'0'));
    
    -- Initialize from text file, from Vivado's UG901 document
    impure function InitRamFromFile (RamFileName : in string) return ram_type is
        FILE RamFile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : ram_type;
        begin
        for I in ram_type'range loop
            readline (RamFile, RamFileLine);
            
            -- Skip two lines if one was empty, signifying comment
            while RamFileLine'Length = 0 loop
                readline (RamFile, RamFileLine);
                readline (RamFile, RamFileLine);
            end loop;
            
            read (RamFileLine, ram(I));
        end loop;
        return ram;
    end function;
    
    signal ram : ram_type := InitRamFromFile("data/program.dat");

begin

    -- Combinatorially read out the correct word
    instruction(7 downto 0) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 3));
    instruction(15 downto 8) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 2));
    instruction(23 downto 16) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 1));
    instruction(31 downto 24) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 0));

end Behavioral;
