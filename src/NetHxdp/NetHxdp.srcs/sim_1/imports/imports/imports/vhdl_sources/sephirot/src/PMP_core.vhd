library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common_pkg.all;

entity PMP_core is

	generic (
			XDP_MD_PAGE : std_logic_vector(3 downto 0) := x"1";
			STACK_PAGE : std_logic_vector(3 downto 0) := x"2"
		);

	Port ( 
		     clk           : in std_logic;
		     reset         : in std_logic;
		     start         : in std_logic;
		     exit_detected : out std_logic;

		     instr_data   : in std_logic_vector(255 downto 0);
		     instr_addr   : out std_logic_vector(15 downto 0);


		     -- interface for helper functions
		     gpr_0_out  : out std_logic_vector(63 downto 0);
		     gpr_1   : out std_logic_vector(63 downto 0);
		     gpr_2   : out std_logic_vector(63 downto 0);
		     gpr_3   : out std_logic_vector(63 downto 0);
		     gpr_4   : out std_logic_vector(63 downto 0);
		     gpr_5   : out std_logic_vector(63 downto 0);

		     gpr_0_in    : in std_logic_vector(63 downto 0);
		     w_e_0_hf : in std_logic;

		     -- Data Bus Interface

		     dbus_data_in_0  : in std_logic_vector(63 downto 0);
		     dbus_data_in_1  : in std_logic_vector(63 downto 0);
		     dbus_data_in_2  : in std_logic_vector(63 downto 0);
		     dbus_data_in_3  : in std_logic_vector(63 downto 0);

		     dbus_data_out_0 : out std_logic_vector(63 downto 0); 
		     dbus_data_out_1 : out std_logic_vector(63 downto 0);  
		     dbus_data_out_2 : out std_logic_vector(63 downto 0);  
		     dbus_data_out_3 : out std_logic_vector(63 downto 0);  

		     dbus_data_mask_0 : out std_logic_vector(63 downto 0);
		     dbus_data_mask_1 : out std_logic_vector(63 downto 0);
		     dbus_data_mask_2 : out std_logic_vector(63 downto 0);
		     dbus_data_mask_3 : out std_logic_vector(63 downto 0);

		     dbus_addr_read_0    : out std_logic_vector(63 downto 0);
		     dbus_addr_read_1    : out std_logic_vector(63 downto 0);
		     dbus_addr_read_2    : out std_logic_vector(63 downto 0);
		     dbus_addr_read_3    : out std_logic_vector(63 downto 0);

		     dbus_addr_wrt_0   : out std_logic_vector(63 downto 0); -- base addresses to write (set the starting bit)
		     dbus_addr_wrt_1   : out std_logic_vector(63 downto 0);
		     dbus_addr_wrt_2   : out std_logic_vector(63 downto 0);
		     dbus_addr_wrt_3   : out std_logic_vector(63 downto 0);

		     dbus_wrt_en_0      : out std_logic;
		     dbus_wrt_en_1      : out std_logic;
		     dbus_wrt_en_2      : out std_logic;
		     dbus_wrt_en_3      : out std_logic;

		     -- HELPER FUNCTION INTERFACE
		     helper_function_done   : in std_logic;
             helper_function_start  : out std_logic;
		     helper_function_id     : out std_logic_vector(7 downto 0)


	     );
end PMP_core;

