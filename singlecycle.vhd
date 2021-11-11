----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 11/30/2019
--
-- Purpose:
--     This is the single-stage CPU parent object. A less tired version
--     of me will write more description here.
-- Inputs: 
--     clk - STD_LOGIC in to clock the CPU
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

entity singlecycle is
    Port ( clk : in STD_LOGIC;
           halt : out STD_LOGIC);
end singlecycle;

architecture Behavioral of singlecycle is

    -- Add the register file as a component
    component regFile
    port(
        addrRead1 : in STD_LOGIC_VECTOR (4 downto 0);
        addrRead2 : in STD_LOGIC_VECTOR (4 downto 0);
        addrWrite : in STD_LOGIC_VECTOR (4 downto 0);
        dataRead1 : out STD_LOGIC_VECTOR (31 downto 0);
        dataRead2 : out STD_LOGIC_VECTOR (31 downto 0);
        dataWrite : in STD_LOGIC_VECTOR (31 downto 0);
        writeEn : in STD_LOGIC;
        clk : in STD_LOGIC);
    end component;
    
    -- Add the ALU as a component
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
    
    -- Add the instruction memory as a component
    component instrMem
    port(
        addrRead : in STD_LOGIC_VECTOR (31 downto 0);
        instruction : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    -- Add the data memory as a componenet
    component dataMem
    port(
        addrRead : in STD_LOGIC_VECTOR (31 downto 0);
        dataIn : in STD_LOGIC_VECTOR (31 downto 0);
        writeEn : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR (31 downto 0);
        clk : in STD_LOGIC);
    end component;
    
    -- Add the control device as a component
    component control
    port(
        instruction : in STD_LOGIC_VECTOR (31 downto 0);
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
    end component;
    
    -- Buses
    signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal instruction : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal readaddr1 : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal readaddr2 : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal writeaddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal readdata1 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal readdata2 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal writedata : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal aluB : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal aluout : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal memaddr : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal writememdata : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal readmemdata : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal alucontrol : STD_LOGIC_VECTOR(3 downto 0) := (others=>'0');
    signal immediate : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    
    -- Flags
    signal reg2loc : STD_LOGIC := '0';
    signal uncond : STD_LOGIC := '0';
    signal branch : STD_LOGIC := '0';
    signal branchr : STD_LOGIC := '0';
    signal link : STD_LOGIC := '0';
    signal absolute : STD_LOGIC := '0';
    signal memtoreg : STD_LOGIC := '0';
    signal alusrc : STD_LOGIC := '0';
    signal regwrite : STD_LOGIC := '0';
    signal datawrite : STD_LOGIC := '0';
    signal zero : STD_LOGIC := '0';
    signal neg : STD_LOGIC := '0';
    signal over : STD_LOGIC := '0';
    signal haltsig : STD_LOGIC := '0';
    
begin
    halt <= haltsig;

    -- Map the register file
    u1: regFile
    port map(
        addrRead1 => readaddr1,
        addrRead2 => readaddr2,
        addrWrite => writeaddr,
        dataRead1 => readdata1,
        dataRead2 => readdata2,
        dataWrite => writedata,
        writeEn => regwrite,
        clk => clk
    );
        
    -- Map the ALU
    u2: alu
    port map(
        inA => readdata1,
        inB => aluB,
        output => aluout,
        control => alucontrol,
        zero => zero,
        over => over,
        neg => neg
    );
    
    -- Map the instruction memory
    u3: instrMem
    port map(
        addrRead => pc,
        instruction => instruction
    );
    
    -- Map the data memory
    u4: dataMem
    port map(
        addrRead => memaddr,
        dataIn => writememdata,
        writeEn => datawrite,
        data => readmemdata,
        clk => clk
    );
    
    -- Map the control signals
    u5: control
    port map(
        instruction => instruction,
        alu => alucontrol,
        reg2loc => reg2loc,
        uncond => uncond,
        branch => branch,
        branchr => branchr,
        link => link,
        absolute => absolute,
        memtoreg => memtoreg,
        alusrc => alusrc,
        regwrite => regwrite,
        datawrite => datawrite,
        immediate => immediate
    );
    
    readaddr1 <= instruction(9 downto 5);
    writeaddr <= instruction(4 downto 0);
    writememdata <= readdata2;
    
    -- Do some acrobatics to prevent out-of-bounds with the
    -- tiny 2kb memory I'm simulating
    memaddr <= "000000000000000000000" & aluout(10 downto 0);
    
    -- Multiplex second register address
    readaddr2 <= instruction(20 downto 16) when reg2loc = '0'
        else instruction(4 downto 0);
    
    -- Multiplex second ALU input for immediates
    aluB <= readdata2 when alusrc = '0'
        else immediate;
    
    -- Multiplex register writeback
    writedata <= std_logic_vector(unsigned(pc) + 8) when link = '1'
        else aluout when memtoreg = '0'
        else readmemdata;
    
    -- Increment PC on clock update
    clock : process(clk)
    begin
        if rising_edge(clk) then
            if instruction = x"FFFFFFFF" then haltsig <= '1'; end if;
        
            report "NEW CLOCK! PC was at " & integer'image(to_integer(signed(pc)))
                & " and instruction was " & integer'image(to_integer(signed(instruction)));
            
            -- Case to branch
            if uncond = '1' or (branch = '1' and zero = '1') then
                if absolute = '0' then
                    pc <= std_logic_vector(signed(pc) + signed(immediate));
                else
                    pc <= std_logic_vector(immediate);
                end if;
            -- Case for branch to register
            elsif branchr = '1' then
                if absolute = '0' then
                    pc <= std_logic_vector(signed(pc) + signed(readdata2));
                else
                    pc <= std_logic_vector(readdata2);
                end if;
            -- Case to not branch
            else
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process clock;

end Behavioral;
