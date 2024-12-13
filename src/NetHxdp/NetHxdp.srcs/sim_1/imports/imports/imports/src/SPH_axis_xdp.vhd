library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity axis_to_xdp is

	port (

		     clk    		: in std_logic; 
		     reset  		: in std_logic; 
		     r0 		: in std_logic_vector(63 downto 0);
		     exit_detected      : in std_logic;
		     start_SPH		: out std_logic;
		     received_packets : out std_logic_vector(31 downto 0);
		     transmitted_packets : out std_logic_vector(31 downto 0);
		     dropped_packets : out std_logic_vector(31 downto 0);

		     M0_AXIS_TDATA   	: out std_logic_vector(255 downto 0);
		     M0_AXIS_TUSER   	: out std_logic_vector(127 downto 0);
		     M0_AXIS_TVALID  	: out std_logic;
		     M0_AXIS_TREADY  	: in std_logic;
		     M0_AXIS_TKEEP   	: out std_logic_vector (31 downto 0);
		     M0_AXIS_TLAST   	: out std_logic; 

		     S0_AXIS_TDATA   	: in std_logic_vector(255 downto 0);
		     S0_AXIS_TUSER   	: in std_logic_vector(127 downto 0);
		     S0_AXIS_TVALID  	: in std_logic;
		     S0_AXIS_TREADY  	: out std_logic;
		     S0_AXIS_TKEEP   	: in std_logic_vector (31 downto 0);
		     S0_AXIS_TLAST   	: in std_logic; 
		     
		     -- INTERFACE FOR bpf_redirect_map ()
		     output_ifindex 	: in std_logic_vector(3 downto 0);
		     bpf_redirect_wrt 	: in std_logic;

		     -- SPH Interfaces
		     read_from_xdp_md_0 : in std_logic;	
		     read_from_xdp_md_1 : in std_logic;	
		     read_from_xdp_md_2 : in std_logic;	
		     read_from_xdp_md_3 : in std_logic;	
		     
		     SPH_read_add_0  : in std_logic_vector(7 downto 0);
		     SPH_read_add_1  : in std_logic_vector(7 downto 0);
		     SPH_read_add_2  : in std_logic_vector(7 downto 0);
		     SPH_read_add_3  : in std_logic_vector(7 downto 0);

		     SPH_data_out_0  : out  std_logic_vector(63 downto 0);
		     SPH_data_out_1  : out  std_logic_vector(63 downto 0);
		     SPH_data_out_2  : out  std_logic_vector(63 downto 0);
		     SPH_data_out_3  : out  std_logic_vector(63 downto 0);

		     SPH_wrt_mask_0  : in  std_logic_vector(63 downto 0);
		     SPH_wrt_mask_1  : in  std_logic_vector(63 downto 0);
		     SPH_wrt_mask_2  : in  std_logic_vector(63 downto 0);
		     SPH_wrt_mask_3  : in  std_logic_vector(63 downto 0);

		     SPH_wrt_add_0   : in std_logic_vector(7 downto 0);
		     SPH_wrt_add_1   : in std_logic_vector(7 downto 0);
		     SPH_wrt_add_2   : in std_logic_vector(7 downto 0);
		     SPH_wrt_add_3   : in std_logic_vector(7 downto 0);
		     SPH_wrt_en_0    : in std_logic;
		     SPH_wrt_en_1    : in std_logic;
		     SPH_wrt_en_2    : in std_logic;
		     SPH_wrt_en_3    : in std_logic;
		     SPH_data_in_0   : in std_logic_vector(63 downto 0);
		     SPH_data_in_1   : in std_logic_vector(63 downto 0);
		     SPH_data_in_2   : in std_logic_vector(63 downto 0);
		     SPH_data_in_3   : in std_logic_vector(63 downto 0)

	     );

end axis_to_xdp;

architecture Behavioral of axis_to_xdp is

	signal 	   start_0                : std_logic;

	signal     skb_address_read_0  	: std_logic_vector(7 downto 0);
	signal     skb_packet_select_0 	: std_logic_vector(31 downto 0);
	signal     skb_address_begin_0 	: std_logic_vector(7 downto 0);
	signal     skb_address_end_0   	: std_logic_vector(7 downto 0);
	signal     skb_tdata_0         	: std_logic_vector(255 downto 0);
	signal     skb_tuser_0	     	: std_logic_vector(127 downto 0);
	signal     skb_tkeep_0	     	: std_logic_vector(31 downto 0);

	signal skb_reset_0 : std_logic;
	signal reset_s : std_logic;



