----------------------------------------------------------------------------------
-- Author: Nathan Hewitt, nhewitt@uncc.edu
--
-- Designed and written for UNCC ECGR 3183, Computer Organization
-- LEGv8 CPU Project, Fall 2019
-- 
-- Latest revision: 12/2/2019
--
-- Purpose:
--     This is the pipelined CPU parent object. A less tired version
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

entity pipelined is
    Port ( clk : in STD_LOGIC;
           halt : out STD_LOGIC);
end pipelined;

architecture Behavioral of pipelined is

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
    
    -- IF/ID pipeline register
    component regFetchDecode
    port(
        inPC : in STD_LOGIC_VECTOR (31 downto 0);
        inInstruct : in STD_LOGIC_VECTOR (31 downto 0);
        outPC : out STD_LOGIC_VECTOR (31 downto 0);
        outInstruct : out STD_LOGIC_VECTOR (31 downto 0);
        clk : in STD_LOGIC);
    end component;
    
    -- ID/EX pipeline register
    component regDecodeExecute
    port(
        inPC : in STD_LOGIC_VECTOR (31 downto 0);
        inData1 : in STD_LOGIC_VECTOR (31 downto 0);
        inData2 : in STD_LOGIC_VECTOR (31 downto 0);
        inImm : in STD_LOGIC_VECTOR (31 downto 0);
        inALU : in STD_LOGIC_VECTOR (3 downto 0);
        inWriteAddr : in STD_LOGIC_VECTOR (4 downto 0);
        inALUsrc : in STD_LOGIC;
        inRegWrite : in STD_LOGIC;
        inLink : in STD_LOGIC;
        inBranch : in STD_LOGIC;
        inBranchR : in STD_LOGIC;
        inUncond : in STD_LOGIC;
        inAbsolute : in STD_LOGIC;
        inDataWrite : in STD_LOGIC;
        inMemToReg : in STD_LOGIC;
        
        outPC : out STD_LOGIC_VECTOR (31 downto 0);
        outData1 : out STD_LOGIC_VECTOR (31 downto 0);
        outData2 : out STD_LOGIC_VECTOR (31 downto 0);
        outImm : out STD_LOGIC_VECTOR (31 downto 0);
        outALU : out STD_LOGIC_VECTOR (3 downto 0);
        outWriteAddr : out STD_LOGIC_VECTOR (4 downto 0);
        outALUsrc : out STD_LOGIC;
        outRegWrite : out STD_LOGIC;
        outLink : out STD_LOGIC;
        outBranch : out STD_LOGIC;
        outBranchR : out STD_LOGIC;
        outUncond : out STD_LOGIC;
        outAbsolute : out STD_LOGIC;
        outDataWrite : out STD_LOGIC;
        outMemToReg : out STD_LOGIC;
        
        clk : in STD_LOGIC);
    end component;
    
    -- EX/MEM pipeline register
    component regExecuteMemory
    port(
        inPC : in STD_LOGIC_VECTOR (31 downto 0);
        inALUout : in STD_LOGIC_VECTOR (31 downto 0);
        inData2 : in STD_LOGIC_VECTOR (31 downto 0);
        inImm : in STD_LOGIC_VECTOR (31 downto 0);
        inWriteAddr : in STD_LOGIC_VECTOR (4 downto 0);
        inRegWrite : in STD_LOGIC;
        inZero : in STD_LOGIC;
        inLink : in STD_LOGIC;
        inBranch : in STD_LOGIC;
        inBranchR : in STD_LOGIC;
        inUncond : in STD_LOGIC;
        inAbsolute : in STD_LOGIC;
        inDataWrite : in STD_LOGIC;
        inMemToReg : in STD_LOGIC;
        
        outPC : out STD_LOGIC_VECTOR (31 downto 0);
        outALUout : out STD_LOGIC_VECTOR (31 downto 0);
        outData2 : out STD_LOGIC_VECTOR (31 downto 0);
        outImm : out STD_LOGIC_VECTOR (31 downto 0);
        outWriteAddr : out STD_LOGIC_VECTOR (4 downto 0);
        outRegWrite : out STD_LOGIC;
        outZero : out STD_LOGIC;
        outLink : out STD_LOGIC;
        outBranch : out STD_LOGIC;
        outBranchR : out STD_LOGIC;
        outUncond : out STD_LOGIC;
        outAbsolute : out STD_LOGIC;
        outDataWrite : out STD_LOGIC;
        outMemToReg : out STD_LOGIC;
        
        clk : in STD_LOGIC);
    end component;
    
    -- MEM/WB pipeline register
    component regMemoryWriteback
    port(
        inPC : in STD_LOGIC_VECTOR (31 downto 0);
        inALUout : in STD_LOGIC_VECTOR (31 downto 0);
        inMemData : in STD_LOGIC_VECTOR (31 downto 0);
        inWriteAddr : in STD_LOGIC_VECTOR (4 downto 0);
        inRegWrite : in STD_LOGIC;
        inLink : in STD_LOGIC;
        inMemToReg : in STD_LOGIC;
        
        outPC : out STD_LOGIC_VECTOR (31 downto 0);
        outALUout : out STD_LOGIC_VECTOR (31 downto 0);
        outMemData : out STD_LOGIC_VECTOR (31 downto 0);
        outWriteAddr : out STD_LOGIC_VECTOR (4 downto 0);
        outRegWrite : out STD_LOGIC;
        outLink : out STD_LOGIC;
        outMemToReg : out STD_LOGIC;
        
        clk : in STD_LOGIC);
    end component;
    
    -- IF signals
    signal if_pc : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal if_instruction : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    
    -- ID signals
    signal id_pc : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal id_instruction : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal id_d1 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal id_d2 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal id_r1 : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal id_r2 : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal id_writeaddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal id_alu : STD_LOGIC_VECTOR (3 downto 0) := (others=>'0');
    signal id_reg2loc : STD_LOGIC := '0';
    signal id_uncond : STD_LOGIC := '0';
    signal id_branch : STD_LOGIC := '0';
    signal id_branchr : STD_LOGIC := '0';
    signal id_link : STD_LOGIC := '0';
    signal id_absolute : STD_LOGIC := '0';
    signal id_memtoreg : STD_LOGIC := '0';
    signal id_alusrc : STD_LOGIC := '0';
    signal id_regwrite : STD_LOGIC := '0';
    signal id_datawrite : STD_LOGIC := '0';
    signal id_immediate : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    
    -- EX signals
    signal ex_pc : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal ex_d1 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal ex_d2 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal ex_aluB : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal ex_aluout : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal ex_writeaddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal ex_alu : STD_LOGIC_VECTOR (3 downto 0) := (others=>'0');
    signal ex_zero : STD_LOGIC := '0';
    signal ex_uncond : STD_LOGIC := '0';
    signal ex_branch : STD_LOGIC := '0';
    signal ex_branchr : STD_LOGIC := '0';
    signal ex_link : STD_LOGIC := '0';
    signal ex_absolute : STD_LOGIC := '0';
    signal ex_memtoreg : STD_LOGIC := '0';
    signal ex_alusrc : STD_LOGIC := '0';
    signal ex_regwrite : STD_LOGIC := '0';
    signal ex_datawrite : STD_LOGIC := '0';
    signal ex_immediate : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    
    -- MEM signals
    signal mem_pc : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal mem_d2 : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal mem_aluout : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal mem_memdata : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal mem_writeaddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal mem_zero : STD_LOGIC := '0';
    signal mem_uncond : STD_LOGIC := '0';
    signal mem_branch : STD_LOGIC := '0';
    signal mem_branchr : STD_LOGIC := '0';
    signal mem_link : STD_LOGIC := '0';
    signal mem_absolute : STD_LOGIC := '0';
    signal mem_memtoreg : STD_LOGIC := '0';
    signal mem_regwrite : STD_LOGIC := '0';
    signal mem_datawrite : STD_LOGIC := '0';
    signal mem_immediate : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal mem_memaddress : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    
    -- WB signals
    signal wb_pc : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal wb_aluout : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal wb_memdata : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    signal wb_writeaddr : STD_LOGIC_VECTOR (4 downto 0) := (others=>'0');
    signal wb_memtoreg : STD_LOGIC := '0';
    signal wb_regwrite : STD_LOGIC := '0';
    signal wb_link : STD_LOGIC := '0';
    signal wb_writeback : STD_LOGIC_VECTOR (31 downto 0) := (others=>'0');
    
    -- Flags
    signal haltsig : STD_LOGIC := '0';
    signal over : STD_LOGIC := '0'; -- TODO implement these two properly, mistakenly
    signal neg : STD_LOGIC := '0';  -- missed them at first, and ran out of time to implement
    
