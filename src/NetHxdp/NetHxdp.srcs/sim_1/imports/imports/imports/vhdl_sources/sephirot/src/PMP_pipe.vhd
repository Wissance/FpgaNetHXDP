library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity lanes is

    port ( 
             clk        :in std_logic;
             reset      :in std_logic;
             decode_flush 	: in std_logic;

             -- HF RESULT BROADCAST
             hf_result : in std_logic_vector(63 downto 0);
             hf_we : in std_logic;

             -- SYLLABLES FROM FETCH STAGE
             syllable_0 :in std_logic_vector(63 downto 0);   
             syllable_1 :in std_logic_vector(63 downto 0);
             syllable_2 :in std_logic_vector(63 downto 0);
             syllable_3 :in std_logic_vector(63 downto 0);

             -- OPERANDS FROM GPR PREFETCHED
             gr_0_src : in std_logic_vector(63 downto 0);  -- operands data
             gr_0_dst : in std_logic_vector(63 downto 0);

             gr_1_src : in std_logic_vector(63 downto 0);
             gr_1_dst : in std_logic_vector(63 downto 0);

             gr_2_src : in std_logic_vector(63 downto 0);
             gr_2_dst : in std_logic_vector(63 downto 0);

             gr_3_src : in std_logic_vector(63 downto 0);
             gr_3_dst : in std_logic_vector(63 downto 0);

             -- ADDRESS OF OPERANDS FROM FETCH STAGE
             gr_add_0_s : in std_logic_vector(3 downto 0); -- operands address
             gr_add_0_d : in std_logic_vector(3 downto 0);

             gr_add_1_s : in std_logic_vector(3 downto 0);
             gr_add_1_d : in std_logic_vector(3 downto 0);

             gr_add_2_s : in std_logic_vector(3 downto 0);
             gr_add_2_d : in std_logic_vector(3 downto 0);

             gr_add_3_s : in std_logic_vector(3 downto 0);
             gr_add_3_d : in std_logic_vector(3 downto 0);

             -- GPR WRITEBACK ADDRESS
             gr_add_dst_wb_0 : out std_logic_vector(3 downto 0);  --addresses for destination
             gr_add_dst_wb_1 : out std_logic_vector(3 downto 0);
             gr_add_dst_wb_2 : out std_logic_vector(3 downto 0);
             gr_add_dst_wb_3 : out std_logic_vector(3 downto 0);

             -- GPR WRITEBACK RESULT
             gr_rsl_0 : out std_logic_vector(63 downto 0); -- results to destination
             gr_rsl_1 : out std_logic_vector(63 downto 0);
             gr_rsl_2 : out std_logic_vector(63 downto 0);
             gr_rsl_3 : out std_logic_vector(63 downto 0);

             -- GPR WRITEBACK ENABLE
             gr_wrt_en_0 : out std_logic; -- write enable for destination 
             gr_wrt_en_1 : out std_logic;
             gr_wrt_en_2 : out std_logic;
             gr_wrt_en_3 : out std_logic;

             -- MEMORY INTERFACE
             mem_add_wrt_0  : out std_logic_vector(63 downto 0); -- write address for memory
             mem_add_read_0 : out std_logic_vector(63 downto 0); -- read address for memory
             mem_data_out_0 : out std_logic_vector(63 downto 0); -- data to write to memory
             mem_wrt_mask_0 : out std_logic_vector(63 downto 0);  -- number of bits written to memory
             mem_data_in_0  : in std_logic_vector(63 downto 0);  -- Data from memory
             mem_w_e_0      : out std_logic;                     -- memory write enable

             mem_add_wrt_1  : out std_logic_vector(63 downto 0); -- write address for memory
             mem_add_read_1 : out std_logic_vector(63 downto 0); -- read address for memory
             mem_data_out_1 : out std_logic_vector(63 downto 0); -- data to write to memory
             mem_wrt_mask_1 : out std_logic_vector(63 downto 0);  -- number of bits written to memory
             mem_data_in_1  : in std_logic_vector(63 downto 0);  -- Data from memory
             mem_w_e_1      : out std_logic;                     -- memory write enable

             mem_add_wrt_2  : out std_logic_vector(63 downto 0); -- write address for memory
             mem_add_read_2 : out std_logic_vector(63 downto 0); -- read address for memory
             mem_data_out_2 : out std_logic_vector(63 downto 0); -- data to write to memory
             mem_wrt_mask_2 : out std_logic_vector(63 downto 0);  -- number of bits written to memory
             mem_data_in_2 : in std_logic_vector(63 downto 0);  -- Data from memory
             mem_w_e_2      : out std_logic;                     -- memory write enable

             mem_add_wrt_3  : out std_logic_vector(63 downto 0); -- write address for memory
             mem_add_read_3 : out std_logic_vector(63 downto 0); -- read address for memory
             mem_data_out_3 : out std_logic_vector(63 downto 0); -- data to write to memory
             mem_wrt_mask_3 : out std_logic_vector(63 downto 0);  -- number of bits written to memory
             mem_data_in_3  : in std_logic_vector(63 downto 0);  -- Data from memory
             mem_w_e_3      : out std_logic;                     -- memory write enable

             -- PROGRAM COUNTER INTERFACE

             PC_addr          : out std_logic_vector(15 downto 0); --address to add to PC
             PC_add           : out std_logic;
             PC_stop          : out std_logic;
             PC_load          : out std_logic;
             pc_idle          : in std_logic;
             exit_detected    : out std_logic;

             --HELPER FUNCTION INTERFACE
             helper_function_id : out std_logic_vector(7 downto 0)


         );
