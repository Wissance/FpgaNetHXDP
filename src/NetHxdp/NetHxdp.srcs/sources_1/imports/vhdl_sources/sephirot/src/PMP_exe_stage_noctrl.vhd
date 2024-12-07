library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common_pkg.all;

entity exe_stage_noctrl is
	generic (
			QUEUES_PAGE : std_logic_vector(3 downto 0) := x"0"
		);

	Port (

		     clk               : in std_logic;
		     reset             : in std_logic;
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

		     pc_idle          : in std_logic

	     );

end exe_stage_noctrl;

architecture Behavioral of exe_stage_noctrl is

	signal opc : std_logic_vector(7 downto 0) := (others => ('0'));
	signal opc_string : string(1 to 5) := "_____";

	signal exe_result_s : std_logic_vector(63 downto 0);
	signal exe_operand_dst_s : std_logic_vector(63 downto 0);
	signal exe_operand_src_s : std_logic_vector(63 downto 0);
	signal w_e_wb_s : std_logic;
	signal w_e_mem_s : std_logic;
	signal wb_reg_add_s : std_logic_vector(3 downto 0);
	signal mem_data_out_s : std_logic_vector(63 downto 0);


begin


	EXECUTE: process(clk)
	begin

		if rising_edge (clk) then

			opc <= syllable(7 downto 0);
			exe_result_s <= (others => '0');
			mem_data_out_s      <= (others => '0');
			mem_wrt_mask    <= (others => '0');
			mem_wrt_addr <= exe_operand_dst_s + exe_offset;
			w_e_mem_s <= '0';
			w_e_wb_s <= '0';


			if std_match(syllable(7 downto 0), ALU64) then
				case syllable(7 downto 0) is

					-- ALU 64
					when NOP_OPC => --null;
						exe_result_s <= (others => '0');
						wb_reg_add_s <= (others => '0');
						opc_string <= "_____";
						w_e_mem_s <= '0';
						w_e_wb_s <= '0';
						mem_data_out_s      <= (others => '0');
						mem_wrt_mask    <= (others => '0');


					when ADDI_OPC => --0x07

						exe_result_s <= exe_operand_dst_s + (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ADDI";

					when ADD_OPC =>

						exe_result_s <= exe_operand_dst_s + exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__ADD";

					when SUBI_OPC =>

						exe_result_s <= exe_operand_dst_s - (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_SUBI";

					when SUB_OPC =>

						exe_result_s <= exe_operand_dst_s - exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__SUB";

					when ORI_OPC =>

						exe_result_s <= exe_operand_dst_s or  x"00000000" & exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__ORI";

					when OR_OPC =>

						exe_result_s <= exe_operand_dst_s or exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "___OR";

					when ANDI_OPC =>

						exe_result_s <= exe_operand_dst_s and  x"00000000" & exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ANDI";

					when AND_OPC =>

						exe_result_s <= exe_operand_dst_s and exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__AND";

					when LSHI_OPC =>

						exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_LSHI";

					when LSH_OPC =>

						exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__LSH";

					when RSHI_OPC =>

						exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_RSHI";

					when RSH_OPC =>

						exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__RSH";

					when NEG_OPC =>

						exe_result_s <= std_logic_vector(-signed(exe_operand_dst_s));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__NEG";

					when XORI_OPC =>

						exe_result_s <= exe_operand_dst_s xor x"00000000" & exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_XORI";

					when XOR_OPC =>

						exe_result_s <= exe_operand_dst_s xor exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__XOR";

					when MOVI_OPC =>

						exe_result_s <= x"00000000" & exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_MOVI";

					when MOV_OPC =>

						exe_result_s <= exe_operand_src_s;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__MOV";

					when ARSHI_OPC =>

						exe_result_s <= std_logic_vector(shift_right(signed(exe_operand_dst_s),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "ARSHI";

					when ARSH_OPC =>
						exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_dst_s),to_integer(unsigned(exe_operand_src_s))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ARSH";

					-- COMPRESSED 64 INSTRUCTIONS
					when SUM_CMP_OPC =>
						exe_result_s <= exe_operand_src_s + (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "SUMCM";

					when SUB_CMP_OPC =>
						exe_result_s <= exe_operand_src_s - (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "SUBCM";

					when OR_CMP_OPC =>
						exe_result_s <= exe_operand_src_s or (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "ORCMP";

					when AND_CMP_OPC =>
						exe_result_s <= exe_operand_src_s and (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "ANDCM";

					when LSH_CMP_OPC =>
						exe_result_s <= std_logic_vector(shift_left(unsigned(exe_operand_src_s),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LSHCM";

					when RSH_CMP_OPC =>
						exe_result_s <= std_logic_vector(shift_right(unsigned(exe_operand_src_s),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "RSHCM";

					when XOR_CMP_OPC =>
						exe_result_s <= exe_operand_src_s xor (x"00000000" & exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "XORCM";
					when others =>

						exe_result_s <= (others => '0');
						wb_reg_add_s <= (others => '0');
						opc_string <= "_____";
						mem_data_out_s      <= (others => '0');
						mem_wrt_mask    <= (others => '0');
						w_e_mem_s <= '0';
						w_e_wb_s <= '0';
				end case;


			elsif std_match(syllable(7 downto 0), ALU32) then
				-- ALU 32
				case syllable(7 downto 0) is
					when ADDI32_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) + (exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ADDI";

					when ADD32_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) + exe_operand_src_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__ADD";

					when SUBI32_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) - (exe_immediate);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_SUBI";

					when SUB32_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) - exe_operand_src_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__SUB";

					when ORI32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) or exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__ORI";

					when OR32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) or exe_operand_src_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "___OR";

					when ANDI32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) and exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ANDI";

					when AND32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) and exe_operand_src_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__AND";

					when LSHI32_OPC =>

						exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)), to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_LSHI";

					when LSH32_OPC =>

						exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__LSH";

					when RSHI32_OPC =>
						exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_RSHI";

					when RSH32_OPC =>
						exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__RSH";

					when NEG32_OPC =>

						exe_result_s(31 downto 0) <= std_logic_vector(-signed(exe_operand_dst_s(31 downto 0)));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__NEG";

					when XORI32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) xor exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_XORI";

					when XOR32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0) xor exe_operand_src_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__XOR";

					when MOVI32_OPC =>

						exe_result_s(31 downto 0) <= exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_MOVI";

					when MOV32_OPC =>

						exe_result_s(31 downto 0) <= exe_operand_dst_s(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "__MOV";

					when ARSHI32_OPC =>

						exe_result_s(31 downto 0) <= std_logic_vector(shift_right(signed(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "ARSHI";

					when ARSH32_OPC =>

						exe_result_s(31 downto 0) <= std_logic_vector(shift_right(signed(exe_operand_dst_s(31 downto 0)),to_integer(unsigned(exe_operand_src_s(31 downto 0)))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "_ARSH";

					-- COMPRESSED 32 INSTRUCTIONS
					when SUM32_CMP_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) + exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "SUMCM";

					when SUB32_CMP_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) - exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "SUBCM";

					when LSH32_CMP_OPC =>
						exe_result_s(31 downto 0) <= std_logic_vector(shift_left(unsigned(exe_operand_src_s(31 downto 0)),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LSHCM";

					when RSH32_CMP_OPC =>
						exe_result_s(31 downto 0) <= std_logic_vector(shift_right(unsigned(exe_operand_src_s(31 downto 0)),to_integer(unsigned(exe_immediate))));
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "RSHCM";

					when XOR32_CMP_OPC =>
						exe_result_s(31 downto 0) <= exe_operand_src_s(31 downto 0) xor  exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "XORCM";
					when others =>

						exe_result_s <= (others => '0');
						wb_reg_add_s <= (others => '0');
						opc_string <= "_____";
						mem_data_out_s      <= (others => '0');
						mem_wrt_mask    <= (others => '0');
						w_e_mem_s <= '0';
						w_e_wb_s <= '0';

				end case;

			elsif std_match(syllable(7 downto 0), MEM) then
				case syllable(7 downto 0) is
					-- MEM
					when LDDW_OPC =>

						exe_result_s <= x"00000000" & exe_immediate;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDDW_";

					when LDXW_OPC =>

						exe_result_s(31 downto 0) <= mem_data_in(31 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDXW_";

					when LDXH_OPC =>

						exe_result_s(15 downto 0) <= mem_data_in(15 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDXHW";

					when LDXB_OPC => --0x71

						exe_result_s(7 downto 0) <= mem_data_in(7 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDXB_";

					when LDXDW_OPC =>

						exe_result_s <= mem_data_in;
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDXDW";

					when LDX48_OPC =>

						exe_result_s <= x"0000" & mem_data_in(47 downto 0);
						wb_reg_add_s <= exe_address_dst;
						w_e_wb_s <= '1';
						opc_string <= "LDX48";

					-- STORE
					when ST48_OPC   =>

						opc_string <= "ST48_";
						mem_data_out_s(47 downto 0) <= mem_data_in(47 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"0000ffffffffffff";

					when STW_OPC   =>

						opc_string <= "STW__";
						mem_data_out_s(31 downto 0) <= mem_data_in(31 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"00000000ffffffff";

					when STH_OPC   =>

						opc_string <= "_STH_";
						mem_data_out_s(15 downto 0) <= mem_data_in(15 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"000000000000ffff";

					when STB_OPC   =>

						opc_string <= "_STB_";
						mem_data_out_s(7 downto 0) <= mem_data_in(7 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"00000000000000ff";

					when STDW_OPC  =>

						opc_string <= "_STDW";
						mem_data_out_s <= mem_data_in ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"ffffffffffffffff";

					when STX48_OPC   =>

						opc_string <= "STX48";
						mem_data_out_s(47 downto 0) <= mem_data_in(47 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"0000ffffffffffff";

					when STXW_OPC  =>

						opc_string <= "_STXW";
						mem_data_out_s(31 downto 0) <= mem_data_in(31 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"00000000ffffffff";

					when STXH_OPC  =>

						opc_string <= "STXH_";
						mem_data_out_s(15 downto 0) <= mem_data_in(15 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"000000000000ffff";


					when STXB_OPC  =>

						opc_string <= "_STXB";
						mem_data_out_s(7 downto 0) <= mem_data_in(7 downto 0) ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"00000000000000ff";


					when STXDW_OPC =>

						opc_string <= "STXDW"; --7b
						mem_data_out_s <= mem_data_in ;
						w_e_mem_s <= '1';
						mem_wrt_mask<= x"ffffffffffffffff";
					when others =>

						exe_result_s <= (others => '0');
						wb_reg_add_s <= (others => '0');
						opc_string <= "_____";
						mem_data_out_s      <= (others => '0');
						mem_wrt_mask    <= (others => '0');
						w_e_mem_s <= '0';
						w_e_wb_s <= '0';

				end case;

			end if;

		end if;

	end process;

	FORWARD: process (all)
	begin

		if (exe_address_src = wb_reg_add_s) then

			exe_operand_src_s <= exe_result_s;
			report("SRC FORWARDED");

		else

			exe_operand_src_s <= exe_operand_src;

		end if;

		if (exe_address_dst = wb_reg_add_s) then

			exe_operand_dst_s <= exe_result_s;
			report("DST FORWARDED");

		else

			exe_operand_dst_s <= exe_operand_dst;

		end if;

	end process;


	exe_result <= exe_result_s;

	wb_reg_add <= wb_reg_add_s;

	mem_wrt_en <= w_e_mem_s when pc_idle = '0' else
		      '0';

	w_e_wb <= w_e_wb_s when pc_idle = '0' else
		  '0';

	mem_data_out <= mem_data_out_s xor (mem_data_in) when (mem_wrt_addr(63 downto 60) = QUEUES_PAGE) else
			mem_data_out_s;

end Behavioral;
