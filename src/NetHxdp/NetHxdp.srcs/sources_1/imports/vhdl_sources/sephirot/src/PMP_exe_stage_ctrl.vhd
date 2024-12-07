library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common_pkg.all;

entity exe_stage_complete is

    generic (
                QUEUES_PAGE : std_logic_vector(3 downto 0) := x"0"
            );
    Port (

             clk               : in std_logic;
             pipeline_flush             : in std_logic;
             -- HF RESULT BROADCAST
             hf_result : in std_logic_vector(63 downto 0);
             hf_we : in std_logic;
             syllable          : in std_logic_vector(63 downto 0);

             exe_operand_src   : in std_logic_vector(63 downto 0); -- SRC reg content
             exe_operand_dst   : in std_logic_vector(63 downto 0); -- DST reg content
             exe_address_src   : in std_logic_vector(3 downto 0); -- SRC reg address
             exe_address_dst   : in std_logic_vector(3 downto 0); -- DST reg address
             exe_immediate     : in std_logic_vector(31 downto 0); -- exe_immediate in the instruction
             exe_opc           : in std_logic_vector(1 downto 0);  -- execution stage opc 100=alu64, 001=alu32, 010= mem, 011= branch
             exe_offset        : in std_logic_vector(15 downto 0); -- exe_offset inside instruction

             -- GPR REGISTERS INTERFACE
             exe_result        : out std_logic_vector(63 downto 0);  -- result from EXE stage for lane forwarding and writeback
             w_e_wb            : out std_logic;
             wb_reg_add        : out std_logic_vector(3 downto 0);   -- current register address in writeback from exe stage   
                                                                     -- MEMORY INTERFACE
             mem_data_in      : in std_logic_vector (63 downto 0);
             mem_data_out     : out std_logic_vector (63 downto 0);
             mem_wrt_addr     : out std_logic_vector (63 downto 0);
             mem_wrt_en       : out std_logic;
             mem_wrt_mask     : out std_logic_vector(63 downto 0);

             pc_idle          : in std_logic;
             -- PC INTERFACE
             PC_addr          : out std_logic_vector(15 downto 0); --address to add to PC
             PC_add           : out std_logic;
             PC_stop          : out std_logic;
             PC_load          : out std_logic;
             branch_here    : out std_logic;
             exit_detected      : out std_logic;
             helper_function_id : out std_logic_vector(7 downto 0)


         );

end exe_stage_complete;

architecture Behavioral of exe_stage_complete is

    signal opc : std_logic_vector(7 downto 0) := (others => ('0'));
    signal opc_string : string(1 to 5) := "_____";
    signal syllable_out : std_logic_vector(63 downto 0);
    signal syllable_s : std_logic_vector(63 downto 0);
    signal exe_address_src_s   : std_logic_vector(3 downto 0); -- SRC reg address
    signal exe_address_src_ss   : std_logic_vector(3 downto 0); -- SRC reg address
    signal exe_address_dst_s   : std_logic_vector(3 downto 0); -- DST reg address
    signal exe_address_dst_ss   : std_logic_vector(3 downto 0); -- DST reg address
    signal exe_immediate_s     : std_logic_vector(31 downto 0); -- exe_immediate in the instruction
    signal exe_immediate_ss     : std_logic_vector(31 downto 0); -- exe_immediate in the instruction
    signal exe_offset_s        : std_logic_vector(15 downto 0); -- exe_offset inside instruction
    signal exe_offset_ss        : std_logic_vector(15 downto 0); -- exe_offset inside instruction

    signal exe_result_s : std_logic_vector(63 downto 0);
    signal exe_operand_dst_s : std_logic_vector(63 downto 0);
    signal exe_operand_src_s : std_logic_vector(63 downto 0);
    signal w_e_wb_s : std_logic;
    signal w_e_mem_s : std_logic;
    signal wb_reg_add_s : std_logic_vector(3 downto 0);
    signal mem_data_out_s : std_logic_vector(63 downto 0);
    signal mem_data_in_mskd : std_logic_vector(63 downto 0);
    signal branch_here_s : std_logic;

