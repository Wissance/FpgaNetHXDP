library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.common_pkg.all;


entity decode_stage is

    Port (
             clk                       : in std_logic;
             reset                     : in std_logic;
             decode_flush	       : in std_logic;
             pc_idle	       : in std_logic;

             -- HF RESULT BROADCAST
             hf_result : in std_logic_vector(63 downto 0);
             hf_we : in std_logic;

             syllable                  : in std_logic_vector(63 downto 0);

             src_reg_add_in            : in std_logic_vector(3 downto 0);   -- from fetch stage
             src_reg_add_out           : out std_logic_vector(3 downto 0);   -- to exe stage
             src_reg_cont              : in std_logic_vector(63 downto 0);  -- from GP register file
             dst_reg_add_in            : in std_logic_vector(3 downto 0);   -- from fetch stage
             dst_reg_add_out           : out std_logic_vector(3 downto 0);   -- to exe stage
             dst_reg_cont              : in std_logic_vector(63 downto 0);  -- from GP register file

             -- SIGNALS FOR CROSSBAR
             addr_wb_0 : in std_logic_vector(3 downto 0);
             addr_wb_1 : in std_logic_vector(3 downto 0);
             addr_wb_2 : in std_logic_vector(3 downto 0);
             addr_wb_3 : in std_logic_vector(3 downto 0);

             wb_wrt_en_0 : in std_logic;
             wb_wrt_en_1 : in std_logic;
             wb_wrt_en_2 : in std_logic;
             wb_wrt_en_3 : in std_logic;

             cont_wb_0 : in std_logic_vector(63 downto 0);
             cont_wb_1 : in std_logic_vector(63 downto 0);
             cont_wb_2 : in std_logic_vector(63 downto 0);
             cont_wb_3 : in std_logic_vector(63 downto 0);

             -- INPUTS FOR LANE FORWARDING

             exe_wb_addr	: in std_logic_vector(3 downto 0);
             exe_wb_result	: in std_logic_vector(63 downto 0);

             -- EXE STAGE INTERFACE
             exe_syllable              : out std_logic_vector(63 downto 0); -- syllable to exe stage
             exe_operand_src           : out std_logic_vector(63 downto 0); -- SRC reg content
             exe_operand_dst           : out std_logic_vector(63 downto 0); -- DST reg content
             exe_immediate             : out std_logic_vector(31 downto 0); -- immediate in the instruction
             exe_opc                   : out std_logic_vector(1 downto 0);  -- execution stage opc 00=alu64, 01=alu32, 10= mem, 11= branch
             exe_dest_reg              : out std_logic_vector(3 downto 0);  -- exe stage destination register for writeback 
             exe_offset                : out std_logic_vector(15 downto 0);

             -- READ BUS FOR PREFETCH
             dbus_addr_read            : out std_logic_vector(63 downto 0);  -- data bus address read for memory prefetch

             opc_name                  : out string (1 to 5)


         );

end decode_stage;

architecture Behavioral of decode_stage is

    signal exe_syllable_s              : std_logic_vector(63 downto 0); -- syllable to exe stage
    signal exe_operand_src_s           : std_logic_vector(63 downto 0); -- SRC reg content
    signal exe_operand_dst_s           : std_logic_vector(63 downto 0); -- DST reg content
    signal exe_immediate_s             : std_logic_vector(31 downto 0); -- immediate in the instruction
    signal exe_opc_s                   : std_logic_vector(1 downto 0);  
    signal exe_dest_reg_s              : std_logic_vector(3 downto 0);  -- exe stage destination register for writeback 
    signal exe_offset_s                : std_logic_vector(15 downto 0);
    signal src_reg_add_out_s             :  std_logic_vector(3 downto 0);   -- to exe stage
    signal dst_reg_add_out_s             :  std_logic_vector(3 downto 0);   -- to exe stage