begin
    halt <= haltsig;

    -- Map the register file
    u1: regFile
    port map(
        addrRead1 => id_r1,
        addrRead2 => id_r2,
        addrWrite => wb_writeaddr,
        dataRead1 => id_d1,
        dataRead2 => id_d2,
        dataWrite => wb_writeback,
        writeEn => wb_regwrite,
        clk => clk
    );
        
    -- Map the ALU
    u2: alu
    port map(
        inA => ex_d1,
        inB => ex_aluB,
        output => ex_aluout,
        control => ex_alu,
        zero => ex_zero,
        over => over,
        neg => neg
    );
    
    -- Map the instruction memory
    u3: instrMem
    port map(
        addrRead => if_pc,
        instruction => if_instruction
    );
    
    -- Map the data memory
    u4: dataMem
    port map(
        addrRead => mem_memaddress,
        dataIn => mem_d2,
        writeEn => mem_datawrite,
        data => mem_memdata,
        clk => clk
    );
    
    -- Map the control signals
    u5: control
    port map(
        instruction => id_instruction,
        alu => id_alu,
        reg2loc => id_reg2loc,
        uncond => id_uncond,
        branch => id_branch,
        branchr => id_branchr,
        link => id_link,
        absolute => id_absolute,
        memtoreg => id_memtoreg,
        alusrc => id_alusrc,
        regwrite => id_regwrite,
        datawrite => id_datawrite,
        immediate => id_immediate
    );
    
    -- Map IF/ID register
    u6: regFetchDecode
    port map(
        inPC => if_pc,
        inInstruct => if_instruction,
        outPC => id_pc,
        outInstruct => id_instruction,
        clk => clk
    );
    
    -- Map ID/EX register
    u7: regDecodeExecute
    port map(
        inPC => id_pc,
        inData1 => id_d1,
        inData2 => id_d2,
        inImm => id_immediate,
        inALU => id_alu,
        inWriteAddr => id_writeAddr,
        inALUsrc => id_alusrc,
        inRegWrite => id_regwrite,
        inLink => id_link,
        inBranch => id_branch,
        inBranchR => id_branchr,
        inUncond => id_uncond,
        inAbsolute => id_absolute,
        inDataWrite => id_datawrite,
        inMemToReg => id_memtoreg,
        outPC => ex_pc,
        outData1 => ex_d1,
        outData2 => ex_d2,
        outImm => ex_immediate,
        outALU => ex_alu,
        outWriteAddr => ex_writeaddr,
        outALUsrc => ex_alusrc,
        outRegWrite => ex_regwrite,
        outLink => ex_link,
        outBranch => ex_branch,
        outBranchR => ex_branchr,
        outUncond => ex_uncond,
        outAbsolute => ex_absolute,
        outDataWrite => ex_datawrite,
        outMemToReg => ex_memtoreg,
        clk => clk
    );
    
    -- Map EX/MEM register
    u8: regExecuteMemory
    port map(
        inPC => ex_pc,
        inALUout => ex_aluout,
        inData2 => ex_d2,
        inImm => ex_immediate,
        inWriteAddr => ex_writeaddr,
        inRegWrite => ex_regwrite,
        inZero => ex_zero,
        inLink => ex_link,
        inBranch => ex_branch,
        inBranchR => ex_branchr,
        inUncond => ex_uncond,
        inAbsolute => ex_absolute,
        inDataWrite => ex_datawrite,
        inMemToReg => ex_memtoreg,
        outPC => mem_pc,
        outALUout => mem_aluout,
        outData2 => mem_d2,
        outImm => mem_immediate,
        outWriteAddr => mem_writeaddr,
        outRegWrite => mem_regwrite,
        outZero => mem_zero,
        outLink => mem_link,
        outBranch => mem_branch,
        outBranchR => mem_branchr,
        outUncond => mem_uncond,
        outAbsolute => mem_absolute,
        outDataWrite => mem_datawrite,
        outMemToReg => mem_memtoreg,
        clk => clk
    );
    
    -- Map MEM/WB register
    u9: regMemoryWriteback
    port map(
        inPC => mem_pc,
        inALUout => mem_aluout,
        inMemData => mem_memdata,
        inWriteAddr => mem_writeaddr,
        inRegWrite => mem_regwrite,
        inLink => mem_link,
        inMemToReg => mem_memtoreg,
        outPC => wb_pc,
        outALUout => wb_aluout,
        outMemData => wb_memdata,
        outWriteAddr => wb_writeaddr,
        outRegWrite => wb_regwrite,
        outLink => wb_link,
        outMemToReg => wb_memtoreg,
        clk => clk
    );
    
    id_r1 <= id_instruction(9 downto 5);
    id_writeaddr <= id_instruction(4 downto 0);
    
    -- Prevent out-of-bounds for currently simulated memory size
    mem_memaddress <= "000000000000000000000" & mem_aluout(10 downto 0);
    
    -- Multiplex second register address
    id_r2 <= id_instruction(20 downto 16) when id_reg2loc = '0'
        else id_instruction(4 downto 0);
    
    -- Multiplex second ALU input for immediates
    ex_aluB <= ex_d2 when ex_alusrc = '0'
        else ex_immediate;
    
    -- Multiplex register writeback
    wb_writeback <= std_logic_vector(unsigned(wb_pc) + 8) when wb_link = '1'
        else wb_aluout when wb_memtoreg = '0'
        else wb_memdata;
    
    -- Increment PC on clock update
    clock : process(clk)
    begin
        if rising_edge(clk) then
            if if_instruction = x"FFFFFFFF" then haltsig <= '1'; end if;
        
            report "NEW CLOCK! PC was at " & integer'image(to_integer(signed(if_pc)))
                & " and instruction was " & integer'image(to_integer(signed(if_instruction)));
            
            -- Case to branch
            if mem_uncond = '1' or (mem_branch = '1' and mem_zero = '1') then
                if mem_absolute = '0' then
                    if_pc <= std_logic_vector(signed(mem_pc) + signed(mem_immediate));
                else
                    if_pc <= std_logic_vector(mem_immediate);
                end if;
            -- Case for branch to register
            elsif mem_branchr = '1' then
                if mem_absolute = '0' then
                    if_pc <= std_logic_vector(signed(mem_pc) + signed(mem_d2));
                else
                    if_pc <= std_logic_vector(mem_d2);
                end if;
            -- Case to not branch
            else
                if_pc <= std_logic_vector(unsigned(if_pc) + 4);
            end if;
        end if;
    end process clock;

end Behavioral;
