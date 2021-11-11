----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/30/2019
--
-- Purpose:
--     Because of this CPU's simplified instruction set (16 instructions), the
--     control logic is likewise simplified, dependent on only a few bits from
--     the opcode. From the opcode, this unit sets the control signals necessary
--     for the other components of the CPU.
-- Inputs: 
--     instruction - The whole instruction, can't just use opcode because
--          the immediate for branches must be found as well
-- Outputs:
--     alu - 4 bit code to control the ALU operation
--     reg2loc - Boolean true if register 2's location is in bits 4-0 of the
--          instruction, false if in bits 20-16
--     uncond - Boolean true if an unconditional branch instruction
--     branch - Boolean true if a branch instruction
--     branchr - Boolean true if a branch to register instruction
--     absolute - Boolean true if a branch is absolute, rather than PC-relative
--     link - Boolean true if the PC should be written to register
--     memtoreg - Boolean true if register write comes from data instead of ALU
--     alusrc - Boolean true if ALU B input is an immediate from instruction
--     regwrite - Boolean true if the register should be written into
--     datawrite - Boolean true if the data memory should be written into
--     immediate - 32 bit immediate for arithmetic and branches
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

entity control is     
    Port ( instruction : in STD_LOGIC_VECTOR (31 downto 0);
           alu : out STD_LOGIC_VECTOR (3 downto 0);
           reg2loc : out STD_LOGIC;
           uncond : out STD_LOGIC;
           branch : out STD_LOGIC;
           branchr : out STD_LOGIC;
           link : out STD_LOGIC;
           absolute : out STD_LOGIC;
           memtoreg : out STD_LOGIC;
           alusrc : out STD_LOGIC;
           regwrite : out STD_LOGIC;
           datawrite : out STD_LOGIC;
           immediate : out STD_LOGIC_VECTOR(31 downto 0));
end control;

architecture Behavioral of control is
   
begin
    controlProcess : process(instruction)
    begin
        -- nop
        if unsigned(instruction) = 0 then
            alu <= "0000";
            reg2loc <= '0';
            uncond <= '0';
            branch <= '0';
            branchr <= '0';
            link <= '0';
            absolute <= '0';
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '0';
            datawrite <= '0';
            immediate <= (others=>'0');
    
        -- link, puts PC+8 in a register
        elsif instruction(31 downto 21) = "11111111111" then
            alu <= "0000";
            reg2loc <= '0';
            uncond <= '0';
            branch <= '0';
            branchr <= '0';
            link <= '1';
            absolute <= '0';
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '1';
            datawrite <= '0';
            immediate <= (others=>'0');
    
        -- B is the only instruction starting with zero
        elsif instruction(31) = '0' then
            alu <= "0000";
            reg2loc <= '0';
            uncond <= '1';
            branch <= '0';
            branchr <= '0';
            link <= '0';
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '0';
            datawrite <= '0';
            immediate <= std_logic_vector(resize(
                signed(instruction(23 downto 0)), immediate'length));
                
            -- Bit 27 signifies an absolute branch
            absolute <= instruction(27);
        
        -- Only the R-type instructions have 1 at location 25
        elsif instruction(25) = '1' then
            reg2loc <= '0';
            uncond <= '0';
            branch <= '0';
            link <= '0';
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '1';
            datawrite <= '0';
            immediate <= (others=>'0');
            
            -- MOV, treated like "ADD Rd, Rn, XZR"
            if instruction(23) = '1' then
                alu <= "0010";
                branchr <= '0';
                absolute <= '0';
            
            -- BR
            elsif instruction(26) = '1' then
                alu <= "0000";
                regwrite <= '0';
                branchr <= '1';
                
                -- Bit 27 for absolute branch
                absolute <= instruction(27);
                
            
            -- LSL or LSR
            elsif instruction(22) = '1' then
                branchr <= '0';
                absolute <= '0';
                
                -- LSL
                if instruction(21) = '1' then
                    alu <= "0100";
                -- LSR
                else
                    alu <= "0101";
                end if;
                
            -- ADD or SUB
            elsif instruction(24) = '1' then
                branchr <= '0';
                absolute <= '0';
                
                -- ADD
                if instruction(30) = '0' then
                    alu <= "0010";
                -- SUB
                else
                    alu <= "0011";
                end if;
            
            -- Else, OR or AND
            else
                branchr <= '0';
                absolute <= '0';
                
                -- OR
                if instruction(29) = '1' then
                    alu <= "1000";
                -- AND
                else
                    alu <= "0111";
                end if;
            end if;
            
        -- Both I-type instructions have 0 at location 29
        elsif instruction(29) = '0' then
            branchr <= '0';
            reg2loc <= '0';
            uncond <= '0';
            branch <= '0';
            branchr <= '0';
            link <= '0';
            absolute <= '0';
            memtoreg <= '0';
            alusrc <= '1';
            regwrite <= '1';
            datawrite <= '0';
            immediate <= std_logic_vector(resize(
                signed(instruction(21 downto 10)), immediate'length));
            
            -- ADDI
            if instruction(30) = '0' then
                alu <= "0010";
            -- SUBI
            else
                alu <= "0011";
            end if;
        
        -- Both D-type instructions have 1 at location 27
        elsif instruction(27) = '1' then
            reg2loc <= '1';
            alu <= "0010"; -- ALU set to add for offset
            uncond <= '0';
            branch <= '0';
            branchr <= '0';
            link <= '0';
            absolute <= '0';
            alusrc <= '1';
            immediate <= std_logic_vector(resize(
                signed(instruction(20 downto 10)), immediate'length));
            
            -- LDUR
            if instruction(22) = '1' then
                memtoreg <= '1';
                regwrite <= '1';
                datawrite <= '0';
            -- STUR
            else
                memtoreg <= '0';
                regwrite <= '0';
                datawrite <= '1';
            end if;
        
        -- CBZ has 0 at location 24
        elsif instruction(24) = '0' then
            alu <= "0001"; -- Check if B is zero
            reg2loc <= '1';
            uncond <= '0';
            branch <= '1';
            branchr <= '0';
            link <= '0';
            absolute <= instruction(30);
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '0';
            datawrite <= '0';
            immediate <= std_logic_vector(resize(
                signed(instruction(23 downto 5)), immediate'length));
        
        -- Else, must be CMP
        else
            alu <= "1010"; -- Subtract, set flags
            reg2loc <= '1';
            uncond <= '0';
            branch <= '0';
            branchr <= '0';
            link <= '0';
            absolute <= '0';
            memtoreg <= '0';
            alusrc <= '0';
            regwrite <= '0'; -- DON'T write back result
            datawrite <= '0';
            immediate <= (others=>'0');
        
        end if;
    end process controlProcess;

end Behavioral;
