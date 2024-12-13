library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- AXI ADDRESS SPACE

-- 0x80000000 -> 0x8000ffff INSTRUCTION MEMEORY
-- 0x80010000 -> 0x8001ffff MAPS
-- 0x80020000 -> 0x8002ffff DEBUG


entity ebpf4fpga_datapath is

	Generic 
	( 
		RESET_ACTIVE_LOW : boolean := true;

		-- PAGE MUXING --> address(63 downto 60), UP TO 16 hosts on the bus
		QUEUES_PAGE 	: std_logic_vector(3 downto 0) := x"0";
		XDP_MD_PAGE 	: std_logic_vector(3 downto 0) := x"1";
		STACK_PAGE 	: std_logic_vector(3 downto 0) := x"2";
		MAPS_PAGE 	: std_logic_vector(3 downto 0) := x"3"

	); 

	Port 
	( 

		clk    : in std_logic;
		reset  : in std_logic;

	-- Ports of AXI-Stream bus interface
		M0_AXIS_TVALID  : out std_logic;
		M0_AXIS_TREADY  : in std_logic;
		M0_AXIS_TDATA   : out std_logic_vector(255 downto 0);
		M0_AXIS_TKEEP   : out std_logic_vector(31 downto 0);
		M0_AXIS_TLAST   : out std_logic;
		M0_AXIS_TUSER   : out std_logic_vector(127 downto 0);

		S0_AXIS_TDATA   : in std_logic_vector(255 downto 0);
		S0_AXIS_TUSER   : in std_logic_vector(127 downto 0);
		S0_AXIS_TVALID  : in std_logic;
		S0_AXIS_TREADY  : out std_logic;
		S0_AXIS_TKEEP   : in std_logic_vector (31 downto 0);
		S0_AXIS_TLAST   : in std_logic;

	-- Ports of Axi Slave Bus Interface S_AXI
		S_AXI_ACLK        : in  std_logic;  
		S_AXI_ARESETN     : in  std_logic;                                     
		S_AXI_AWADDR      : in  std_logic_vector(31 downto 0);     
		S_AXI_AWVALID     : in  std_logic; 
		S_AXI_WDATA       : in  std_logic_vector(31 downto 0); 
		S_AXI_WSTRB       : in  std_logic_vector(3 downto 0);   
		S_AXI_WVALID      : in  std_logic;                                    
		S_AXI_BREADY      : in  std_logic;                                    
		S_AXI_ARADDR      : in  std_logic_vector(31 downto 0);
		S_AXI_ARVALID     : in  std_logic;                                     
		S_AXI_RREADY      : in  std_logic;                                     
		S_AXI_ARREADY     : out std_logic;             
		S_AXI_RDATA       : out std_logic_vector(31 downto 0);
		S_AXI_RRESP       : out std_logic_vector(1 downto 0);
		S_AXI_RVALID      : out std_logic;                                   
		S_AXI_WREADY      : out std_logic; 
		S_AXI_BRESP       : out std_logic_vector(1 downto 0);                         
		S_AXI_BVALID      : out std_logic;                                    
		S_AXI_AWREADY     : out std_logic
	);

end ebpf4fpga_datapath;

