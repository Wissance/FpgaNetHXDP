library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

entity hXDP_maps_subsystem is

	Port (
		     clk                : in std_logic;
		     reset              : in std_logic;

		     --AXI/INSTRUCTION_MEM interface
		     axi_clock 		: in std_logic;
		     we			: in std_logic;
		     axi_addr 		: in std_logic_vector(31 downto 0); 
		     axi_data_out 	: out std_logic_vector(127 downto 0);
		     axi_data_in     	: in std_logic_vector (127 downto 0);


		     -- MAPS BUS INTERFACE to HF
		     mb_key                : in std_logic_vector(63 downto 0);
		     mb_value_in           : in std_logic_vector(63 downto 0);
		     mb_value_out          : out std_logic_vector(63 downto 0);
		     mb_wrt_en             : in std_logic;
		     mb_ht_lookup          : in std_logic;
		     mb_ht_remove          : in std_logic;
		     mb_ht_update          : in std_logic;
		     mb_ht_match           : out std_logic;

		     -- SEPHIROT INTERFACE
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

end hXDP_maps_subsystem;

architecture Behavioral of hXDP_maps_subsystem is

	signal HM0_axi_data_out 	: std_logic_vector(127 downto 0);
	signal HM0_mb_value_out     : std_logic_vector(63 downto 0);
	signal HM0_we               : std_logic;
	signal HM0_type_select               : std_logic_vector(3 downto 0);
	signal HM0_mb_wrt_en        : std_logic;
	signal HM0_mb_ht_match      : std_logic;
	signal HM0_data_out_0  : std_logic_vector(63 downto 0);
	signal HM0_data_out_1  : std_logic_vector(63 downto 0);
	signal HM0_data_out_2  : std_logic_vector(63 downto 0);
	signal HM0_data_out_3  : std_logic_vector(63 downto 0);
	signal HM0_wrt_en_0    : std_logic;
	signal HM0_wrt_en_1    : std_logic;
	signal HM0_wrt_en_2    : std_logic;
	signal HM0_wrt_en_3    : std_logic;

	signal HM1_axi_data_out 	: std_logic_vector(127 downto 0);
	signal HM1_mb_value_out     : std_logic_vector(63 downto 0);
	signal HM1_we               : std_logic;
	signal HM1_type_select               : std_logic_vector(3 downto 0);
	signal HM1_mb_wrt_en        : std_logic;
	signal HM1_mb_ht_match      : std_logic;
	signal HM1_data_out_0  : std_logic_vector(63 downto 0);
	signal HM1_data_out_1  : std_logic_vector(63 downto 0);
	signal HM1_data_out_2  : std_logic_vector(63 downto 0);
	signal HM1_data_out_3  : std_logic_vector(63 downto 0);
	signal HM1_wrt_en_0    : std_logic;
	signal HM1_wrt_en_1    : std_logic;
	signal HM1_wrt_en_2    : std_logic;
	signal HM1_wrt_en_3    : std_logic;

	signal read_add_0_d : std_logic_vector(63 downto 0);
	signal read_add_1_d : std_logic_vector(63 downto 0);
	signal read_add_2_d : std_logic_vector(63 downto 0);
	signal read_add_3_d : std_logic_vector(63 downto 0);
	signal axi_addr_d : std_logic_vector(31 downto 0);
	signal mb_key_d : std_logic_vector(63 downto 0);
	
	signal read_add_0_dd : std_logic_vector(63 downto 0);
	signal read_add_1_dd : std_logic_vector(63 downto 0);
	signal read_add_2_dd : std_logic_vector(63 downto 0);
	signal read_add_3_dd : std_logic_vector(63 downto 0);
	signal axi_addr_dd : std_logic_vector(31 downto 0);
	signal mb_key_dd : std_logic_vector(63 downto 0);


begin

	-- CONFIGURE HERE TYPE OF MAPS
	HM0_type_select <= x"1";
	HM1_type_select <= x"1";

	BPF_DEVMAP: entity work.HM_top 
	generic map (
			    key_size        	=> 32 ,     
			    value_size      	=> 32  ,  
			    max_entries    	=> 128 ,
			   map_index => "0000" 
		    )
	port map (
			 clk                	=>clk   , 
			 reset              	=>reset,

			 --AXI/INSTRUCTION_MEM interface
			 axi_clock 	=> axi_clock,
			 we		=> HM0_we   ,          
			 axi_addr 	=> axi_addr ,
			 axi_data_out 	=>HM0_axi_data_out,
			 axi_data_in     	=>axi_data_in ,

			 -- CONFIGURATION INTERFACE
			 type_select        	=> HM0_type_select      , 

			 -- MAPS BUS INTERFACE
			 mb_key                	=>mb_key          ,  
			 mb_value_in           	=>mb_value_in     ,  
			 mb_value_out          	=>HM0_mb_value_out    ,  
			 mb_wrt_en             	=>HM0_mb_wrt_en       ,  
			 mb_ht_lookup          	=>mb_ht_lookup    ,  
			 mb_ht_remove          	=>mb_ht_remove    ,  
			 mb_ht_update          	=>mb_ht_update    ,  
			 mb_ht_match           	=>HM0_mb_ht_match     ,  

			 -- Read
			 read_add_0  	=>read_add_0 , 
			 read_add_1  	=>read_add_1 , 
			 read_add_2  	=>read_add_2 , 
			 read_add_3  	=>read_add_3 , 

			 data_out_0  	=>HM0_data_out_0, 
			 data_out_1  	=>HM0_data_out_1, 
			 data_out_2  	=>HM0_data_out_2, 
			 data_out_3  	=>HM0_data_out_3, 

			 --Write
			 wrt_add_0   	=>wrt_add_0  , 
			 wrt_add_1   	=>wrt_add_1  , 
			 wrt_add_2   	=>wrt_add_2  , 
			 wrt_add_3   	=>wrt_add_3  , 

			 wrt_en_0    	=>HM0_wrt_en_0, 
			 wrt_en_1    	=>HM0_wrt_en_1, 
			 wrt_en_2    	=>HM0_wrt_en_2, 
			 wrt_en_3    	=>HM0_wrt_en_3, 

			 data_in_0   	=>data_in_0, 
			 data_in_1   	=>data_in_1, 
			 data_in_2   	=>data_in_2, 
			 data_in_3   	=>data_in_3 
		 );

	BPF_ARRAY: entity work.HM_top 

	generic map (
			    key_size        	=> 32 ,     
			    value_size      	=> 64  ,  
			    max_entries    	=> 2 ,
			   map_index => "0001" 
		    )
	port map
	(
		clk                	=>clk   , 
		reset              	=>reset,

		--AXI/INSTRUCTION_MEM interface
		axi_clock 	=> axi_clock,
		we		=> HM1_we   ,          
		axi_addr 	=> axi_addr ,
		axi_data_out 	=>HM1_axi_data_out,
		axi_data_in     	=>axi_data_in ,

		-- CONFIGURATION INTERFACE
		type_select        	=> HM1_type_select      , 

		-- MAPS BUS INTERFACE
		mb_key                	=>mb_key          ,  
		mb_value_in           	=>mb_value_in     ,  
		mb_value_out          	=>HM1_mb_value_out    ,  
		mb_wrt_en             	=>HM1_mb_wrt_en       ,  
		mb_ht_lookup          	=>mb_ht_lookup    ,  
		mb_ht_remove          	=>mb_ht_remove    ,  
		mb_ht_update          	=>mb_ht_update    ,  
		mb_ht_match           	=>HM1_mb_ht_match     ,  

		-- Read
		read_add_0  	=>read_add_0 , 
		read_add_1  	=>read_add_1 , 
		read_add_2  	=>read_add_2 , 
		read_add_3  	=>read_add_3 , 

		data_out_0  	=>HM1_data_out_0, 
		data_out_1  	=>HM1_data_out_1, 
		data_out_2  	=>HM1_data_out_2, 
		data_out_3  	=>HM1_data_out_3, 

		--Write
		wrt_add_0   	=>wrt_add_0  , 
		wrt_add_1   	=>wrt_add_1  , 
		wrt_add_2   	=>wrt_add_2  , 
		wrt_add_3   	=>wrt_add_3  , 

		wrt_en_0    	=>HM1_wrt_en_0, 
		wrt_en_1    	=>HM1_wrt_en_1, 
		wrt_en_2    	=>HM1_wrt_en_2, 
		wrt_en_3    	=>HM1_wrt_en_3, 

		data_in_0   	=>data_in_0, 
		data_in_1   	=>data_in_1, 
		data_in_2   	=>data_in_2, 
		data_in_3   	=>data_in_3 	
	);

	TOKENS: process(clk)
	begin
		if rising_edge(clk) then
			read_add_0_d <= read_add_0;
			read_add_1_d <= read_add_1;
			read_add_2_d <= read_add_2;
			read_add_3_d <= read_add_3;
			axi_addr_d <= axi_addr;
			mb_key_d <= mb_key;
			
			read_add_0_dd <= read_add_0_d;
			read_add_1_dd <= read_add_1_d;
			read_add_2_dd <= read_add_2_d;
			read_add_3_dd <= read_add_3_d;
			axi_addr_dd <= axi_addr_d;
			mb_key_dd <= mb_key_d;
		end if;
	end process;

	READ: process (all)
	begin
		data_out_0 <= (others => '0');
		data_out_1 <= (others => '0');
		data_out_2 <= (others => '0');
		data_out_3 <= (others => '0');
		axi_data_out <= (others => '0');
		mb_value_out <= (others => '0');
		mb_ht_match <= '0';

		case read_add_0_dd(11 downto 8) is

			when x"0" =>
				data_out_0 <= HM0_data_out_0;
			when x"1" =>
				data_out_0 <= HM1_data_out_0;
			when others =>
				data_out_0 <= (others => '0');
		end case;
		case read_add_1_dd(11 downto 8) is

			when x"0" =>
				data_out_1 <= HM0_data_out_1;
			when x"1" =>
				data_out_1 <= HM1_data_out_1;
			when others =>
				data_out_1 <= (others => '0');
		end case;
		case read_add_2_dd(11 downto 8) is

			when x"0" =>
				data_out_2 <= HM0_data_out_2;
			when x"1" =>
				data_out_2 <= HM1_data_out_2;
			when others =>
				data_out_2 <= (others => '0');
		end case;
		case read_add_3_dd(11 downto 8) is

			when x"0" =>
				data_out_3 <= HM0_data_out_3;
			when x"1" =>
				data_out_3 <= HM1_data_out_3;
			when others =>
				data_out_3 <= (others => '0');
		end case;
		case axi_addr_dd(11 downto 8) is

			when x"0" =>
				axi_data_out <= HM0_axi_data_out;
			when x"1" =>
				axi_data_out <= HM1_axi_data_out;
			when others =>
				axi_data_out <= (others => '0');
		end case;
		case mb_key_d(11 downto 8) is

			when x"0" =>
				mb_value_out <= HM0_mb_value_out;
				mb_ht_match <= HM0_mb_ht_match;
			when x"1" =>
				mb_value_out <= HM1_mb_value_out;
				mb_ht_match <= HM1_mb_ht_match;
			when others =>
				mb_value_out <= (others => '0');
				mb_ht_match <= '0';
		end case;


	end process;

	WRITE: process (all)
	begin

		HM0_wrt_en_0 <= '0';
		HM0_wrt_en_1 <= '0';
		HM0_wrt_en_2 <= '0';
		HM0_wrt_en_3 <= '0';
		HM1_wrt_en_0 <= '0';
		HM1_wrt_en_1 <= '0';
		HM1_wrt_en_2 <= '0';
		HM1_wrt_en_3 <= '0';
		HM0_we <= '0';
		HM1_we <= '0';
		HM0_mb_wrt_en <= '0';
		HM1_mb_wrt_en <= '0';

		case wrt_add_0(11 downto 8) is

			when x"0" =>
				HM0_wrt_en_0 <= wrt_en_0;
			when x"1" =>
				HM1_wrt_en_0 <= wrt_en_0;
			when others =>
				HM0_wrt_en_0 <= '0';
				HM1_wrt_en_0 <= '0';
		end case;
		case wrt_add_1(11 downto 8) is

			when x"0" =>
				HM0_wrt_en_1 <= wrt_en_1;
			when x"1" =>
				HM1_wrt_en_1 <= wrt_en_1;
			when others =>
				HM0_wrt_en_1 <= '0';
				HM1_wrt_en_1 <= '0';
		end case;
		case wrt_add_2(11 downto 8) is

			when x"0" =>
				HM0_wrt_en_2 <= wrt_en_2;
			when x"1" =>
				HM1_wrt_en_2 <= wrt_en_2;
			when others =>
				HM0_wrt_en_2 <= '0';
				HM1_wrt_en_2 <= '0';
		end case;
		case wrt_add_3(11 downto 8) is

			when x"0" =>
				HM0_wrt_en_3 <= wrt_en_3;
			when x"1" =>
				HM1_wrt_en_3 <= wrt_en_3;
			when others =>
				HM0_wrt_en_3 <= '0';
				HM1_wrt_en_3 <= '0';
		end case;
		case axi_addr(11 downto 8) is

			when x"0" =>
				HM0_we <= we;
			when x"1" =>
				HM1_we <= we;
			when others =>
				HM0_we <= '0';
				HM1_we <= '0';
		end case;
		case mb_key(11 downto 8) is

			when x"0" =>
				HM0_mb_wrt_en <= mb_wrt_en;
			when x"1" =>
				HM1_mb_wrt_en <= mb_wrt_en;
			when others =>
				HM0_mb_wrt_en <= '0';
				HM1_mb_wrt_en <= '0';
		end case;


	end process;

end Behavioral;
