----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/29/2019
--
-- Purpose:
--     This component acts as the data memory for the CPU. It is asynchronous
--     and is allocated in 8-bit blocks. Its current implementation has 2KB of 
--     addressable memory (for simulation purposes) but could be expanded to 2^32 bytes.
-- Inputs: 
--     addrRead - 32 bit vector specifying which byte to read
--     dataIn - 32 bit vector for data to write into memory
--     writeEn - Boolean, true allows writing to file
--     clk - Boolean, rising edge write
-- Outputs:
--     data - 32 bit vector for the 8 bytes at the given location
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dataMem is
    Port ( addrRead : in STD_LOGIC_VECTOR (31 downto 0);
           dataIn : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           writeEn : in STD_LOGIC;
           data : out STD_LOGIC_VECTOR (31 downto 0));
end dataMem;

architecture Behavioral of dataMem is

    -- Variables to store the memory
    type ram_type is array (0 to 2047) of bit_vector(7 downto 0);
    signal ram : ram_type := (others=>(others=>'0'));

begin

    -- Combinatorially read out the correct doubleword
    data(7 downto 0) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead))))
            when unsigned(addrRead) < 2040 else x"00";
    data(15 downto 8) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 1))
            when unsigned(addrRead) < 2040 else x"00";
    data(23 downto 16) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 2))
            when unsigned(addrRead) < 2040 else x"00";
    data(31 downto 24) <=
            to_stdlogicvector(ram(to_integer(unsigned(addrRead)) + 3))
            when unsigned(addrRead) < 2040 else x"00";
            
    -- Write into memory if write_en is on
    writeprocess : process(clk) is
    begin
        if rising_edge(clk) and writeEn = '1' and (unsigned(addrRead) < 2040) then
            ram(to_integer(unsigned(addrRead))) <=
                    to_bitvector(dataIn(7 downto 0));
            ram(to_integer(unsigned(addrRead)) + 1) <=
                    to_bitvector(dataIn(15 downto 8));
            ram(to_integer(unsigned(addrRead)) + 2) <=
                    to_bitvector(dataIn(23 downto 16));
            ram(to_integer(unsigned(addrRead)) + 3) <=
                    to_bitvector(dataIn(31 downto 24));
            report "Address " & integer'image(to_integer(unsigned(addrRead)))
                & " written with " & integer'image(to_integer(signed(dataIn)));
        end if;
    end process writeprocess;

end Behavioral;