begin

    syllable_s <= syllable when pc_idle ='0' else
                  syllable_out;

    exe_address_src_ss <= exe_address_src when pc_idle = '0' else
                          exe_address_src_s;

    exe_address_dst_ss <= exe_address_dst when pc_idle = '0' else
                          exe_address_dst_s;
    
    exe_immediate_ss <= exe_immediate when pc_idle = '0' else
                          exe_immediate_s;
    
    exe_offset_ss <= exe_offset when pc_idle = '0' else
                          exe_offset_s;

    EXECUTE: process(clk)
    begin

        if rising_edge (clk) then


            syllable_out <= syllable;
            exe_address_src_s <= exe_address_src;
            exe_address_dst_s <= exe_address_dst;
            exe_immediate_s <= exe_immediate;
            exe_offset_s <= exe_offset;
            opc <= syllable(7 downto 0);
            exe_result_s <= (others => '0');
            mem_data_out_s      <= (others => '0');
            mem_wrt_mask    <= (others => '0');
            mem_wrt_addr <= exe_operand_dst_s + exe_offset_ss;
            mem_data_in_mskd <= (others => '0');
            wb_reg_add_s <= exe_address_dst_ss;
            PC_addr <= exe_offset_ss-3;
            w_e_mem_s <= '0';
            w_e_wb_s <= '0';
            branch_here_s <= '0';
            opc_string <= "_____";
            PC_add <= '0';
            PC_stop <= '0';
            PC_load <= '0';
            exit_detected <= '0';
            helper_function_id <= (others => '1');

            if ((branch_here_s = '0') and (pipeline_flush = '0')) or (pc_idle = '1') then
                if std_match(syllable_s(7 downto 0), ALU64) then
                    case syllable_s(7 downto 0) is

                                              -- ALU 64
                        when NOP_OPC => --null;
                            opc_string <= "__NOP";


                        when ADDI_OPC => --0x07

                            exe_result_s <= exe_operand_dst_s + (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "_ADDI";

                        when ADD_OPC =>

                            exe_result_s <= exe_operand_dst_s + exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "__ADD";

                        when SUBI_OPC =>

                            exe_result_s <= exe_operand_dst_s - (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "_SUBI";

                        when SUB_OPC =>

                            exe_result_s <= exe_operand_dst_s - exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "__SUB";

                        when ORI_OPC =>

                            exe_result_s <= exe_operand_dst_s or  x"00000000" & exe_immediate_ss;
                            w_e_wb_s <= '1';
                            opc_string <= "__ORI";

                        when OR_OPC =>

                            exe_result_s <= exe_operand_dst_s or exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "___OR";

                        when ANDI_OPC =>

                            exe_result_s <= exe_operand_dst_s and  x"00000000" & exe_immediate_ss;
                            w_e_wb_s <= '1';
                            opc_string <= "_ANDI";

                        when AND_OPC =>

                            exe_result_s <= exe_operand_dst_s and exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "__AND";

                        when LSHI_OPC =>

                            exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_immediate_ss))));
                            w_e_wb_s <= '1';
                            opc_string <= "_LSHI";

                        when LSH_OPC =>

                            exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
                            w_e_wb_s <= '1';
                            opc_string <= "__LSH";

                        when RSHI_OPC =>

                            exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_immediate_ss))));
                            w_e_wb_s <= '1';
                            opc_string <= "_RSHI";

                        when RSH_OPC =>

                            exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
                            w_e_wb_s <= '1';
                            opc_string <= "__RSH";

                        when NEG_OPC =>

                            exe_result_s <= std_logic_vector(-signed(exe_operand_dst_s));
                            w_e_wb_s <= '1';
                            opc_string <= "__NEG";

                        when XORI_OPC =>

                            exe_result_s <= exe_operand_dst_s xor x"00000000" & exe_immediate_ss;
                            w_e_wb_s <= '1';
                            opc_string <= "_XORI";

                        when XOR_OPC =>

                            exe_result_s <= exe_operand_dst_s xor exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "__XOR";

                        when MOVI_OPC =>

                            exe_result_s <= x"00000000" & exe_immediate_ss;
                            w_e_wb_s <= '1';
                            opc_string <= "_MOVI";

                        when MOV_OPC =>

                            exe_result_s <= exe_operand_src_s;
                            w_e_wb_s <= '1';
                            opc_string <= "__MOV";

                        when ARSHI_OPC =>

                            exe_result_s <= std_logic_vector(shift_right(signed(exe_operand_dst_s),to_integer(unsigned(exe_immediate_ss))));
                            w_e_wb_s <= '1';
                            opc_string <= "ARSHI";

                        when ARSH_OPC =>
                            exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
                            w_e_wb_s <= '1';
                            opc_string <= "_ARSH";

                                              -- COMPRESSED 64 INSTRUCTIONS
                        when SUM_CMP_OPC =>
                            exe_result_s <= exe_operand_src_s + (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "SUMCM";

                        when SUB_CMP_OPC =>
                            exe_result_s <= exe_operand_src_s - (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "SUBCM";

                        when OR_CMP_OPC =>
                            exe_result_s <= exe_operand_src_s or (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "ORCMP";

                        when AND_CMP_OPC =>
                            exe_result_s <= exe_operand_src_s and (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "ANDCM";

                        when LSH_CMP_OPC =>
                            exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_src_s),to_integer(unsigned(exe_immediate_ss))));
                            w_e_wb_s <= '1';
                            opc_string <= "LSHCM";

                        when RSH_CMP_OPC =>
                            exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_src_s),to_integer(unsigned(exe_immediate_ss))));
                            w_e_wb_s <= '1';
                            opc_string <= "RSHCM";

                        when XOR_CMP_OPC =>
                            exe_result_s <= exe_operand_src_s xor (x"00000000" & exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "XORCM";
                        when others =>
                            null;

                    end case;


                elsif std_match(syllable_s(7 downto 0), ALU32) then
                                          -- ALU 32
                    case syllable_s(7 downto 0) is
                        when ADDI32_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) + (exe_immediate_ss);
                            w_e_wb_s <= '1';
                            opc_string <= "_ADDI";

                        when ADD32_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) + exe_operand_src_s(31 downto 0);
                            w_e_wb_s <= '1';
                            opc_string <= "__ADD";

                        when SUBI32_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) - (exe_immediate_ss);

                            w_e_wb_s <= '1';
                            opc_string <= "_SUBI";

                        when SUB32_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) - exe_operand_src_s(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "__SUB";

                        when ORI32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) or exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "__ORI";

                        when OR32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) or exe_operand_src_s(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "___OR";

                        when ANDI32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) and exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "_ANDI";

                        when AND32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) and exe_operand_src_s(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "__AND";

                        when LSHI32_OPC =>

                            exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)), to_integer(unsigned(exe_immediate_ss))));

                            w_e_wb_s <= '1';
                            opc_string <= "_LSHI";

                        when LSH32_OPC =>

                            exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));

                            w_e_wb_s <= '1';
                            opc_string <= "__LSH";

                        when RSHI32_OPC =>
                            exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_immediate_ss))));

                            w_e_wb_s <= '1';
                            opc_string <= "_RSHI";

                        when RSH32_OPC =>
                            exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));

                            w_e_wb_s <= '1';
                            opc_string <= "__RSH";

                        when NEG32_OPC =>

                            exe_result_s(31 downto 0) <= std_logic_vector(-signed(exe_operand_dst_s(31 downto 0)));

                            w_e_wb_s <= '1';
                            opc_string <= "__NEG";

                        when XORI32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) xor exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "_XORI";

                        when XOR32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) xor exe_operand_src_s(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "__XOR";

                        when MOVI32_OPC =>

                            exe_result_s(31 downto 0) <= exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "_MOVI";

                        when MOV32_OPC =>

                            exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "__MOV";

                        when ARSHI32_OPC =>

                            exe_result_s(31 downto 0) <= std_logic_vector(shift_right(signed(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_immediate_ss))));

                            w_e_wb_s <= '1';
                            opc_string <= "ARSHI";

                        when ARSH32_OPC =>

                            exe_result_s(31 downto 0) <= std_logic_vector(shift_right(signed(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));

                            w_e_wb_s <= '1';
                            opc_string <= "_ARSH";

                                              -- COMPRESSED 32 INSTRUCTIONS
                        when SUM32_CMP_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) + exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "SUMCM";

                        when SUB32_CMP_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) - exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "SUBCM";

                        when LSH32_CMP_OPC =>
                            exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_src_s(31 downto 0)),to_integer(unsigned(exe_immediate_ss))));

                            w_e_wb_s <= '1';
                            opc_string <= "LSHCM";

                        when RSH32_CMP_OPC =>
                            exe_result_s(31 downto 0) <= std_logic_vector(shift_right(unsigned(exe_operand_src_s(31 downto 0)),to_integer(unsigned(exe_immediate_ss))));

                            w_e_wb_s <= '1';
                            opc_string <= "RSHCM";

                        when XOR32_CMP_OPC =>
                            exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) xor  exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "XORCM";

                                              -- BYTESWAP
                        when LE_OPC =>

                            w_e_wb_s <= '1';
                            opc_string <= "LE___";

                            if (exe_immediate_ss = x"10") then
                                exe_result_s(15 downto 0) <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8);

                            elsif (exe_immediate_ss = x"20") then
                                exe_result_s(31 downto 0) <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8) & exe_operand_dst_s(23 downto 16) & exe_operand_dst_s(31 downto 24);

                            elsif (exe_immediate_ss = x"40") then 
                                exe_result_s <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8) & exe_operand_dst_s(23 downto 16) & exe_operand_dst_s(31 downto 24)  & exe_operand_dst_s(47 downto 32) & exe_operand_dst_s(55 downto 48) & exe_operand_dst_s(63 downto 56);
                            else 
                                exe_result_s <= (others => '0');

                            end if;

                        when BE_OPC =>

                            w_e_wb_s <= '1';
                            opc_string <= "BE___";

                            if (exe_immediate_ss = x"10") then
                                exe_result_s(15 downto 0) <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8);

                            elsif (exe_immediate_ss = x"20") then
                                exe_result_s(31 downto 0) <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8) & exe_operand_dst_s(23 downto 16) & exe_operand_dst_s(31 downto 24);

                            elsif (exe_immediate_ss = x"40") then 
                                exe_result_s <= exe_operand_dst_s(7 downto 0) & exe_operand_dst_s(15 downto 8) & exe_operand_dst_s(23 downto 16) & exe_operand_dst_s(31 downto 24)  & exe_operand_dst_s(47 downto 32) & exe_operand_dst_s(55 downto 48) & exe_operand_dst_s(63 downto 56);
                            else 
                                exe_result_s <= (others => '0');

                            end if;


                        when others =>
                            null;

                    end case;

                elsif std_match(syllable_s(7 downto 0), MEM) then
                    case syllable_s(7 downto 0) is
                                              -- MEM
                        when LDDW_OPC =>

                            exe_result_s <= x"00000000" & exe_immediate_ss;

                            w_e_wb_s <= '1';
                            opc_string <= "LDDW_";

                        when LDXW_OPC =>

                            exe_result_s(31 downto 0) <= mem_data_in(31 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "LDXW_";

                        when LDXH_OPC =>

                            exe_result_s(15 downto 0) <= mem_data_in(15 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "LDXHW";

                        when LDXB_OPC => --0x71

                            exe_result_s(7 downto 0) <= mem_data_in(7 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "LDXB_";

                        when LDXDW_OPC =>

                            exe_result_s <= mem_data_in;

                            w_e_wb_s <= '1';
                            opc_string <= "LDXDW";

                        when LDX48_OPC =>

                            exe_result_s <= x"0000" & mem_data_in(47 downto 0);

                            w_e_wb_s <= '1';
                            opc_string <= "LDX48";

                                              -- STORE
                        when ST48_OPC   =>

                            opc_string <= "ST48_";
                            mem_data_out_s(47 downto 0) <= exe_operand_src_s(47 downto 0) ;
                            mem_data_in_mskd(47 downto 0) <= mem_data_in(47 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"0000ffffffffffff";

                        when STW_OPC   =>

                            opc_string <= "STW__";
                            mem_data_out_s(31 downto 0) <= exe_operand_src_s(31 downto 0) ;
                            mem_data_in_mskd(31 downto 0) <= mem_data_in(31 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"00000000ffffffff";

                        when STH_OPC   =>

                            opc_string <= "_STH_";
                            mem_data_out_s(15 downto 0) <= exe_operand_src_s(15 downto 0) ;
                            mem_data_in_mskd(15 downto 0) <= mem_data_in(15 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"000000000000ffff";

                        when STB_OPC   =>

                            opc_string <= "_STB_";
                            mem_data_out_s(7 downto 0) <= exe_operand_src_s(7 downto 0) ;
                            mem_data_in_mskd(7 downto 0) <= mem_data_in(7 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"00000000000000ff";

                        when STDW_OPC  =>

                            opc_string <= "_STDW";
                            mem_data_out_s <= exe_operand_src_s ;
                            mem_data_in_mskd <= mem_data_in;
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"ffffffffffffffff";

                        when STX48_OPC   =>

                            opc_string <= "STX48";
                            mem_data_out_s(47 downto 0) <= exe_operand_src_s(47 downto 0) ;
                            mem_data_in_mskd(47 downto 0) <= mem_data_in(47 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"0000ffffffffffff";

                        when STXW_OPC  =>

                            opc_string <= "_STXW";
                            mem_data_out_s(31 downto 0) <= exe_operand_src_s(31 downto 0) ;
                            mem_data_in_mskd(31 downto 0) <= mem_data_in(31 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"00000000ffffffff";

                        when STXH_OPC  =>

                            opc_string <= "STXH_";
                            mem_data_out_s(15 downto 0) <= exe_operand_src_s(15 downto 0) ;
                            mem_data_in_mskd(15 downto 0) <= mem_data_in(15 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"000000000000ffff";


                        when STXB_OPC  =>

                            opc_string <= "_STXB";
                            mem_data_out_s(7 downto 0) <= exe_operand_src_s(7 downto 0) ;
                            mem_data_in_mskd(7 downto 0) <=  mem_data_in(7 downto 0);
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"00000000000000ff";


                        when STXDW_OPC =>

                            opc_string <= "STXDW"; --7b
                            mem_data_out_s <= exe_operand_src_s ;
                            mem_data_in_mskd <=  mem_data_in;
                            w_e_mem_s <= '1';
                            mem_wrt_mask<= x"ffffffffffffffff";
                        when others =>
                            null;

                    end case;

                elsif std_match(syllable_s(7 downto 0), BRCH) then
                                          -- CTRL
                    case syllable_s(7 downto 0) is

                        when JA_OPC =>
                            branch_here_s <= '1';

                            PC_add <= '1';
                            opc_string <= "___JA";

                        when JEQI_OPC =>
                            opc_string <= "_JEQI";
                            if (exe_operand_dst_s(31 downto 0) = exe_immediate_ss) then

                                branch_here_s <= '1';

                                PC_add <= '1';


                            end if;

                        when JEQ_OPC =>
                            opc_string <= "__JEQ";
                            if (exe_operand_dst_s = exe_operand_src) then

                                branch_here_s <= '1';

                                PC_add <= '1';



                            end if;

                        when JGTI_OPC =>
                            opc_string <= "_JGTI";
                            if (exe_operand_dst_s(31 downto 0) > exe_immediate_ss) then
                                branch_here_s <= '1';

                                PC_add <= '1';


                            end if;

                        when JGT_OPC => --2d
                            opc_string <= "JMPGT";
                            if (exe_operand_dst_s > exe_operand_src) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JGEI_OPC =>

                            opc_string <= "_JGEI";
                            if (exe_operand_dst_s(31 downto 0) >= exe_immediate_ss) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JGE_OPC =>
                            opc_string <= "__JGE";

                            if (exe_operand_dst_s >= exe_operand_src) then
                                branch_here_s <= '1';


                                PC_add <= '1';
                            end if;

                        when JLTI_OPC =>

                            opc_string <= "_JLTI";
                            if (exe_operand_dst_s(31 downto 0) < exe_immediate_ss) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JLT_OPC =>
                            opc_string <= "__JLT";
                            if (exe_operand_dst_s < exe_operand_src) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JLEI_OPC =>
                            opc_string <= "_JLEI";
                            if (exe_operand_dst_s(31 downto 0) <= exe_immediate_ss) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JLE_OPC =>
                            opc_string <= "__JLE";
                            if (exe_operand_dst_s <= exe_operand_src) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSETI_OPC =>
                            opc_string <= "JSETI";
                            if ((exe_operand_dst_s(31 downto 0) and exe_immediate_ss) /= x"00000000") then
                                branch_here_s <= '1';

                                PC_add <= '1';



                            end if;

                        when JSET_OPC =>
                            opc_string <= "_JSET";
                            if ((exe_operand_dst_s and exe_operand_src) /= x"00000000") then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JNEI_OPC =>
                            opc_string <= "_JNEI";
                            if (exe_operand_dst_s(31 downto 0) /= exe_immediate_ss) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JNE_OPC =>
                            opc_string <= "__JNE";
                            if (exe_operand_dst_s /= exe_operand_src) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSGTIS_OPC =>
                            opc_string <= "JSGTI";
                            if (signed(exe_operand_dst_s(31 downto 0)) > signed(exe_immediate_ss)) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JSGTS_OPC =>
                            opc_string <= "JSGTS";
                            if (signed(exe_operand_dst_s) > signed(exe_operand_src)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSGEIS_OPC =>
                            opc_string <= "JSGEI";
                            if (signed(exe_operand_dst_s(31 downto 0)) >= signed(exe_immediate_ss)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSGES_OPC =>
                            opc_string <= "JSGES";
                            if (signed(exe_operand_dst_s) >= signed(exe_operand_src)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSLTIS_OPC =>
                            opc_string <= "JSLTI";
                            if (signed(exe_operand_dst_s(31 downto 0)) < signed(exe_immediate_ss)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSLTS_OPC =>
                            opc_string <= "JSLTS";
                            if (signed(exe_operand_dst_s) < signed(exe_operand_src)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when JSLEIS_OPC =>
                            opc_string <= "JSLEI";
                            if (signed(exe_operand_dst_s(31 downto 0)) <= signed(exe_immediate_ss)) then
                                branch_here_s <= '1';


                                PC_add <= '1';



                            end if;

                        when JSLES_OPC =>
                            opc_string <= "JSLES";
                            if (signed(exe_operand_dst_s) <= signed(exe_operand_src)) then
                                branch_here_s <= '1';


                                PC_add <= '1';


                            end if;

                        when CALL_OPC =>

                            opc_string <= "_CALL";
                            PC_stop <= '1';
                            branch_here_s <= '1';

                            helper_function_id <= exe_immediate_ss(7 downto 0);


                        when EXIT_OPC =>

                            branch_here_s <= '1';
                            opc_string <= "EXIT_";
                            exit_detected <= '1';

                        when others =>
                            null;

                    end case;

                end if;
            end if;
        end if;

    end process;

    FORWARD: process (all)
    begin

        if (exe_address_src_ss = wb_reg_add_s)  and (w_e_wb_s = '1')then

            exe_operand_src_s <= exe_result_s;
            report("SRC FORWARDED");


        else

            exe_operand_src_s <= exe_operand_src;

        end if;

        if (exe_address_dst_ss = wb_reg_add_s) and (w_e_wb_s = '1')then

            exe_operand_dst_s <= exe_result_s;
            report("DST FORWARDED");

        else

            exe_operand_dst_s <= exe_operand_dst;

        end if;

        if (exe_address_src_ss = x"0") and (hf_we = '1') then

            exe_operand_src_s <= hf_result;
            report("SRC HF");

        end if;

        if (exe_address_dst_ss = x"0") and (hf_we = '1') then

            exe_operand_dst_s <= hf_result;
            report("DST HF");

        end if;

    end process;

    exe_result <= exe_result_s;

    wb_reg_add <= wb_reg_add_s;

    mem_wrt_en <= w_e_mem_s when pc_idle = '0' else
                  '0';

    w_e_wb <= w_e_wb_s when pc_idle = '0' else
              '0';

    mem_data_out <= mem_data_out_s  xor mem_data_in_mskd when (mem_wrt_addr(63 downto 60) < x"2") else
                    mem_data_out_s;

    branch_here <= branch_here_s;

end Behavioral;