architecture Behavioral of PMP_core is

	signal stop_s        : std_logic := '0';
	signal reset_s       : std_logic;
	signal early_exit    : std_logic;
	signal xdp_action_fetch : std_logic_vector(31 downto 0);
	signal gpr_0_out_s : std_logic_vector(63 downto 0);

	-- Instruction Memory Interface
	signal imem_addr_s     :  std_logic_vector(15 downto 0);
	signal imem_instr_s    :  std_logic_vector(255 downto 0);

	signal syllable_0_fetch : std_logic_vector(63 downto 0);
	signal syllable_1_fetch : std_logic_vector(63 downto 0);
	signal syllable_2_fetch : std_logic_vector(63 downto 0);
	signal syllable_3_fetch : std_logic_vector(63 downto 0);

	signal syllable_0_gpr : std_logic_vector(63 downto 0);
	signal syllable_1_gpr : std_logic_vector(63 downto 0);
	signal syllable_2_gpr : std_logic_vector(63 downto 0);
	signal syllable_3_gpr : std_logic_vector(63 downto 0);

	-- GPR INTERFACE
	signal add_src_0         : std_logic_vector(3 downto 0);
	signal add_src_0_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_0_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_0_exe     : std_logic_vector(3 downto 0);
	signal add_dst_0_fetch   : std_logic_vector(3 downto 0);
	signal w_e_0             : std_logic;
	signal cont_src_0        : std_logic_vector(63 downto 0);
	signal cont_dst_0_exe    : std_logic_vector(63 downto 0);
	signal cont_dst_0_fetch  : std_logic_vector(63 downto 0);

	signal add_src_1         : std_logic_vector(3 downto 0);
	signal add_src_1_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_1_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_1_exe     : std_logic_vector(3 downto 0);
	signal add_dst_1_fetch   : std_logic_vector(3 downto 0);
	signal w_e_1             : std_logic;
	signal cont_src_1        : std_logic_vector(63 downto 0);
	signal cont_dst_1_exe    : std_logic_vector(63 downto 0);
	signal cont_dst_1_fetch  : std_logic_vector(63 downto 0);

	signal add_src_2         : std_logic_vector(3 downto 0);
	signal add_src_2_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_2_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_2_exe     : std_logic_vector(3 downto 0);
	signal add_dst_2_fetch   : std_logic_vector(3 downto 0);
	signal w_e_2             : std_logic;
	signal cont_src_2        : std_logic_vector(63 downto 0);
	signal cont_dst_2_exe    : std_logic_vector(63 downto 0);
	signal cont_dst_2_fetch  : std_logic_vector(63 downto 0);

	signal add_src_3         : std_logic_vector(3 downto 0);
	signal add_src_3_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_3_to_dec  : std_logic_vector(3 downto 0);
	signal add_dst_3_exe     : std_logic_vector(3 downto 0);
	signal add_dst_3_fetch   : std_logic_vector(3 downto 0);
	signal w_e_3             : std_logic;
	signal cont_src_3        : std_logic_vector(63 downto 0);
	signal cont_dst_3_exe    : std_logic_vector(63 downto 0);
	signal cont_dst_3_fetch  : std_logic_vector(63 downto 0);

	-- PROGRAM COUNTER INTERFACE
	signal PC_new_addr       : std_logic_vector(15 downto 0);
	signal PC_increment      : std_logic;
	signal PC_add            : std_logic;
	signal PC_stop           : std_logic;
	signal PC_load           : std_logic;
	signal reset_units_s   : std_logic;
	signal exit_detected_s   : std_logic;
	signal fetch_flush_s     : std_logic;
	signal decode_flush_s    : std_logic;
	signal gpr_flush_s     : std_logic;
	signal exe_masquerade_s  : std_logic;

