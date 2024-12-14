library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.marcux_pkg.all;

entity HM_configurator is

	generic (
			key_size        : integer := 64;
			value_size      : integer := 64;
			max_entries    	: integer := 64;
			map_index       : std_logic_vector(3 downto 0)
		);

	Port (
		     -- CONFIGURATION INTERFACE
		     type_select        : in std_logic_vector(3 downto 0);

		     -- BRAM INTERFACE
		     bmem_mb_address      : out std_logic_vector(7 downto 0); 
		     bmem_mb_data_in      : out std_logic_vector(127 downto 0); -- data to mem
		     bmem_mb_data_out     : in std_logic_vector(127 downto 0); -- data from mem
		     bmem_mb_wrt_en       : out std_logic;

		     -- MAPS BUS INTERFACE
		     mb_key                : in std_logic_vector(63 downto 0);
		     mb_value_in           : in std_logic_vector(63 downto 0);
		     mb_value_out          : out std_logic_vector(63 downto 0);
		     mb_wrt_en             : in std_logic;
		     mb_ht_lookup          : in std_logic;
		     mb_ht_remove          : in std_logic;
		     mb_ht_update          : in std_logic;
		     mb_ht_match           : out std_logic

	     );

end HM_configurator;

--------------MAP TYPE ENCODING--------------
-- x0  BPF_MAP_TYPE_HASH ???
-- x1  BPF_MAP_TYPE_ARRAY ???
-- x2  BPF_MAP_TYPE_PROG_ARRAY 
-- x3  BPF_MAP_TYPE_PERF_EVENT_ARRAY
-- x4  BPF_MAP_TYPE_PERCPU_HASH ???
-- x5  BPF_MAP_TYPE_PERCPU_ARRAY ???
-- x6  BPF_MAP_TYPE_STACK_TRACE
-- x7  BPF_MAP_TYPE_CGROUP_ARRAY 
-- x8  BPF_MAP_TYPE_LRU_HASH 
-- x9  BPF_MAP_TYPE_LRU_PERCPU_HASH
-- xA  BPF_MAP_TYPE_LPM_TRIE
----------------------------------------------

architecture Behavioral of HM_configurator is

	function jhash (i_vector : in std_logic_vector(63 downto 0))
	return std_logic_vector is
	begin

		return i_vector(63 downto 56) xor 
		i_vector(55 downto 48) xor
		i_vector(47 downto 40) xor
		i_vector(39 downto 32) xor
		i_vector(31 downto 24) xor
		i_vector(23 downto 16) xor
		i_vector(15 downto 8) xor
		i_vector(7  downto 0);
	end;


	signal ht_out_count_item_s  :  std_logic_vector(31 downto 0);
	signal padding : std_logic_vector(key_size -1 downto 0) := (others => '0');
	signal padding_256 : std_logic_vector((7-log_2(max_entries)) downto 0) := (others => '0');

begin

	process (all)
	begin

		bmem_mb_address     <= (others => '0'); 
		bmem_mb_data_in     <= (others => '0'); 
		bmem_mb_wrt_en      <= '0'; 

		mb_value_out        <= (others => '0'); 
		mb_value_out(63 downto 60)   <= x"3" ; 
		mb_ht_match <= '0';
		bmem_mb_wrt_en <= '0';

		case type_select is

			when x"0" =>  -- BPF_MAP_TYPE_HASH

				bmem_mb_address     <= jhash(mb_key); 
				bmem_mb_data_in((key_size+value_size)-1 downto 0)     <= mb_key(key_size -1 downto 0) & mb_value_in(value_size -1 downto 0);
				--				mb_value_out(value_size -1 downto 0)    <= bmem_mb_data_out(value_size-1 downto 0);
				mb_value_out(11 downto 0) <= map_index & jhash(mb_key);

				-- HT LOOKUP ALWAYS
				if (bmem_mb_data_out(value_size+key_size -1 downto value_size) = mb_key) then
					mb_ht_match <= '1';
				else
					mb_ht_match <= '0';
				end if;

				-- HT REMOVE
				if (mb_ht_remove ='1') then
					bmem_mb_data_in   <= (others => '0');
					bmem_mb_wrt_en <= '1';
				end if;

				-- HT UPDATE
				if (mb_ht_update='1') then
					bmem_mb_wrt_en <= '1';
				end if;

			when x"1" =>  -- BPF_MAP_TYPE_ARRAY

				bmem_mb_address     <= mb_key(7 downto 0); 
				bmem_mb_data_in(value_size -1 downto 0)     <= mb_value_in(value_size-1 downto 0);
				--				mb_value_out(value_size -1 downto 0)         <= bmem_mb_data_out(value_size -1  downto 0);
				bmem_mb_wrt_en <= mb_wrt_en;
				mb_value_out(11 downto 0) <= map_index & mb_key(7 downto 0);

			when x"3" =>  -- BPF_MAP_TYPE_PERCPU_HASH
				bmem_mb_address     <= jhash(mb_key); 
				bmem_mb_data_in((key_size+value_size)-1 downto 0)     <= mb_key(key_size -1 downto 0) & mb_value_in(value_size -1 downto 0);
				--				mb_value_out(value_size -1 downto 0)         <= bmem_mb_data_out(value_size-1 downto 0);
				mb_value_out(11 downto 0) <= map_index & jhash(mb_key);

				-- HT LOOKUP ALWAYS
				if (bmem_mb_data_out(value_size+key_size -1 downto value_size) = mb_key) then
					mb_ht_match <= '1';
				else
					mb_ht_match <= '0';
				end if;

				-- HT REMOVE
				if (mb_ht_remove ='1') then
					bmem_mb_data_in   <= (others => '0');
					bmem_mb_wrt_en <= '1';
				end if;

				-- HT UPDATE
				if (mb_ht_update='1') then
					bmem_mb_wrt_en <= '1';
				end if;

			when x"4" =>  -- BPF_MAP_TYPE_PERCPU_ARRAY
				bmem_mb_address     <= mb_key(7 downto 0); 
				bmem_mb_data_in(value_size -1 downto 0)     <= mb_value_in(value_size -1 downto 0);
				--				mb_value_out(value_size -1 downto 0)        <= bmem_mb_data_out(value_size -1  downto 0);
				bmem_mb_wrt_en <= mb_wrt_en;
				mb_value_out(11 downto 0) <= map_index & mb_key(7 downto 0);



			when others =>

				bmem_mb_address     <= (others => '0'); 
				bmem_mb_data_in    <= (others => '0'); 
				bmem_mb_wrt_en      <= '0'; 
				mb_value_out      <= (others => '0'); 

		end case;
	end process;
end Behavioral;