architecture Behavioral of ebpf4fpga_datapath is

	--      -----------------------------
	--     ?? BEGIN OF INPUT PIPE SIGNALS ??
	--      -----------------------------

	signal S0_AXIS_TDATA_0   :  std_logic_vector(255 downto 0);
	signal S0_AXIS_TUSER_0   :  std_logic_vector(127 downto 0);
	signal S0_AXIS_TVALID_0  :  std_logic;
	signal S0_AXIS_TKEEP_0   :  std_logic_vector (31 downto 0);
	signal S0_AXIS_TLAST_0   :  std_logic;
	signal S0_AXIS_TREADY_0  :  std_logic;

	signal S0_AXIS_TDATA_1   :  std_logic_vector(255 downto 0);
	signal S0_AXIS_TUSER_1   :  std_logic_vector(127 downto 0);
	signal S0_AXIS_TVALID_1  :  std_logic;
	signal S0_AXIS_TKEEP_1   :  std_logic_vector (31 downto 0);
	signal S0_AXIS_TLAST_1   :  std_logic;
	signal S0_AXIS_TREADY_1  :  std_logic;

	--      --------------------------
	--     ?? BEGIN OF CONTROL SIGNALS ??
	--      --------------------------

	signal    reset_s           : std_logic; 
	signal    start_s           : std_logic; 
	signal    exit_detected_s   : std_logic;
	signal 	  received_packets  : std_logic_vector(31 downto 0);
	signal 	  dropped_packets  : std_logic_vector(31 downto 0);
	signal 	  transmitted_packets  : std_logic_vector(31 downto 0);

	-- FROM bpf_redirect() to APS
	signal output_ifindex_s : std_logic_vector(3 downto 0);
	signal bpf_redirect_wrt_s : std_logic;


	--      ------------------------------
	--     ?? BEGIN OF SPH RELATED SIGNALS ??
	--      ------------------------------

	signal    axi_clock     		: std_logic; 
	signal    instruction_mem_we            : std_logic; 
	signal    instruction_mem_re 		: std_logic;
	signal    axi_addr_s      		: std_logic_vector(31 downto 0); 
	signal    instruction_mem_axi_data_out  : std_logic_vector(255 downto 0);
	signal    instruction_mem_axi_data_in   : std_logic_vector(255 downto 0); 
	signal    maps_axi_addr 		: std_logic_vector(31 downto 0);
	signal    maps_axi_data_in 		: std_logic_vector(127 downto 0);
	signal    maps_axi_data_out 		: std_logic_vector(127 downto 0);
	signal    maps_we 			: std_logic;
	signal    maps_re 			: std_logic;

	-- SPH: Instruction memory interface
	signal SPH_imem_addr : std_logic_vector(15 downto 0);
	signal SPH_imem_data : std_logic_vector(255 downto 0);

	-- SPH: Helper Functions interface
	signal    SPH_gpr_1            : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_2            : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_3            : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_4            : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_5            : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_0_in         : std_logic_vector(63 downto 0); 
	signal    SPH_gpr_0_out        : std_logic_vector(63 downto 0); 

	signal    SPH_w_e_0_hf         : std_logic;
	signal    helper_function_done : std_logic;
	signal    helper_function_start : std_logic;
	signal    helper_function_id   : std_logic_vector(7 downto 0);

	-- SPH: Data Bus Interface
	signal    SPH_dbus_data_in_0 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_data_in_1 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_data_in_2 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_data_in_3 : std_logic_vector(63 downto 0); 

	signal    SPH_dbus_data_out_0 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_data_out_1 : std_logic_vector(63 downto 0);  
	signal    SPH_dbus_data_out_2 : std_logic_vector(63 downto 0);  
	signal    SPH_dbus_data_out_3 : std_logic_vector(63 downto 0);  

	signal    SPH_dbus_data_mask_0 : std_logic_vector(63 downto 0);
	signal    SPH_dbus_data_mask_1 : std_logic_vector(63 downto 0);
	signal    SPH_dbus_data_mask_2 : std_logic_vector(63 downto 0);
	signal    SPH_dbus_data_mask_3 : std_logic_vector(63 downto 0);

	signal    SPH_dbus_addr_read_0 : std_logic_vector(63 downto 0);    
	signal    SPH_dbus_addr_read_1 : std_logic_vector(63 downto 0);    
	signal    SPH_dbus_addr_read_2 : std_logic_vector(63 downto 0);    
	signal    SPH_dbus_addr_read_3 : std_logic_vector(63 downto 0);    

	signal    SPH_dbus_addr_wrt_0 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_addr_wrt_1 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_addr_wrt_2 : std_logic_vector(63 downto 0); 
	signal    SPH_dbus_addr_wrt_3 : std_logic_vector(63 downto 0); 

	signal    SPH_dbus_wrt_en_0  : std_logic;   
	signal    SPH_dbus_wrt_en_1  : std_logic;   
	signal    SPH_dbus_wrt_en_2  : std_logic;   
	signal    SPH_dbus_wrt_en_3  : std_logic;   

	signal    SPH_cycles : std_logic_vector(31 downto 0);        

	--      --------------------------------------
	--     ?? BEGIN OF INPUT QUEUS RELATED SIGNALS ??
	--      --------------------------------------

	signal read_from_xdp_md_0 : std_logic;
	signal read_from_xdp_md_1 : std_logic;
	signal read_from_xdp_md_2 : std_logic;
	signal read_from_xdp_md_3 : std_logic;

	signal QUEUES_read_add_0  : std_logic_vector(7 downto 0);
	signal QUEUES_read_add_1  : std_logic_vector(7 downto 0);
	signal QUEUES_read_add_2  : std_logic_vector(7 downto 0);
	signal QUEUES_read_add_3  : std_logic_vector(7 downto 0);

	signal QUEUES_data_out_0  : std_logic_vector(63 downto 0);
	signal QUEUES_data_out_1  : std_logic_vector(63 downto 0);
	signal QUEUES_data_out_2  : std_logic_vector(63 downto 0);
	signal QUEUES_data_out_3  : std_logic_vector(63 downto 0);

	signal QUEUES_wrt_add_0   : std_logic_vector(7 downto 0);
	signal QUEUES_wrt_add_1   : std_logic_vector(7 downto 0);
	signal QUEUES_wrt_add_2   : std_logic_vector(7 downto 0);
	signal QUEUES_wrt_add_3   : std_logic_vector(7 downto 0);

	signal QUEUES_wrt_en_0    : std_logic;
	signal QUEUES_wrt_en_1    : std_logic;
	signal QUEUES_wrt_en_2    : std_logic;
	signal QUEUES_wrt_en_3    : std_logic;

	signal QUEUES_data_in_0   : std_logic_vector(63 downto 0);
	signal QUEUES_data_in_1   : std_logic_vector(63 downto 0);
	signal QUEUES_data_in_2   : std_logic_vector(63 downto 0);
	signal QUEUES_data_in_3   : std_logic_vector(63 downto 0);

	--      -------------------------------
	--     ?? BEGIN OF MAPS RELATED SIGNALS ??
	--      -------------------------------

	signal  mb_key             : std_logic_vector(63 downto 0);
	signal  mb_value_in        : std_logic_vector(63 downto 0);
	signal  mb_value_out       : std_logic_vector(63 downto 0);
	signal  mb_wrt_en          : std_logic;
	signal  mb_ht_lookup       : std_logic;
	signal  mb_ht_remove       : std_logic;
	signal  mb_ht_update       : std_logic;
	signal  mb_ht_match        : std_logic;

	-- SPH interface
	signal MAPS_read_add_0  : std_logic_vector(63 downto 0);
	signal MAPS_read_add_1  : std_logic_vector(63 downto 0);
	signal MAPS_read_add_2  : std_logic_vector(63 downto 0);
	signal MAPS_read_add_3  : std_logic_vector(63 downto 0);

	signal MAPS_data_out_0  :  std_logic_vector(63 downto 0);
	signal MAPS_data_out_1  :  std_logic_vector(63 downto 0);
	signal MAPS_data_out_2  :  std_logic_vector(63 downto 0);
	signal MAPS_data_out_3  :  std_logic_vector(63 downto 0);

	signal MAPS_wrt_add_0   : std_logic_vector(63 downto 0);
	signal MAPS_wrt_add_1   : std_logic_vector(63 downto 0);
	signal MAPS_wrt_add_2   : std_logic_vector(63 downto 0);
	signal MAPS_wrt_add_3   : std_logic_vector(63 downto 0);

	signal MAPS_wrt_en_0    : std_logic;
	signal MAPS_wrt_en_1    : std_logic;
	signal MAPS_wrt_en_2    : std_logic;
	signal MAPS_wrt_en_3    : std_logic;

	signal MAPS_data_in_0   : std_logic_vector(63 downto 0);
	signal MAPS_data_in_1   : std_logic_vector(63 downto 0);
	signal MAPS_data_in_2   : std_logic_vector(63 downto 0);
	signal MAPS_data_in_3   : std_logic_vector(63 downto 0);

	--      --------------------------------
	--     ?? BEGIN OF STACK RELATED SIGNALS ??
	--      --------------------------------

	-- SPH interface
	signal STACK_read_add_0  : std_logic_vector(63 downto 0);
	signal STACK_read_add_1  : std_logic_vector(63 downto 0);
	signal STACK_read_add_2  : std_logic_vector(63 downto 0);
	signal STACK_read_add_3  : std_logic_vector(63 downto 0);

	signal STACK_data_out_0  :  std_logic_vector(63 downto 0);
	signal STACK_data_out_1  :  std_logic_vector(63 downto 0);
	signal STACK_data_out_2  :  std_logic_vector(63 downto 0);
	signal STACK_data_out_3  :  std_logic_vector(63 downto 0);

	signal STACK_wrt_add_0   : std_logic_vector(63 downto 0);
	signal STACK_wrt_add_1   : std_logic_vector(63 downto 0);
	signal STACK_wrt_add_2   : std_logic_vector(63 downto 0);
	signal STACK_wrt_add_3   : std_logic_vector(63 downto 0);

	signal STACK_wrt_en_0    : std_logic;
	signal STACK_wrt_en_1    : std_logic;
	signal STACK_wrt_en_2    : std_logic;
	signal STACK_wrt_en_3    : std_logic;

	signal STACK_data_in_0   : std_logic_vector(63 downto 0);
	signal STACK_data_in_1   : std_logic_vector(63 downto 0);
	signal STACK_data_in_2   : std_logic_vector(63 downto 0);
	signal STACK_data_in_3   : std_logic_vector(63 downto 0);

	--      -------------------------------
	--     ?? BEGIN OF *CTX RELATED SIGNALS ??
	--      -------------------------------

	attribute max_fanout : integer;                              
	attribute max_fanout of SPH_dbus_addr_read_0 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_read_1 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_read_2 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_read_3 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_wrt_0 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_wrt_1 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_wrt_2 : signal is 256;
	attribute max_fanout of SPH_dbus_addr_wrt_3 : signal is 256;