begin


	PC_UNIT: entity work.pmp_control_unit port map 
	( 
		clk => clk,        
		start => start,      
		rst => (reset_s or exit_detected_s or early_exit),       

		reset_units => reset_units_s,
		fetch_flush => fetch_flush_s,
		decode_flush => decode_flush_s,
		gpr_flush => gpr_flush_s,
		exe_masquerade => exe_masquerade_s,
		pc_addr => PC_new_addr,  
		pc_add => PC_add,     
		PC_stop => PC_stop,
		pc_load => PC_load, 
		pc_resume => helper_function_done, 

		PC => instr_addr  
	);  

	IF_STAGE: entity work.fetch_stage port map 
	(

		clk  => clk,       
		reset => (reset_units_s) ,    
		fetch_flush => fetch_flush_s ,
		instr => instr_data,      
        pc_idle => exe_masquerade_s,

		early_exit => early_exit,
		xdp_action => xdp_action_fetch,

		syllable_0 => syllable_0_fetch, 
		syllable_1 => syllable_1_fetch, 
		syllable_2 => syllable_2_fetch, 
		syllable_3 => syllable_3_fetch, 

		-- General purpose registers prefetch

		gr_src_0 =>  add_src_0,
		gr_src_1 =>  add_src_1,
		gr_src_2 =>  add_src_2,
		gr_src_3 =>  add_src_3, 

		gr_dst_0 =>  add_dst_0_fetch,
		gr_dst_1 =>  add_dst_1_fetch,
		gr_dst_2 =>  add_dst_2_fetch,
		gr_dst_3 =>  add_dst_3_fetch

	);  

	GPR_FILE: entity work.gr_regfile 
	generic map
	(
		XDP_MD_PAGE => XDP_MD_PAGE,
		STACK_PAGE => STACK_PAGE
	)
	port map 
	(
		clk => clk,
		rst => (reset_units_s),
		flush_pipeline => gpr_flush_s,
        pc_idle => exe_masquerade_s,

		gpr_1    =>    gpr_1,   
		gpr_2    =>    gpr_2,   
		gpr_3    =>    gpr_3,   
		gpr_4    =>    gpr_4,   
		gpr_5    =>    gpr_5,   
		gpr_0_in    =>    gpr_0_in,   
		gpr_0_out    =>    gpr_0_out_s,   
		w_e_0_hf =>    w_e_0_hf,

		syllable_0_in => syllable_0_fetch,
		syllable_1_in => syllable_1_fetch,
		syllable_2_in => syllable_2_fetch,
		syllable_3_in => syllable_3_fetch,

		syllable_0_out => syllable_0_gpr,
		syllable_1_out => syllable_1_gpr,
		syllable_2_out => syllable_2_gpr,
		syllable_3_out => syllable_3_gpr,

		add_src_0 => add_src_0,          
		add_src_0_to_dec => add_src_0_to_dec,          
		add_dst_0_to_dec => add_dst_0_to_dec,          
		add_dst_0_exe => add_dst_0_exe,    
		add_dst_0_fetch => add_dst_0_fetch,  
		w_e_0 => w_e_0,            
		cont_src_0 => cont_src_0,        
		cont_dst_0_exe => cont_dst_0_exe,    
		cont_dst_0_fetch => cont_dst_0_fetch, 

		add_src_1 => add_src_1,          
		add_src_1_to_dec => add_src_1_to_dec,          
		add_dst_1_to_dec => add_dst_1_to_dec,          
		add_dst_1_exe => add_dst_1_exe,    
		add_dst_1_fetch => add_dst_1_fetch,  
		w_e_1 => w_e_1,            
		cont_src_1 => cont_src_1,        
		cont_dst_1_exe => cont_dst_1_exe,    
		cont_dst_1_fetch => cont_dst_1_fetch, 

		add_src_2 => add_src_2,          
		add_src_2_to_dec => add_src_2_to_dec,          
		add_dst_2_to_dec => add_dst_2_to_dec,          
		add_dst_2_exe => add_dst_2_exe,    
		add_dst_2_fetch => add_dst_2_fetch,  
		w_e_2 => w_e_2,            
		cont_src_2 => cont_src_2,        
		cont_dst_2_exe => cont_dst_2_exe,    
		cont_dst_2_fetch => cont_dst_2_fetch, 

		add_src_3 => add_src_3,          
		add_src_3_to_dec => add_src_3_to_dec,          
		add_dst_3_to_dec => add_dst_3_to_dec,          
		add_dst_3_exe => add_dst_3_exe,    
		add_dst_3_fetch => add_dst_3_fetch,  
		w_e_3 => w_e_3,            
		cont_src_3 => cont_src_3,        
		cont_dst_3_exe => cont_dst_3_exe,    
		cont_dst_3_fetch => cont_dst_3_fetch 

	);


	LANES: entity work.lanes port map 
	(

		clk => clk,
		reset => (reset_units_s),
		decode_flush => decode_flush_s,
		pc_idle => exe_masquerade_s,
		--stop => stop_s,        
		hf_result=>    gpr_0_in,   
		hf_we =>    w_e_0_hf,

		syllable_0 =>  syllable_0_gpr,  
		syllable_1 =>  syllable_1_gpr,
		syllable_2 =>  syllable_2_gpr,
		syllable_3 =>  syllable_3_gpr,

		gr_0_src => cont_src_0,
		gr_0_dst => cont_dst_0_fetch,

		gr_1_src => cont_src_1,
		gr_1_dst => cont_dst_1_fetch,

		gr_2_src => cont_src_2,
		gr_2_dst => cont_dst_2_fetch,

		gr_3_src => cont_src_3,
		gr_3_dst => cont_dst_3_fetch,

		gr_add_0_s => add_src_0_to_dec,  
		gr_add_0_d => add_dst_0_to_dec,

		gr_add_1_s => add_src_1_to_dec,  
		gr_add_1_d => add_dst_1_to_dec,

		gr_add_2_s => add_src_2_to_dec,  
		gr_add_2_d => add_dst_2_to_dec,

		gr_add_3_s => add_src_3_to_dec,  
		gr_add_3_d => add_dst_3_to_dec,

		gr_add_dst_wb_0 => add_dst_0_exe,  
		gr_add_dst_wb_1 => add_dst_1_exe,  
		gr_add_dst_wb_2 => add_dst_2_exe,  
		gr_add_dst_wb_3 => add_dst_3_exe,  

		gr_rsl_0 => cont_dst_0_exe, 
		gr_rsl_1 => cont_dst_1_exe,
		gr_rsl_2 => cont_dst_2_exe,
		gr_rsl_3 => cont_dst_3_exe,

		gr_wrt_en_0 => w_e_0, 
		gr_wrt_en_1 => w_e_1,
		gr_wrt_en_2 => w_e_2,
		gr_wrt_en_3 => w_e_3,

		mem_add_wrt_0 => dbus_addr_wrt_0, 
		mem_add_read_0 => dbus_addr_read_0,
		mem_data_out_0 => dbus_data_out_0,
		mem_wrt_mask_0 => dbus_data_mask_0,
		mem_data_in_0 => dbus_data_in_0, 
		mem_w_e_0 => dbus_wrt_en_0,     

		mem_add_wrt_1 => dbus_addr_wrt_1, 
		mem_add_read_1 => dbus_addr_read_1,
		mem_data_out_1 => dbus_data_out_1,
		mem_wrt_mask_1 => dbus_data_mask_1,
		mem_data_in_1 => dbus_data_in_1, 
		mem_w_e_1 => dbus_wrt_en_1,     

		mem_add_wrt_2 => dbus_addr_wrt_2, 
		mem_add_read_2 => dbus_addr_read_2,
		mem_data_out_2 => dbus_data_out_2,
		mem_wrt_mask_2 => dbus_data_mask_2,
		mem_data_in_2 => dbus_data_in_2, 
		mem_w_e_2 => dbus_wrt_en_2,     

		mem_add_wrt_3 => dbus_addr_wrt_3, 
		mem_add_read_3 => dbus_addr_read_3,
		mem_data_out_3 => dbus_data_out_3,
		mem_wrt_mask_3 => dbus_data_mask_3,
		mem_data_in_3 => dbus_data_in_3, 
		mem_w_e_3 => dbus_wrt_en_3,     

		-- PROGRAM COUNTER INTERFACE

		PC_addr => PC_new_addr, 
		PC_add  => PC_add,
		PC_stop => PC_stop,
		PC_load => PC_load,
		exit_detected => exit_detected_s,
		helper_function_id => helper_function_id

	);


	reset_s <= reset ;
	exit_detected <= exit_detected_s or early_exit;

	gpr_0_out <= x"00000000" & xdp_action_fetch when early_exit = '1' else
		        gpr_0_out_s;

    helper_function_start <= PC_stop;

end Behavioral;