begin

	SPH_AXIS_FIFO: entity work.axis_input_fifo port map
	(

		clk    		=>   clk    	        , 	
		reset  		=>   reset  		,
		received_packets => received_packets,	

		S0_AXIS_TDATA   	=>   S0_AXIS_TDATA   	,
		S0_AXIS_TUSER   	=>   S0_AXIS_TUSER   	,
		S0_AXIS_TVALID  	=>   S0_AXIS_TVALID  	,
		S0_AXIS_TREADY  	=>   S0_AXIS_TREADY  	,
		S0_AXIS_TKEEP   	=>   S0_AXIS_TKEEP   	,
		S0_AXIS_TLAST   	=>   S0_AXIS_TLAST   	,

		skb_reset => skb_reset_0,
		skb_address_read  	=>   skb_address_read_0  	,
		skb_packet_select 	=>   skb_packet_select_0 	,
		skb_address_begin 	=>   skb_address_begin_0 	,
		skb_start  		=>   start_0  		,
		skb_address_end   	=>   skb_address_end_0   	,
		skb_tdata         	=>   skb_tdata_0         	,
		skb_tuser	     	=>   skb_tuser_0	     	,
		skb_tkeep	     	=>   skb_tkeep_0	     	

	);

	SKB_TO_XDP_STRUCT: entity work.skb_to_xdp port map
	(
		clk    		=> clk    	     ,
		reset     	=> reset_s    ,
		r0              => r0,
		exit_detected	=> exit_detected     ,
		start_SPH 	=> start_SPH,
		transmitted_packets => transmitted_packets,
		dropped_packets => dropped_packets,
		     
		output_ifindex 	  =>  output_ifindex  ,	
		bpf_redirect_wrt  =>  bpf_redirect_wrt,

		M0_AXIS_TDATA   	=>  M0_AXIS_TDATA ,    
		M0_AXIS_TUSER       =>  M0_AXIS_TUSER ,    
		M0_AXIS_TVALID      =>  M0_AXIS_TVALID,
		M0_AXIS_TREADY      =>  M0_AXIS_TREADY,
		M0_AXIS_TKEEP       =>  M0_AXIS_TKEEP ,
		M0_AXIS_TLAST       =>  M0_AXIS_TLAST ,

		skb_address_read  	=> skb_address_read_0  ,
		skb_packet_select 	=> skb_packet_select_0 ,
		skb_address_begin 	=> skb_address_begin_0 ,
		skb_start	        => start_0	     ,
		skb_address_end   	=> skb_address_end_0   ,
		skb_tdata         	=> skb_tdata_0         ,
		skb_tuser	        => skb_tuser_0	     ,
		skb_tkeep	        => skb_tkeep_0	     ,

		read_from_xdp_md_0 => read_from_xdp_md_0,
		read_from_xdp_md_1 => read_from_xdp_md_1,
		read_from_xdp_md_2 => read_from_xdp_md_2,
		read_from_xdp_md_3 => read_from_xdp_md_3,

		SPH_read_add_0  =>  SPH_read_add_0 ,
		SPH_read_add_1  =>  SPH_read_add_1 ,
		SPH_read_add_2  =>  SPH_read_add_2 ,
		SPH_read_add_3  =>  SPH_read_add_3 ,
		SPH_data_out_0  =>  SPH_data_out_0 ,
		SPH_data_out_1  =>  SPH_data_out_1 ,
		SPH_data_out_2  =>  SPH_data_out_2 ,
		SPH_data_out_3  =>  SPH_data_out_3 ,
		SPH_wrt_add_0   =>  SPH_wrt_add_0  ,
		SPH_wrt_add_1   =>  SPH_wrt_add_1  ,
		SPH_wrt_add_2   =>  SPH_wrt_add_2  ,
		SPH_wrt_add_3   =>  SPH_wrt_add_3  ,
		SPH_wrt_en_0    =>  SPH_wrt_en_0   ,
		SPH_wrt_en_1    =>  SPH_wrt_en_1   ,
		SPH_wrt_en_2    =>  SPH_wrt_en_2   ,
		SPH_wrt_en_3    =>  SPH_wrt_en_3   ,
		SPH_wrt_mask_0  =>  SPH_wrt_mask_0,
		SPH_wrt_mask_1  =>  SPH_wrt_mask_1,
		SPH_wrt_mask_2  =>  SPH_wrt_mask_2,
		SPH_wrt_mask_3  =>  SPH_wrt_mask_3,
		SPH_data_in_0   =>  SPH_data_in_0  ,
		SPH_data_in_1   =>  SPH_data_in_1  ,
		SPH_data_in_2   =>  SPH_data_in_2  ,
		SPH_data_in_3   =>  SPH_data_in_3 

	);

	reset_s <= reset or skb_reset_0;

end Behavioral;