begin

	--      --------------------
	--     ?? COMPONENT ISTANCES ??
	--      --------------------

	AXIS_TO_XDP: entity work.axis_to_xdp port map
	(
		clk                =>    clk               , 
		reset              =>    reset_s             , 
		r0                 =>    SPH_gpr_0_out,
		exit_detected      =>    exit_detected_s     , 
		start_SPH	        =>    start_s	        ,

		received_packets => received_packets,
		dropped_packets => dropped_packets,
		transmitted_packets => transmitted_packets,

		-- bpf_redirect_map()
		output_ifindex => output_ifindex_s,
		bpf_redirect_wrt => bpf_redirect_wrt_s,

		M0_AXIS_TVALID  =>  M0_AXIS_TVALID, 
		M0_AXIS_TREADY  =>  M0_AXIS_TREADY, 
		M0_AXIS_TDATA   =>  M0_AXIS_TDATA , 
		M0_AXIS_TKEEP   =>  M0_AXIS_TKEEP , 
		M0_AXIS_TLAST   =>  M0_AXIS_TLAST , 
		M0_AXIS_TUSER   =>  M0_AXIS_TUSER , 

		S0_AXIS_TDATA      =>    S0_AXIS_TDATA_1     , 
		S0_AXIS_TUSER      =>    S0_AXIS_TUSER_1     , 
		S0_AXIS_TVALID     =>    S0_AXIS_TVALID_1    , 
		S0_AXIS_TREADY     =>    S0_AXIS_TREADY_1    , 
		S0_AXIS_TKEEP      =>    S0_AXIS_TKEEP_1     , 
		S0_AXIS_TLAST      =>    S0_AXIS_TLAST_1     , 

		read_from_xdp_md_0 => read_from_xdp_md_0,
		read_from_xdp_md_1 => read_from_xdp_md_1,
		read_from_xdp_md_2 => read_from_xdp_md_2,
		read_from_xdp_md_3 => read_from_xdp_md_3,

		SPH_read_add_0      =>  QUEUES_read_add_0    , 
		SPH_read_add_1      =>  QUEUES_read_add_1    , 
		SPH_read_add_2      =>  QUEUES_read_add_2    , 
		SPH_read_add_3      =>  QUEUES_read_add_3    , 

		SPH_data_out_0      =>  QUEUES_data_out_0    , 
		SPH_data_out_1      =>  QUEUES_data_out_1    , 
		SPH_data_out_2      =>  QUEUES_data_out_2    , 
		SPH_data_out_3      =>  QUEUES_data_out_3    , 

		SPH_wrt_add_0       =>  QUEUES_wrt_add_0     , 
		SPH_wrt_add_1       =>  QUEUES_wrt_add_1     , 
		SPH_wrt_add_2       =>  QUEUES_wrt_add_2     , 
		SPH_wrt_add_3       =>  QUEUES_wrt_add_3     , 

		SPH_wrt_en_0        =>  QUEUES_wrt_en_0      , 
		SPH_wrt_en_1        =>  QUEUES_wrt_en_1      , 
		SPH_wrt_en_2        =>  QUEUES_wrt_en_2      , 
		SPH_wrt_en_3        =>  QUEUES_wrt_en_3      , 

		SPH_wrt_mask_0        => SPH_dbus_data_mask_0      , 
		SPH_wrt_mask_1        => SPH_dbus_data_mask_1      , 
		SPH_wrt_mask_2        => SPH_dbus_data_mask_2      , 
		SPH_wrt_mask_3        => SPH_dbus_data_mask_3      , 

		SPH_data_in_0       =>  QUEUES_data_in_0     , 
		SPH_data_in_1       =>  QUEUES_data_in_1     , 
		SPH_data_in_2       =>  QUEUES_data_in_2     , 
		SPH_data_in_3       =>  QUEUES_data_in_3      

	);

	SPH_CORE: entity work.PMP_core 
	generic map 
	(
		XDP_MD_PAGE => XDP_MD_PAGE,
		STACK_PAGE => STACK_PAGE

	)
	port map
	(
		clk   		=> clk,       
		reset 		=> reset_s,   
		start 		=> start_s,
		exit_detected 	=> exit_detected_s,
		instr_data 	=> SPH_imem_data, -- instructions from instructions memory 
		instr_addr 	=> SPH_imem_addr, -- addres to instruction memory


		-- interface for helper functions
		gpr_0_out => SPH_gpr_0_out,
		gpr_1    =>  SPH_gpr_1,
		gpr_2    =>  SPH_gpr_2,
		gpr_3    =>  SPH_gpr_3,
		gpr_4    =>  SPH_gpr_4,
		gpr_5    =>  SPH_gpr_5,
		gpr_0_in    =>  SPH_gpr_0_in,
		w_e_0_hf =>  SPH_w_e_0_hf,

		-- Data Bus Interface

		dbus_data_in_0 => SPH_dbus_data_in_0, 
		dbus_data_in_1 => SPH_dbus_data_in_1, 
		dbus_data_in_2 => SPH_dbus_data_in_2, 
		dbus_data_in_3 => SPH_dbus_data_in_3, 

		dbus_data_out_0 => SPH_dbus_data_out_0,
		dbus_data_out_1 => SPH_dbus_data_out_1, 
		dbus_data_out_2 => SPH_dbus_data_out_2, 
		dbus_data_out_3 => SPH_dbus_data_out_3, 

		dbus_data_mask_0 => SPH_dbus_data_mask_0,
		dbus_data_mask_1 => SPH_dbus_data_mask_1,
		dbus_data_mask_2 => SPH_dbus_data_mask_2,
		dbus_data_mask_3 => SPH_dbus_data_mask_3,

		dbus_addr_read_0 => SPH_dbus_addr_read_0,   
		dbus_addr_read_1 => SPH_dbus_addr_read_1,  
		dbus_addr_read_2 => SPH_dbus_addr_read_2, 
		dbus_addr_read_3 => SPH_dbus_addr_read_3,  

		dbus_addr_wrt_0 => SPH_dbus_addr_wrt_0,
		dbus_addr_wrt_1 => SPH_dbus_addr_wrt_1,
		dbus_addr_wrt_2 => SPH_dbus_addr_wrt_2,
		dbus_addr_wrt_3 => SPH_dbus_addr_wrt_3,

		dbus_wrt_en_0 => SPH_dbus_wrt_en_0,     
		dbus_wrt_en_1 => SPH_dbus_wrt_en_1,    
		dbus_wrt_en_2 => SPH_dbus_wrt_en_2,    
		dbus_wrt_en_3 => SPH_dbus_wrt_en_3,    

		helper_function_done => helper_function_done,
		helper_function_start => helper_function_start,
		helper_function_id => helper_function_id

	);

	INSTRUCTION_MEM: entity work.i_mem port map 
	(

		-- AXI/INSTRUCTION_MEM interface
		axi_clock      => axi_clock,  
		we             => instruction_mem_we,
		axi_addr       => axi_addr_s,
		axi_data_out   => instruction_mem_axi_data_out,
		axi_data_in    => instruction_mem_axi_data_in,
		-- SPH Interface
		clock 		=> clk,
		reset 	 => reset_s,
		addr 	 => SPH_imem_addr,
		data_out => SPH_imem_data

	);


	MAPS_SUBSYS: entity work.hxdp_maps_subsystem port map
	(
		clk      => clk,          
		reset    => reset_s,          

		mb_key           =>  mb_key          ,    
		mb_value_in      =>  mb_value_in     ,    
		mb_value_out     =>  mb_value_out    ,    
		mb_wrt_en        =>  mb_wrt_en       ,    
		mb_ht_lookup     =>  mb_ht_lookup    ,    
		mb_ht_remove     =>  mb_ht_remove    ,    
		mb_ht_update     =>  mb_ht_update    ,    
		mb_ht_match      =>  mb_ht_match     ,    

		read_add_0 => MAPS_read_add_0,
		read_add_1 => MAPS_read_add_1,
		read_add_2 => MAPS_read_add_2,
		read_add_3 => MAPS_read_add_3,

		data_out_0 => MAPS_data_out_0, 
		data_out_1 => MAPS_data_out_1, 
		data_out_2 => MAPS_data_out_2, 
		data_out_3 => MAPS_data_out_3, 

		wrt_add_0  => MAPS_wrt_add_0, 
		wrt_add_1  => MAPS_wrt_add_1, 
		wrt_add_2  => MAPS_wrt_add_2, 
		wrt_add_3  => MAPS_wrt_add_3, 

		wrt_en_0   => MAPS_wrt_en_0, 
		wrt_en_1   => MAPS_wrt_en_1, 
		wrt_en_2   => MAPS_wrt_en_2, 
		wrt_en_3   => MAPS_wrt_en_3, 

		data_in_0  => MAPS_data_in_0, 
		data_in_1  => MAPS_data_in_1, 
		data_in_2  => MAPS_data_in_2, 
		data_in_3  => MAPS_data_in_3,

		axi_clock     => axi_clock,
		we            => maps_we,
		axi_addr      => axi_addr_s,
		axi_data_out  => maps_axi_data_out,
		axi_data_in   => maps_axi_data_in   

	);

	STACK: entity work.SPH_stack port map
	(
		clk      => clk,          
		reset    => (reset_s or exit_detected_s),         

		read_add_0 => STACK_read_add_0,
		read_add_1 => STACK_read_add_1,
		read_add_2 => STACK_read_add_2,
		read_add_3 => STACK_read_add_3,

		data_out_0 => STACK_data_out_0, 
		data_out_1 => STACK_data_out_1, 
		data_out_2 => STACK_data_out_2, 
		data_out_3 => STACK_data_out_3, 

		wrt_add_0  => STACK_wrt_add_0, 
		wrt_add_1  => STACK_wrt_add_1, 
		wrt_add_2  => STACK_wrt_add_2, 
		wrt_add_3  => STACK_wrt_add_3, 

		wrt_en_0   => STACK_wrt_en_0, 
		wrt_en_1   => STACK_wrt_en_1, 
		wrt_en_2   => STACK_wrt_en_2, 
		wrt_en_3   => STACK_wrt_en_3, 

		data_in_0  => STACK_data_in_0, 
		data_in_1  => STACK_data_in_1, 
		data_in_2  => STACK_data_in_2, 
		data_in_3  => STACK_data_in_3

	);

	HF_SUBSYS: entity work.HF_top port map
	(

		done  => helper_function_done, 
		clk => clk,   
		start => helper_function_start,                                

		R0 => SPH_gpr_0_in,                  
		write_enable_R0 => SPH_w_e_0_hf,                            

		R1 => SPH_gpr_1,                   
		R2 => SPH_gpr_2,
		R3 => SPH_gpr_3,                   
		R4 => SPH_gpr_4,                   
		R5 => SPH_gpr_5,                   
		ID => helper_function_id,                  

		-- APS Interface
		output_ifindex => output_ifindex_s,
		bpf_redirect_wrt => bpf_redirect_wrt_s,

		mb_key            => mb_key,    
		mb_value_to_map   => mb_value_in,   
		mb_value_from_map => mb_value_out,
		mb_wrt_en         => mb_wrt_en,

		mb_ht_match       => mb_ht_match,                 
		mb_ht_lookup      => mb_ht_lookup,                  
		mb_ht_update      => mb_ht_update,                  
		mb_ht_remove      => mb_ht_remove                  

	);

	AXI_IO_IFACE : entity work.AXI4tomem port map 
	(
		we_INSTR => instruction_mem_we,
		we_MAPS => maps_we,
		address_out => axi_addr_s,
		start_SPH => start_s,
		datapath_reset => reset_s,
		received_packets => received_packets,
		dropped_packets => dropped_packets,
		transmitted_packets => transmitted_packets,
		imem_data_out => instruction_mem_axi_data_in,
		imem_data_in => instruction_mem_axi_data_out,
		maps_data_out => maps_axi_data_in,
		maps_data_in => maps_axi_data_out,
		S_AXI_ACLK    => S_AXI_ACLK     ,
		S_AXI_ARESETN => S_AXI_ARESETN  ,
		S_AXI_AWADDR  => S_AXI_AWADDR   ,
		S_AXI_AWVALID => S_AXI_AWVALID  ,
		S_AXI_WDATA   => S_AXI_WDATA    ,
		S_AXI_WSTRB   => S_AXI_WSTRB    ,
		S_AXI_WVALID  => S_AXI_WVALID   ,
		S_AXI_BREADY  => S_AXI_BREADY   ,
		S_AXI_ARADDR  => S_AXI_ARADDR   ,
		S_AXI_ARVALID => S_AXI_ARVALID  ,
		S_AXI_RREADY  => S_AXI_RREADY   ,
		S_AXI_ARREADY => S_AXI_ARREADY  ,
		S_AXI_RDATA   => S_AXI_RDATA    ,
		S_AXI_RRESP   => S_AXI_RRESP    ,
		S_AXI_RVALID  => S_AXI_RVALID   ,
		S_AXI_WREADY  => S_AXI_WREADY   ,
		S_AXI_BRESP   => S_AXI_BRESP    ,
		S_AXI_BVALID  => S_AXI_BVALID   ,
		S_AXI_AWREADY => S_AXI_AWREADY  

	);
	--      ---------------
	--     ?? CONTROL LOGIC ??
	--      ---------------

	reset_s <= reset when (RESET_ACTIVE_LOW = false) else
		   not(reset);

	axi_clock <= S_AXI_ACLK;

	--     +---------------------------+
	--     ?? MUXING ACCESS TO DATA BUS ??
	--     +---------------------------+

	-- MAPS
	MAPS_read_add_0 <= SPH_dbus_addr_read_0;
	MAPS_read_add_1 <= SPH_dbus_addr_read_1;
	MAPS_read_add_2 <= SPH_dbus_addr_read_2;
	MAPS_read_add_3 <= SPH_dbus_addr_read_3;

	MAPS_wrt_add_0 <= SPH_dbus_addr_wrt_0;
	MAPS_wrt_add_1 <= SPH_dbus_addr_wrt_1;
	MAPS_wrt_add_2 <= SPH_dbus_addr_wrt_2;
	MAPS_wrt_add_3 <= SPH_dbus_addr_wrt_3;

	MAPS_data_in_0 <= SPH_dbus_data_out_0;
	MAPS_data_in_1 <= SPH_dbus_data_out_1;
	MAPS_data_in_2 <= SPH_dbus_data_out_2;
	MAPS_data_in_3 <= SPH_dbus_data_out_3;

	MAPS_wrt_en_0 <= SPH_dbus_wrt_en_0 when (SPH_dbus_addr_wrt_0(63 downto 60)= MAPS_PAGE) else
			 '0';
	MAPS_wrt_en_1 <= SPH_dbus_wrt_en_1 when (SPH_dbus_addr_wrt_1(63 downto 60)= MAPS_PAGE) else
			 '0';
	MAPS_wrt_en_2 <= SPH_dbus_wrt_en_2 when (SPH_dbus_addr_wrt_2(63 downto 60)= MAPS_PAGE) else
			 '0';
	MAPS_wrt_en_3 <= SPH_dbus_wrt_en_3 when (SPH_dbus_addr_wrt_3(63 downto 60)= MAPS_PAGE) else
			 '0';

	-- QUEUES
	QUEUES_read_add_0 <= SPH_dbus_addr_read_0(7 downto 0);
	QUEUES_read_add_1 <= SPH_dbus_addr_read_1(7 downto 0);
	QUEUES_read_add_2 <= SPH_dbus_addr_read_2(7 downto 0);
	QUEUES_read_add_3 <= SPH_dbus_addr_read_3(7 downto 0);

	QUEUES_wrt_add_0 <= SPH_dbus_addr_wrt_0(7 downto 0);
	QUEUES_wrt_add_1 <= SPH_dbus_addr_wrt_1(7 downto 0);
	QUEUES_wrt_add_2 <= SPH_dbus_addr_wrt_2(7 downto 0);
	QUEUES_wrt_add_3 <= SPH_dbus_addr_wrt_3(7 downto 0);

	QUEUES_data_in_0 <= SPH_dbus_data_out_0;
	QUEUES_data_in_1 <= SPH_dbus_data_out_1;
	QUEUES_data_in_2 <= SPH_dbus_data_out_2;
	QUEUES_data_in_3 <= SPH_dbus_data_out_3;

	QUEUES_wrt_en_0 <= SPH_dbus_wrt_en_0 when (SPH_dbus_addr_wrt_0(63 downto 60) = QUEUES_PAGE) else
			   '0';
	QUEUES_wrt_en_1 <= SPH_dbus_wrt_en_1 when (SPH_dbus_addr_wrt_1(63 downto 60) = QUEUES_PAGE) else
			   '0';
	QUEUES_wrt_en_2 <= SPH_dbus_wrt_en_2 when (SPH_dbus_addr_wrt_2(63 downto 60) = QUEUES_PAGE) else
			   '0';
	QUEUES_wrt_en_3 <= SPH_dbus_wrt_en_3 when (SPH_dbus_addr_wrt_3(63 downto 60) = QUEUES_PAGE) else
			   '0';

	read_from_xdp_md_0 <= '1' when (SPH_dbus_addr_read_0(63 downto 60) = XDP_MD_PAGE) else
			      '0';
	read_from_xdp_md_1 <= '1' when (SPH_dbus_addr_read_1(63 downto 60) = XDP_MD_PAGE) else
			      '0';
	read_from_xdp_md_2 <= '1' when (SPH_dbus_addr_read_2(63 downto 60) = XDP_MD_PAGE) else
			      '0';
	read_from_xdp_md_3 <= '1' when (SPH_dbus_addr_read_3(63 downto 60) = XDP_MD_PAGE) else
			      '0';

	-- STACK
	STACK_read_add_0 <= SPH_dbus_addr_read_0;
	STACK_read_add_1 <= SPH_dbus_addr_read_1;
	STACK_read_add_2 <= SPH_dbus_addr_read_2;
	STACK_read_add_3 <= SPH_dbus_addr_read_3;

	STACK_wrt_add_0 <= SPH_dbus_addr_wrt_0;
	STACK_wrt_add_1 <= SPH_dbus_addr_wrt_1;
	STACK_wrt_add_2 <= SPH_dbus_addr_wrt_2;
	STACK_wrt_add_3 <= SPH_dbus_addr_wrt_3;

	STACK_data_in_0 <= SPH_dbus_data_out_0;
	STACK_data_in_1 <= SPH_dbus_data_out_1;
	STACK_data_in_2 <= SPH_dbus_data_out_2;
	STACK_data_in_3 <= SPH_dbus_data_out_3;

	STACK_wrt_en_0 <= SPH_dbus_wrt_en_0 when (SPH_dbus_addr_wrt_0(63 downto 60)= STACK_PAGE) else
			  '0';
	STACK_wrt_en_1 <= SPH_dbus_wrt_en_1 when (SPH_dbus_addr_wrt_1(63 downto 60)= STACK_PAGE) else
			  '0';
	STACK_wrt_en_2 <= SPH_dbus_wrt_en_2 when (SPH_dbus_addr_wrt_2(63 downto 60)= STACK_PAGE) else
			  '0';
	STACK_wrt_en_3 <= SPH_dbus_wrt_en_3 when (SPH_dbus_addr_wrt_3(63 downto 60)= STACK_PAGE) else
			  '0';


	-- MUXING DATA IN TO SPH
	SPH_dbus_data_in_0 <=  QUEUES_data_out_0 when (SPH_dbus_addr_read_0(63 downto 60) = QUEUES_PAGE) else 
			       MAPS_data_out_0 when (SPH_dbus_addr_read_0(63 downto 60) = MAPS_PAGE) else
			       QUEUES_data_out_0 when (SPH_dbus_addr_read_0(63 downto 60) = XDP_MD_PAGE) else 
			       STACK_data_out_0 when (SPH_dbus_addr_read_0(63 downto 60) = STACK_PAGE) else 
			       (others => '0');

	SPH_dbus_data_in_1 <=  QUEUES_data_out_1 when (SPH_dbus_addr_read_1(63 downto 60) = QUEUES_PAGE) else 
			       MAPS_data_out_1 when (SPH_dbus_addr_read_1(63 downto 60) = MAPS_PAGE) else
			       QUEUES_data_out_1 when (SPH_dbus_addr_read_0(63 downto 60) = XDP_MD_PAGE) else 
			       STACK_data_out_1 when (SPH_dbus_addr_read_0(63 downto 60) = STACK_PAGE) else 
			       (others => '0');

	SPH_dbus_data_in_2 <=  QUEUES_data_out_2 when (SPH_dbus_addr_read_2(63 downto 60) = QUEUES_PAGE) else 
			       MAPS_data_out_2 when (SPH_dbus_addr_read_2(63 downto 60) = MAPS_PAGE) else
			       QUEUES_data_out_2 when (SPH_dbus_addr_read_0(63 downto 60) = XDP_MD_PAGE) else 
			       STACK_data_out_2 when (SPH_dbus_addr_read_0(63 downto 60) = STACK_PAGE) else 
			       (others => '0');

	SPH_dbus_data_in_3 <=  QUEUES_data_out_3 when (SPH_dbus_addr_read_3(63 downto 60) = QUEUES_PAGE) else 
			       MAPS_data_out_3 when (SPH_dbus_addr_read_3(63 downto 60) = MAPS_PAGE) else
			       QUEUES_data_out_3 when (SPH_dbus_addr_read_0(63 downto 60) = XDP_MD_PAGE) else 
			       STACK_data_out_3 when (SPH_dbus_addr_read_0(63 downto 60) = STACK_PAGE) else 
			       (others => '0');

	INPUT_PIPELINE: process (clk)
	begin

		if rising_edge(clk) then

			S0_AXIS_TDATA_0   <=  S0_AXIS_TDATA; 
			S0_AXIS_TUSER_0   <=  S0_AXIS_TUSER; 
			S0_AXIS_TVALID_0  <=  S0_AXIS_TVALID;
			S0_AXIS_TKEEP_0   <=  S0_AXIS_TKEEP; 
			S0_AXIS_TLAST_0   <=  S0_AXIS_TLAST;
			S0_AXIS_TREADY    <=  S0_AXIS_TREADY_0;

			S0_AXIS_TDATA_1   <=  S0_AXIS_TDATA_0; 
			S0_AXIS_TUSER_1   <=  S0_AXIS_TUSER_0; 
			S0_AXIS_TVALID_1  <=  S0_AXIS_TVALID_0;
			S0_AXIS_TKEEP_1   <=  S0_AXIS_TKEEP_0; 
			S0_AXIS_TLAST_1   <=  S0_AXIS_TLAST_0;
			S0_AXIS_TREADY_0  <=  S0_AXIS_TREADY_1;


		end if;
	end process;

end Behavioral;
