library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity HF_bpf_redirect_map is

	-- ID: 51
	Port ( 
		     done   : out std_logic;
		     clk : in std_logic;
		     start : in std_logic;

		     -- PMP Interface
		     R0              : out std_logic_vector(63 downto 0);
		     write_enable_R0 : out std_logic;

		     R1: in std_logic_vector(63 downto 0);
		     R2: in std_logic_vector(63 downto 0);
		     R3: in std_logic_vector(63 downto 0);
		     R4: in std_logic_vector(63 downto 0);
		     R5: in std_logic_vector(63 downto 0);
		     ID: in std_logic_vector(7 downto 0);

		     --ACTIVE PACKET SELECTOR INTERFACE
		     output_ifindex 	: out std_logic_vector(3 downto 0);
		     bpf_redirect_wrt 	: out std_logic;

		     -- MAPS BUS INTERFACE
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

end HF_bpf_redirect_map;

architecture Behavioral of HF_bpf_redirect_map is

begin


	mb_key <= R2;
	mb_map_index <= R1(3 downto 0); 

	process (clk)
	begin
		if rising_edge (clk) then 
			mb_wrt_en <= '0';
			output_ifindex <= (others => '0');
			bpf_redirect_wrt <= '0';
			done <= '0';
			R0 <= (others => '0');
			write_enable_R0 <= '0';
			mb_ht_lookup   <= '0';       
			mb_ht_update   <= '0';       
			mb_ht_remove   <= '0'; 
			mb_value_to_map <= (others => '0');      

			if (start = '1') then 
				output_ifindex <= mb_value_from_map(3 downto 0);
				bpf_redirect_wrt <= '1';
				done <= '1';
				R0 <= x"0000000000000004";
				write_enable_R0 <= '1';
			end if;

		end if;
	end process;

end Behavioral;