begin

    --	dbus_addr_read  <= src_reg_cont + (x"0000000000" & syllable(31 downto 16)); -- always prefetch
    dbus_addr_read <= cont_wb_0 + (x"0000000000" & syllable(31 downto 16)) when (wb_wrt_en_0 = '1') and (src_reg_add_in = addr_wb_0) else
                      cont_wb_1 + (x"0000000000" & syllable(31 downto 16)) when (wb_wrt_en_1 = '1') and (src_reg_add_in = addr_wb_1) else
                      cont_wb_2 + (x"0000000000" & syllable(31 downto 16)) when (wb_wrt_en_2 = '1') and (src_reg_add_in = addr_wb_2) else
                      cont_wb_3 + (x"0000000000" & syllable(31 downto 16)) when (wb_wrt_en_3 = '1') and (src_reg_add_in = addr_wb_3) else
                      src_reg_cont + (x"0000000000" & syllable(31 downto 16));

    decode_output: process(clk)
    begin

        if rising_edge(clk) then

            if (reset = '1') or (decode_flush = '1') then

                exe_operand_src <= (others => '0'); 
                exe_operand_dst <= (others => '0'); 
                exe_immediate   <= (others => '0');
                exe_opc         <= (others => '0');
                exe_dest_reg    <= (others => '0');
                exe_offset      <= (others => '0');
                exe_syllable    <= (others => '0');
                src_reg_add_out <= (others => '0');
                dst_reg_add_out <= (others => '0');

            else 

                    -- IMPLEMENT CROSSBAR
                if (wb_wrt_en_0 = '1') and (src_reg_add_in = addr_wb_0) then
                    exe_operand_src <= cont_wb_0;
                elsif (wb_wrt_en_1 = '1') and (src_reg_add_in = addr_wb_1) then
                    exe_operand_src <= cont_wb_1;
                elsif (wb_wrt_en_2 = '1') and (src_reg_add_in = addr_wb_2) then
                    exe_operand_src <= cont_wb_2;
                elsif (wb_wrt_en_3 = '1') and (src_reg_add_in = addr_wb_3) then
                    exe_operand_src <= cont_wb_3;
                elsif (hf_we = '1') and (src_reg_add_in = x"0") then
                    exe_operand_src <= hf_result;
                else
                    exe_operand_src <= src_reg_cont;
                end if;

                if (wb_wrt_en_0 = '1') and (dst_reg_add_in = addr_wb_0) then
                    exe_operand_dst <= cont_wb_0;
                elsif (wb_wrt_en_1 = '1') and (dst_reg_add_in = addr_wb_1) then
                    exe_operand_dst <= cont_wb_1;
                elsif (wb_wrt_en_2 = '1') and (dst_reg_add_in = addr_wb_2) then
                    exe_operand_dst <= cont_wb_2;
                elsif (wb_wrt_en_3 = '1') and (dst_reg_add_in = addr_wb_3) then
                    exe_operand_dst <= cont_wb_3;
                elsif (hf_we = '1') and (dst_reg_add_in = x"0") then
                    exe_operand_dst <= hf_result;
                else
                    exe_operand_dst <= dst_reg_cont;
                end if;

                if (pc_idle = '0') then

                    exe_syllable    <= syllable;
                    exe_immediate   <= syllable(63 downto 32);
                    exe_offset      <= syllable(31 downto 16);
                    exe_dest_reg    <= dst_reg_add_in; 

                    src_reg_add_out <= src_reg_add_in;
                    dst_reg_add_out <= dst_reg_add_in;

                    -- SELECTING PROPER EXECUTION UNIT
                    if std_match(syllable(7 downto 0), ALU64) then

                        exe_opc <= "00";

                    elsif std_match(syllable(7 downto 0), ALU32) then

                        exe_opc <= "01";

                    elsif std_match(syllable(7 downto 0), BRCH) then

                        exe_opc <= "11";

                    elsif std_match(syllable(7 downto 0), MEM) then

                        if std_match(syllable(7 downto 0), NOP_OPC) then

                            exe_opc <= "00";

                        else
                            exe_opc <= "10";

                        end if;
                    end if;


                end if;
            end if;
        end if;
    end process;
end Behavioral;