end lanes;

architecture Behavioral of lanes is

    signal flush_pipeline_s : std_logic;
    signal stop_s : std_logic;

    signal	gr_add_dst_wb_0_s :  std_logic_vector(3 downto 0);  --addresses for destination
    signal	gr_add_dst_wb_1_s :  std_logic_vector(3 downto 0);
    signal	gr_add_dst_wb_2_s :  std_logic_vector(3 downto 0);
    signal	gr_add_dst_wb_3_s :  std_logic_vector(3 downto 0);
    signal	gr_rsl_0_s :  std_logic_vector(63 downto 0); -- results to destination
    signal	gr_rsl_1_s :  std_logic_vector(63 downto 0);
    signal	gr_rsl_2_s :  std_logic_vector(63 downto 0);
    signal	gr_rsl_3_s :  std_logic_vector(63 downto 0);
    signal	gr_wrt_en_0_s :  std_logic; -- write enable for destination 
    signal	gr_wrt_en_1_s :  std_logic;
    signal	gr_wrt_en_2_s :  std_logic;
    signal	gr_wrt_en_3_s :  std_logic;

    signal PC_addr_0          :  std_logic_vector(15 downto 0); --address to add to PC
    signal PC_add_0           :  std_logic;
    signal PC_stop_0          :  std_logic;
    signal PC_load_0          :  std_logic;
    signal exit_detected_0    :  std_logic;
    signal branch_here_0      : std_logic;
    signal helper_function_id_0 : std_logic_vector(7 downto 0);

    signal PC_addr_1          :  std_logic_vector(15 downto 0); --address to add to PC
    signal PC_add_1           :  std_logic;
    signal PC_stop_1          :  std_logic;
    signal PC_load_1          :  std_logic;
    signal exit_detected_1    :  std_logic;
    signal branch_here_1      : std_logic;
    signal helper_function_id_1 : std_logic_vector(7 downto 0);

    signal PC_addr_2          :  std_logic_vector(15 downto 0); --address to add to PC
    signal PC_add_2           :  std_logic;
    signal PC_stop_2          :  std_logic;
    signal PC_load_2          :  std_logic;
    signal exit_detected_2    :  std_logic;
    signal branch_here_2      : std_logic;
    signal helper_function_id_2 : std_logic_vector(7 downto 0);

    signal PC_addr_3          :  std_logic_vector(15 downto 0); --address to add to PC
    signal PC_add_3           :  std_logic;
    signal PC_stop_3          :  std_logic;
    signal PC_load_3          :  std_logic;
    signal exit_detected_3    :  std_logic;
    signal branch_here_3      : std_logic;
    signal helper_function_id_3 : std_logic_vector(7 downto 0);
