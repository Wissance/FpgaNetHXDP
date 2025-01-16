library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.marcux_pkg.all;


entity HW_common_ram is

	generic (
			key_size        : integer := 64;
			value_size      : integer := 64;
			max_entries    	: integer := 64
		);

	Port (
		     clk                : in std_logic;
		     reset              : in std_logic;

		     bmem_mb_address      : in std_logic_vector(7 downto 0); 
		     bmem_mb_data_in      : in std_logic_vector(127 downto 0); -- data to mem
		     bmem_mb_data_out     : out std_logic_vector(127 downto 0); -- data from mem
		     bmem_mb_wrt_en       : in std_logic;

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
		     data_in_3   : in std_logic_vector(63 downto 0);

	     -- AXI-LITE INTERFACE
		     axi_clock          : in std_logic;
		     we                 : in std_logic;
		     axi_addr           : in std_logic_vector(31 downto 0); 
		     axi_data_out       : out std_logic_vector(127 downto 0);
		     axi_data_in        : in std_logic_vector (127 downto 0)
	     );

end HW_common_ram;


architecture Behavioral of HW_common_ram is

	signal Wenb  : std_logic_vector(5 downto 0);       
	signal WAddr : std_logic_vector(6*log_2(max_entries)-1 downto 0);
	signal WData : std_logic_vector(6*(key_size+value_size)-1 downto 0);      
	signal RAddr : std_logic_vector(6*log_2(max_entries)-1 downto 0);
	signal RData : std_logic_vector(6*(key_size+value_size)-1 downto 0);  -- !!!!! [(key_size+value_size)*6-1:0]

	component mpram_wrp
		generic (
				MEMD    : integer;
				DATAW   : integer;
				IFILE   : string;
				nRPORTS : integer;
				nWPORTS : integer;
				tipo    : string;   -- // implementation type: REG, XOR, LVTREG, LVTBIN, LVT1HT, AUTO
				BYP     : string); --// Bypassing type: NON, WAW, RAW, RDW

		port (
			     clk   : in  std_logic;                                         
			     Wenb  : in  std_logic_vector(nWPORTS-1 downto 0);         
			     WAddr : in  std_logic_vector(log_2(MEMD)*nWPORTS-1 downto 0); 
			     WData : in  std_logic_vector(DATAW*nWPORTS-1 downto 0);       
			     RAddr : in  std_logic_vector(log_2(MEMD)*nRPORTS-1 downto 0); 
			     RData : out std_logic_vector(DATAW*nRPORTS-1 downto 0)        
		     );
	end component;

	signal padding : std_logic_vector(key_size -1 downto 0) := (others => '0');
begin   

	MULTI_RAMS_PMP_DATA_RAM: mpram_wrp 
	generic map (
			    MEMD    => max_entries,
			    DATAW   => key_size+value_size,
			    nRPORTS => 6,
			    nWPORTS => 6,
			    IFILE => "",
			    tipo    => "LVTREG",   -- // implementation type: REG, XOR, LVTREG, LVTBIN, LVT1HT, AUTO
			    BYP     => "RAW" --
		    )

	port map (

			 Wenb => Wenb,   
			 WAddr => WAddr, 
			 WData => WData, 
			 RAddr => RAddr, 
			 RData => RData, 
			 clk => clk
		 );

	Wenb <=  we  & 
		 wrt_en_0   & 
		 wrt_en_1    & 
		 wrt_en_2  & 
		 wrt_en_3 & 
		 bmem_mb_wrt_en;

	WAddr <= axi_addr(log_2(max_entries)-1 downto 0) & 
		 (wrt_add_0(log_2(max_entries)-1 downto 0))  & 
		 (wrt_add_1(log_2(max_entries)-1 downto 0))  & 
		 (wrt_add_2(log_2(max_entries)-1 downto 0))   & 
		 (wrt_add_3(log_2(max_entries)-1 downto 0)) & 
		 bmem_mb_address(log_2(max_entries)-1 downto 0);

	WData <= axi_data_in((key_size+value_size)-1 downto 0) & 
		 (padding & data_in_0((value_size)-1 downto 0)) & 
		 (padding & data_in_1((value_size)-1 downto 0)) & 
		 (padding & data_in_2((value_size)-1 downto 0)) & 
		 (padding & data_in_3((value_size)-1 downto 0))  & 
		 bmem_mb_data_in((key_size+value_size)-1 downto 0);

	RAddr <= axi_addr(log_2(max_entries)-1 downto 0) & 
		 read_add_0(log_2(max_entries)-1 downto 0) & 
		 read_add_1(log_2(max_entries)-1 downto 0) & 
		 read_add_2(log_2(max_entries)-1 downto 0) & 
		 read_add_3(log_2(max_entries)-1 downto 0) & 
		 bmem_mb_address(log_2(max_entries)-1 downto 0); 

	-- Port Index * (key_size+value_size)
	process (all)
	begin
		axi_data_out		<= (others => '0'); 
		data_out_0		<= (others => '0');
		data_out_1		<= (others => '0');
		data_out_2		<= (others => '0');
		data_out_3		<= (others => '0');
		bmem_mb_data_out	<= (others => '0');
		
		axi_data_out(key_size+value_size -1 downto 0) <=  RData(6*(key_size+value_size)-1 downto 5*(key_size+value_size))   ;      
		data_out_0(value_size -1 downto 0)   	 <=  RData((4*key_size + 5*value_size)-1 downto 4*(key_size+value_size))   ;      
		data_out_1(value_size -1 downto 0)   	 <=  RData((3*key_size + 4*value_size)-1 downto 3*(key_size+value_size))   ;      
		data_out_2(value_size -1 downto 0)  	 <=  RData((2*key_size + 3*value_size)-1 downto 2*(key_size+value_size))   ;      
		data_out_3(value_size -1 downto 0)   	 <=  RData((key_size + 2*value_size)-1 downto (key_size+value_size))   ;      
		bmem_mb_data_out(key_size+value_size -1 downto 0) <=  RData((key_size+value_size) -1  downto 0)  ;     

	end process;

end Behavioral;
