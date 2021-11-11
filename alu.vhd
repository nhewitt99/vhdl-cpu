----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/30/2019
--
-- Purpose:
--     The ALU for this processor is capable of addition, subtraction, logical
--     shifts, logical NOT, AND, OR, and XOR, and passthroughs. It is asynchronous
--     and operates on 32-bit operands.
-- Inputs: 
--     inA - 32 bit vector for first operand value
--     inB - 32 bit vector for second operand value
--     control - 4 bit vector to choose ALU operation as follows:
--        0000 - Passthrough A
--        0001 - Passthrough B
--        0010 - Add A and B
--        0011 - Subtract B from A
--        0100 - Shift A left B bits
--        0101 - Shift A right B bits
--        0110 - NOT B
--        0111 - A AND B
--        1000 - A OR B
--        1001 - A XOR B
--        1010 - Subtract B from A, set flags
-- Outputs:
--     output - 32 bit vector for result from the chosen operation
--     zero - Boolean true if result was zero
--     over - Boolean true if result overflowed
--     neg - Boolean true if MSB of last result is 1
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

entity alu is     
    Port ( inA : in STD_LOGIC_VECTOR (31 downto 0);
           inB : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (3 downto 0);
           output : out STD_LOGIC_VECTOR (31 downto 0);
           zero : out STD_LOGIC;
           over : out STD_LOGIC;
           neg : out STD_LOGIC);
end alu;

architecture Behavioral of alu is
   
begin

    controlProcess : process(inA, inB, control)
    variable numA : signed(31 downto 0) := (others=>'0');
    variable numB : signed(31 downto 0) := (others=>'0');
    variable numO : signed(31 downto 0) := (others=>'0');
    variable varzero : std_logic := '0';
    variable varneg : std_logic := '0';
    variable varover : std_logic := '0';
    
    variable shiftTemp : std_logic_vector(31 downto 0) := (others=>'0');
    variable shiftTempWide : std_logic_vector(32 downto 0) := (others=>'0');

    begin
    
    numA := signed(inA);
    numB := signed(inB);
        
    case control is
        --Passthrough A
        when "0000" =>
            numO := numA;
            output <= std_logic_vector(numO);
        
        --Passthroughh B, mostly just used for CBZ so set zero flag
        when "0001" =>
            numO := numB;
            output <= std_logic_vector(numO);
            if numO = 0 then
                varzero := '1';
            else
                varzero := '0';
            end if;
        
        --A + B
        when "0010" =>
            numO := numA + numB;
            output <= std_logic_vector(numO);
        
        --A - B
        when "0011" =>
            numO := numA - numB;
            output <= std_logic_vector(numO);
        
        --A << B
        -- I originally had to do some crazy shift stuff to make shifts
        -- work for 64-bit width. Then I reread the project and realized
        -- that we only need 32-bit width, but this old version is
        -- remaining so I don't break anything.
        when "0100" =>
            shiftTemp := inA;
            if to_integer(numB) > 0 then
                for i in 1 to to_integer(numB) loop
                    shiftTempWide := (shiftTemp & "0");
                    shiftTemp := shiftTempWide(31 downto 0);
                end loop;
            else
                for i in 1 to to_integer(numB)*(-1) loop
                    shiftTempWide := ("0" & shiftTemp);
                    shiftTemp := shiftTempWide(32 downto 1);
                end loop;
            end if;
            output <= shiftTemp;
        
        --A >> B
        when "0101" =>
            shiftTemp := inA;
            if to_integer(numB) > 0 then
                for i in 1 to to_integer(numB) loop
                    shiftTempWide := ("0" & shiftTemp);
                    shiftTemp := shiftTempWide(32 downto 1);
                end loop;
            else
                for i in 1 to to_integer(numB)*(-1) loop
                    shiftTempWide := (shiftTemp & "0");
                    shiftTemp := shiftTempWide(31 downto 0);
                end loop;
            end if;
            
            output <= shiftTemp;
        
        --NOT B
        when "0110" =>
            output <= not inB;
        
        --A AND B
        when "0111" =>
            output <= inA and inB;
        
        --A OR B
        when "1000" =>
            output <= inA or inB;
        
        --A XOR B
        when "1001" =>
            output <= inA xor inB;
        
        --A - B, set flags
        when "1010" =>
            numO := numA - numB;
            output <= std_logic_vector(numO);
            -- report integer'image(to_integer(numA))
            -- & " " & integer'image(to_integer(numB))
            -- & " " & integer'image(to_integer(numO));
            
            --zero and negative
            if numO = 0 then
                varzero := '1';
            else
                varzero := '0';
            end if;
            
            varneg := numO(31);
            
            --overflow
            if inA(31) /= inB(31) then
                if numO(31) /= inA(31) then
                    varover := '1';
                else
                    varover := '0';
                end if;
            else
                varover := '0';
            end if;
            
            report "ZR=" & std_logic'image(varzero)
                & " NG=" & std_logic'image(varneg)
                & " OV=" & std_logic'image(varover);
            
            
        -- Base case
        when others =>
            output <= inA;
    end case;
    
    zero <= varzero;
    neg <= varneg;
    over <= varover;
    
    end process controlProcess;

end Behavioral;
