library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ID: 0, 1 ,2

entity HF_map_ele is

	Port ( 
		     clk : in std_logic;
		     done   : out std_logic;
		     start : in std_logic;

		     R0              : out std_logic_vector(63 downto 0);
		     write_enable_R0 : out std_logic;

		     R1: in std_logic_vector(63 downto 0);
		     R2: in std_logic_vector(63 downto 0);
		     R3: in std_logic_vector(63 downto 0);
		     R4: in std_logic_vector(63 downto 0);
		     R5: in std_logic_vector(63 downto 0);
		     ID: in std_logic_vector(7 downto 0);

		     -- MAPS BUS INTERFACE

		     -- ARRAY
		     mb_map_index          : out std_logic_vector(3 downto 0);
		     mb_key                : out std_logic_vector(63 downto 0);
		     mb_value_to_map       : out std_logic_vector(63 downto 0);
		     mb_value_from_map     : in std_logic_vector(63 downto 0);
		     mb_wrt_en             : out std_logic;
		     -- HT
		     mb_ht_match           : in std_logic;
		     mb_ht_lookup          : out std_logic;
		     mb_ht_update          : out std_logic;
		     mb_ht_remove          : out std_logic


	     );

end HF_map_ele;

architecture Behavioral of HF_map_ele is

signal ID_s : std_logic_vector(7 downto 0);

begin

	mb_map_index <= R1(3 downto 0);
	mb_key <= R2;
	mb_value_to_map <= R3;

	process (clk)
	begin

		if rising_edge (clk) then 

			done           <= '0';      
			R0             <= (others => '0');      
			write_enable_R0 <= '0';      
			mb_wrt_en      <= '0';       
			mb_ht_lookup   <= '0';       
			mb_ht_update   <= '0';       
			mb_ht_remove   <= '0';
			
			if (start = '1') then
			ID_s <= ID;
				case ID is

					when x"00" => -- MAP UPDATE ELEMENT

						--mb_key <`= key;
						mb_value_to_map <= R3;
						mb_ht_update <= '1';
						mb_wrt_en <= '1';

						R0 <= (others => '0');
						write_enable_R0 <= '1';
						done <= '1';

					when x"01" => -- MAP LOOKUP ELEMENT

						mb_ht_lookup <= '1';

						R0 <= mb_value_from_map;
						write_enable_R0 <= '1';
						done <= '1';

					when x"02" => -- MAP DELETE ELEMENT

						mb_ht_remove <= '1';

						R0 <= (others => '0');
						write_enable_R0 <= '1';
						done <= '1';

					when others =>

						done           <= '0';      
						R0             <= (others => '0');      
						write_enable_R0 <= '0';      
						mb_value_to_map  <= (others => '0');    
						mb_wrt_en      <= '0';       
						mb_ht_lookup   <= '0';       
						mb_ht_update   <= '0';       
						mb_ht_remove   <= '0';       

				end case;

			end if;

		end if;

	end process;

end Behavioral;