begin


    LANE_0: entity work.lane_0 port map 
    (

        clk   => clk,     
        reset => reset,     
        decode_flush => decode_flush,

        hf_result => hf_result  ,
        hf_we => hf_we  ,
        syllable_0 => syllable_0,

        add_src    => gr_add_0_s, 
        add_dst    => gr_add_0_d,
        gr_src_cont => gr_0_src,              
        gr_dst_cont => gr_0_dst,              

        addr_wb_0 =>gr_add_dst_wb_0_s,
        addr_wb_1 =>gr_add_dst_wb_1_s,
        addr_wb_2 =>gr_add_dst_wb_2_s,
        addr_wb_3 =>gr_add_dst_wb_3_s,

        wb_wrt_en_0 =>gr_wrt_en_0_s,
        wb_wrt_en_1 =>gr_wrt_en_1_s,
        wb_wrt_en_2 =>gr_wrt_en_2_s,
        wb_wrt_en_3 =>gr_wrt_en_3_s,

        cont_wb_0 =>gr_rsl_0_s ,
        cont_wb_1 =>gr_rsl_1_s ,
        cont_wb_2 =>gr_rsl_2_s ,
        cont_wb_3 =>gr_rsl_3_s ,

        exe_result => gr_rsl_0_s,      
        w_e_wb  => gr_wrt_en_0_s,         
        wb_reg_add => gr_add_dst_wb_0_s,       

        mem_data_in  => mem_data_in_0,    
        mem_data_out => mem_data_out_0,    
        mem_read_addr => mem_add_read_0,     
        mem_wrt_addr  => mem_add_wrt_0,   
        mem_wrt_en  => mem_w_e_0,     
        mem_wrt_mask => mem_wrt_mask_0,

        pc_addr => PC_addr_0,          
        pc_add => PC_add_0,              
        PC_stop => PC_stop_0,          
        pc_load => PC_load_0,
        pc_idle => pc_idle,
        branch_here => branch_here_0,
        exit_detected => exit_detected_0,
        helper_function_id => helper_function_id_0

    );

    LANE_1: entity work.lane_0 port map 
    (

        clk   => clk,     
        reset => reset,     
        decode_flush => decode_flush,

        hf_result => hf_result  ,
        hf_we => hf_we  ,
        syllable_0 => syllable_1,

        add_src    => gr_add_1_s, 
        add_dst    => gr_add_1_d,
        gr_src_cont => gr_1_src,              
        gr_dst_cont => gr_1_dst,              

        addr_wb_0 =>gr_add_dst_wb_0_s,
        addr_wb_1 =>gr_add_dst_wb_1_s,
        addr_wb_2 =>gr_add_dst_wb_2_s,
        addr_wb_3 =>gr_add_dst_wb_3_s,

        wb_wrt_en_0 =>gr_wrt_en_0_s,
        wb_wrt_en_1 =>gr_wrt_en_1_s,
        wb_wrt_en_2 =>gr_wrt_en_2_s,
        wb_wrt_en_3 =>gr_wrt_en_3_s,

        cont_wb_0 =>gr_rsl_0_s ,
        cont_wb_1 =>gr_rsl_1_s ,
        cont_wb_2 =>gr_rsl_2_s ,
        cont_wb_3 =>gr_rsl_3_s ,

        exe_result => gr_rsl_1_s,      
        w_e_wb  => gr_wrt_en_1_s,         
        wb_reg_add => gr_add_dst_wb_1_s,       

        mem_data_in  => mem_data_in_1,    
        mem_data_out => mem_data_out_1,    
        mem_read_addr => mem_add_read_1,     
        mem_wrt_addr  => mem_add_wrt_1,   
        mem_wrt_en  => mem_w_e_1  ,   
        mem_wrt_mask => mem_wrt_mask_1,

        pc_addr => PC_addr_1,          
        pc_add => PC_add_1,              
        PC_stop => PC_stop_1,          
        pc_load => PC_load_1,
        pc_idle => pc_idle,
        branch_here => branch_here_1,
        exit_detected => exit_detected_1,
        helper_function_id => helper_function_id_1


    );


    LANE_2: entity work.lane_0 port map 
    (

        clk   => clk,     
        reset => reset,     
        decode_flush => decode_flush,
        hf_result => hf_result  ,
        hf_we => hf_we  ,

        syllable_0 => syllable_2,

        add_src    => gr_add_2_s, 
        add_dst    => gr_add_2_d,
        gr_src_cont => gr_2_src,              
        gr_dst_cont => gr_2_dst,              

        addr_wb_0 =>gr_add_dst_wb_0_s,
        addr_wb_1 =>gr_add_dst_wb_1_s,
        addr_wb_2 =>gr_add_dst_wb_2_s,
        addr_wb_3 =>gr_add_dst_wb_3_s,

        wb_wrt_en_0 =>gr_wrt_en_0_s,
        wb_wrt_en_1 =>gr_wrt_en_1_s,
        wb_wrt_en_2 =>gr_wrt_en_2_s,
        wb_wrt_en_3 =>gr_wrt_en_3_s,

        cont_wb_0 =>gr_rsl_0_s ,
        cont_wb_1 =>gr_rsl_1_s ,
        cont_wb_2 =>gr_rsl_2_s ,
        cont_wb_3 =>gr_rsl_3_s ,

        exe_result => gr_rsl_2_s,      
        w_e_wb  => gr_wrt_en_2_s,         
        wb_reg_add => gr_add_dst_wb_2_s,       

        mem_data_in  => mem_data_in_2,    
        mem_data_out => mem_data_out_2,    
        mem_read_addr => mem_add_read_2,     
        mem_wrt_addr  => mem_add_wrt_2,   
        mem_wrt_en  => mem_w_e_2,     
        mem_wrt_mask => mem_wrt_mask_2,

        pc_addr => PC_addr_2,          
        pc_add => PC_add_2,              
        PC_stop => PC_stop_2,          
        pc_load => PC_load_2,
        pc_idle => pc_idle,
        branch_here => branch_here_2,
        exit_detected => exit_detected_2,
        helper_function_id => helper_function_id_2


    );

    LANE_3: entity work.lane_0 port map 
    (

        clk   => clk,     
        reset => reset,     
        decode_flush => decode_flush,

        hf_result => hf_result  ,
        hf_we => hf_we  ,
        syllable_0 => syllable_3,

        add_src    => gr_add_3_s, 
        add_dst    => gr_add_3_d,
        gr_src_cont => gr_3_src,              
        gr_dst_cont => gr_3_dst,              

        addr_wb_0 =>gr_add_dst_wb_0_s,
        addr_wb_1 =>gr_add_dst_wb_1_s,
        addr_wb_2 =>gr_add_dst_wb_2_s,
        addr_wb_3 =>gr_add_dst_wb_3_s,

        wb_wrt_en_0 =>gr_wrt_en_0_s,
        wb_wrt_en_1 =>gr_wrt_en_1_s,
        wb_wrt_en_2 =>gr_wrt_en_2_s,
        wb_wrt_en_3 =>gr_wrt_en_3_s,

        cont_wb_0 =>gr_rsl_0_s ,
        cont_wb_1 =>gr_rsl_1_s ,
        cont_wb_2 =>gr_rsl_2_s ,
        cont_wb_3 =>gr_rsl_3_s ,

        exe_result => gr_rsl_3_s,      
        w_e_wb  => gr_wrt_en_3_s,         
        wb_reg_add => gr_add_dst_wb_3_s,       

        mem_data_in  => mem_data_in_3,    
        mem_data_out => mem_data_out_3,    
        mem_read_addr => mem_add_read_3,     
        mem_wrt_addr  => mem_add_wrt_3,   
        mem_wrt_en  => mem_w_e_3 ,    
        mem_wrt_mask => mem_wrt_mask_3,

        pc_addr => PC_addr_3,          
        pc_add => PC_add_3,              
        PC_stop => PC_stop_3,          
        pc_load => PC_load_3,
        pc_idle => pc_idle,
        branch_here => branch_here_3,
        exit_detected => exit_detected_3,
        helper_function_id => helper_function_id_3


    );

    gr_add_dst_wb_0	<=gr_add_dst_wb_0_s;
    gr_add_dst_wb_1	<=gr_add_dst_wb_1_s;
    gr_add_dst_wb_2	<=gr_add_dst_wb_2_s;
    gr_add_dst_wb_3	<=gr_add_dst_wb_3_s;

    gr_wrt_en_0	<=gr_wrt_en_0_s;
    gr_wrt_en_1	<=gr_wrt_en_1_s;
    gr_wrt_en_2	<=gr_wrt_en_2_s;
    gr_wrt_en_3	<=gr_wrt_en_3_s;

    gr_rsl_0	<=gr_rsl_0_s ;
    gr_rsl_1	<=gr_rsl_1_s ;
    gr_rsl_2	<=gr_rsl_2_s ;
    gr_rsl_3	<=gr_rsl_3_s ;

    PC_ACCESS_MUX: process(all)
    begin
            
        PC_addr          <= (others => '0');       
        PC_add           <= '0';       
        PC_stop          <= '0';       
        PC_load          <= '0';       
        exit_detected    <= '0'; 
        helper_function_id <= (others => '0');

        if (branch_here_0 = '1') then
            PC_addr          <= PC_addr_0;       
            PC_add           <= PC_add_0 ;       
            PC_stop          <= PC_stop_0;       
            PC_load          <= PC_load_0;       
            exit_detected    <= exit_detected_0; 
            helper_function_id <= helper_function_id_0;

        elsif(branch_here_1 = '1') then
            PC_addr          <= PC_addr_1;       
            PC_add           <= PC_add_1 ;       
            PC_stop          <= PC_stop_1;       
            PC_load          <= PC_load_1;       
            exit_detected    <= exit_detected_1; 
            helper_function_id <= helper_function_id_1;

        elsif(branch_here_2 = '1') then
            PC_addr          <= PC_addr_2;       
            PC_add           <= PC_add_2 ;       
            PC_stop          <= PC_stop_2;       
            PC_load          <= PC_load_2;       
            exit_detected    <= exit_detected_2; 
            helper_function_id <= helper_function_id_2;

        elsif(branch_here_3 = '1') then
            PC_addr          <= PC_addr_3;       
            PC_add           <= PC_add_3 ;       
            PC_stop          <= PC_stop_3;       
            PC_load          <= PC_load_3;       
            exit_detected    <= exit_detected_3; 
            helper_function_id <= helper_function_id_3;

        end if;


    end process;

end Behavioral;
