library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity HF_bpf_get_smp_processor_id is

	-- ID: 8
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
		     ID: in std_logic_vector(7 downto 0)

	     );

end HF_bpf_get_smp_processor_id;

architecture Behavioral of HF_bpf_get_smp_processor_id is

begin

	process (clk)
	begin
		if rising_edge (clk) then 
			done <= '0';
			R0 <= (others => '0');
			write_enable_R0 <= '0';

			if (start = '1') then 
				done <= '1';
				R0 <= x"0000000000000000";
				write_enable_R0 <= '1';
			end if;

		end if;
	end process;

end Behavioral;
