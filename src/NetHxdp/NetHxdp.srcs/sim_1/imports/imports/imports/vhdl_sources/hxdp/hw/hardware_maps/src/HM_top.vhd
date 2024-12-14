library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

entity HM_top is

	generic (
			key_size        : integer := 64;
			value_size      : integer := 64;
			max_entries    	: integer := 64;
			map_index 	: std_logic_vector := "0000"
		);

	Port (
		     clk                : in std_logic;
		     reset              : in std_logic;

		     --AXI/INSTRUCTION_MEM interface
		     axi_clock  	: in std_logic;
		     we			: in std_logic;
		     axi_addr 		: in std_logic_vector(31 downto 0); 
		     axi_data_out 	: out std_logic_vector(127 downto 0);
		     axi_data_in     	: in std_logic_vector (127 downto 0);

		     -- CONFIGURATION INTERFACE
		     type_select        : in std_logic_vector(3 downto 0);

		     -- MAPS BUS INTERFACE
		     mb_key                : in std_logic_vector(63 downto 0);
		     mb_value_in           : in std_logic_vector(63 downto 0);
		     mb_value_out          : out std_logic_vector(63 downto 0);
		     mb_wrt_en             : in std_logic;
		     mb_ht_lookup          : in std_logic;
		     mb_ht_remove          : in std_logic;
		     mb_ht_update          : in std_logic;
		     mb_ht_match           : out std_logic;

		     -- Read
		     read_add_0  : in std_logic_vector(63 downto 0);
		     read_add_1  : in std_logic_vector(63 downto 0);
		     read_add_2  : in std_logic_vector(63 downto 0);
		     read_add_3  : in std_logic_vector(63 downto 0);

		     data_out_0  : out std_logic_vector(63 downto 0);
		     data_out_1  : out std_logic_vector(63 downto 0);
		     data_out_2  : out std_logic_vector(63 downto 0);
		     data_out_3  : out std_logic_vector(63 downto 0);

		     --Write
		     wrt_add_0   : in std_logic_vector(63 downto 0);
		     wrt_add_1   : in std_logic_vector(63 downto 0);
		     wrt_add_2   : in std_logic_vector(63 downto 0);
		     wrt_add_3   : in std_logic_vector(63 downto 0);

		     wrt_en_0    : in std_logic;
		     wrt_en_1    : in std_logic;
		     wrt_en_2    : in std_logic;
		     wrt_en_3    : in std_logic;

		     data_in_0   : in std_logic_vector(63 downto 0);
		     data_in_1   : in std_logic_vector(63 downto 0);
		     data_in_2   : in std_logic_vector(63 downto 0);
		     data_in_3   : in std_logic_vector(63 downto 0)

	     );

end HM_top;

architecture Behavioral of HM_top is

	signal bmem_mb_address_s    : std_logic_vector(7 downto 0);   
	signal bmem_mb_data_out_s   : std_logic_vector(127 downto 0);   
	signal bmem_mb_wrt_en_s     : std_logic;   
	signal bmem_mb_data_in_s : std_logic_vector(127 downto 0);


begin

	HM_CONFIGURATOR_I: entity work.HM_configurator 

	generic map 
	(
		key_size     => key_size    ,   
		value_size   => value_size  ,   
		max_entries  => max_entries,   	
		map_index => map_index
	)

	port map 
	(

		type_select => type_select,

		-- BRAM INTERFACE
		bmem_mb_address    => bmem_mb_address_s,  
		bmem_mb_data_in    => bmem_mb_data_in_s,  
		bmem_mb_data_out   => bmem_mb_data_out_s,  
		bmem_mb_wrt_en     => bmem_mb_wrt_en_s,  

		-- MAPS BUS INTERFACE
		mb_key        => mb_key      ,        
		mb_value_in   => mb_value_in ,        
		mb_value_out  => mb_value_out,        
		mb_wrt_en     => mb_wrt_en   ,        
		mb_ht_lookup  => mb_ht_lookup,        
		mb_ht_remove  => mb_ht_remove,        
		mb_ht_update  => mb_ht_update,        
		mb_ht_match   => mb_ht_match         


	);

	HW_RAM_I: entity work.HW_common_ram 
	generic map 
	(
		key_size     => key_size    ,   
		value_size   => value_size  ,   
		max_entries  => max_entries   	
	)
	
	port map 
	(

		clk => clk,
		reset => reset,

		bmem_mb_address => bmem_mb_address_s,
		bmem_mb_data_in => bmem_mb_data_in_s,
		bmem_mb_data_out => bmem_mb_data_out_s,
		bmem_mb_wrt_en => bmem_mb_wrt_en_s,

		read_add_0 => read_add_0, 
		read_add_1 => read_add_1, 
		read_add_2 => read_add_2, 
		read_add_3 => read_add_3, 

		data_out_0 => data_out_0, 
		data_out_1 => data_out_1, 
		data_out_2 => data_out_2, 
		data_out_3 => data_out_3, 

		wrt_add_0  => wrt_add_0 , 
		wrt_add_1  => wrt_add_1 , 
		wrt_add_2  => wrt_add_2 , 
		wrt_add_3  => wrt_add_3 , 

		wrt_en_0   => wrt_en_0  , 
		wrt_en_1   => wrt_en_1  , 
		wrt_en_2   => wrt_en_2  , 
		wrt_en_3   => wrt_en_3  , 

		data_in_0  => data_in_0 , 
		data_in_1  => data_in_1 , 
		data_in_2  => data_in_2 , 
		data_in_3  => data_in_3 ,

		axi_clock    => axi_clock,
		we           => we,
		axi_addr     => axi_addr,
		axi_data_out => axi_data_out,
		axi_data_in  => axi_data_in 

	);

end Behavioral;
