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


entity SPH_stack is

	generic (
			value_size      : integer := 64;
			max_entries    	: integer := 64
		);

	Port (
		     clk                : in std_logic;
		     reset              : in std_logic;

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

end SPH_stack;


architecture Behavioral of SPH_stack is

	signal Wenb  : std_logic_vector(3 downto 0);       
	signal WAddr : std_logic_vector(4*log_2(max_entries)-1 downto 0);
	signal WData : std_logic_vector(4*(value_size)-1 downto 0);      
	signal RAddr : std_logic_vector(4*log_2(max_entries)-1 downto 0);
	signal RData : std_logic_vector(4*(value_size)-1 downto 0);  

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

begin   

	MULTI_RAMS_PMP_DATA_RAM: mpram_wrp 
	generic map (
			    MEMD    => max_entries,
			    DATAW   => value_size,
			    nRPORTS => 4,
			    nWPORTS => 4,
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

	Wenb <=  wrt_en_0  & 
		 wrt_en_1  & 
		 wrt_en_2  & 
		 wrt_en_3 ; 

	WAddr <= (wrt_add_0(log_2(max_entries)-1 downto 0))  & 
		 (wrt_add_1(log_2(max_entries)-1 downto 0))  & 
		 (wrt_add_2(log_2(max_entries)-1 downto 0))   & 
		 (wrt_add_3(log_2(max_entries)-1 downto 0)) ;

	WData <= (data_in_0((value_size)-1 downto 0)) & 
		 (data_in_1((value_size)-1 downto 0)) & 
		 (data_in_2((value_size)-1 downto 0)) & 
		 (data_in_3((value_size)-1 downto 0)) ; 

	RAddr <= read_add_0(log_2(max_entries)-1 downto 0) & 
		 read_add_1(log_2(max_entries)-1 downto 0) & 
		 read_add_2(log_2(max_entries)-1 downto 0) & 
		 read_add_3(log_2(max_entries)-1 downto 0) ; 


	data_out_0	<=  RData((4*value_size)-1 downto 3*value_size)   ;      
	data_out_1	<=  RData((3*value_size)-1 downto 2*value_size)   ;      
	data_out_2	<=  RData((2*value_size)-1 downto value_size)   ;      
	data_out_3	<=  RData((value_size)-1 downto 0)   ;      

end Behavioral;
