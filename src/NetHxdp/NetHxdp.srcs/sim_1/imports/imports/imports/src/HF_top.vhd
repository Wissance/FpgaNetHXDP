library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity HF_top is
    Port (
             clk	: in std_logic;
             start	: in std_logic;
             done 	: out std_logic;

             ID : in std_logic_vector(7 downto 0);

             R0 	     : out std_logic_vector (63 downto 0);
             write_enable_R0 : out std_logic;

             R1 :  in std_logic_vector (63 downto 0);
             R2 :  in std_logic_vector (63 downto 0);
             R3 :  in std_logic_vector (63 downto 0);
             R4 :  in std_logic_vector (63 downto 0);
             R5 :  in std_logic_vector (63 downto 0);

             --ACTIVE PACKET SELECTOR INTERFACE
             output_ifindex 	: out std_logic_vector(3 downto 0);
             bpf_redirect_wrt 	: out std_logic;

             -- MAPS
             mb_map_index   	   : out std_logic_vector(3 downto 0);
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
end HF_top;

architecture Behavioral of HF_top is

    signal ID_d : std_logic_vector(7 downto 0);
    signal ID_dd : std_logic_vector(7 downto 0);
    -- MAP ACCESS
    signal HF0_R0_s 		:  std_logic_vector (63 downto 0);
    signal HF0_done_s 		: std_logic;
    signal HF0_start_s 		: std_logic;
    signal HF0_write_enable_R0_s 	:  std_logic;
    signal HF0_mb_map_index_s                : std_logic_vector(3 downto 0);
    signal HF0_mb_key_s                : std_logic_vector(63 downto 0);
    signal HF0_mb_value_to_map_s       : std_logic_vector(63 downto 0);
    signal HF0_mb_wrt_en_s             : std_logic;
    signal HF0_mb_ht_lookup_s          : std_logic;
    signal HF0_mb_ht_update_s          : std_logic;
    signal HF0_mb_ht_remove_s          : std_logic;

    -- REDIRECT MAP
    signal HF1_R0_s 		:  std_logic_vector (63 downto 0);
    signal HF1_done_s 		: std_logic;
    signal HF1_start_s 		: std_logic;
    signal HF1_write_enable_R0_s :  std_logic;
    signal HF1_mb_key_s                : std_logic_vector(63 downto 0);
    signal HF1_mb_map_index_s                : std_logic_vector(3 downto 0);
    signal HF1_mb_value_to_map_s       : std_logic_vector(63 downto 0);
    signal HF1_mb_wrt_en_s             : std_logic;
    signal HF1_mb_ht_lookup_s          : std_logic;
    signal HF1_mb_ht_update_s          : std_logic;
    signal HF1_mb_ht_remove_s          : std_logic;
begin


    MAPS_ACCESS: entity work.HF_map_ele port map 
    (
        clk               => clk,
        done 		  => HF0_done_s,
        start 		  => start,

        R0                =>  HF0_R0_s             ,
        write_enable_R0   =>  HF0_write_enable_R0_s,
        R1                =>  R1             ,
        R2                =>  R2             ,
        R3                =>  R3             ,
        R4                =>  R4             ,
        R5                =>  R5             ,
        ID                =>  ID             ,

        mb_map_index      =>  HF0_mb_map_index_s ,
        mb_key            =>  HF0_mb_key_s           ,
        mb_value_to_map   =>  HF0_mb_value_to_map_s  ,
        mb_value_from_map =>  mb_value_from_map,
        mb_wrt_en         =>  HF0_mb_wrt_en_s        ,

        mb_ht_match       =>  mb_ht_match      ,
        mb_ht_lookup      =>  HF0_mb_ht_lookup_s     ,
        mb_ht_update      =>  HF0_mb_ht_update_s     ,
        mb_ht_remove      =>  HF0_mb_ht_remove_s     

    );

    BPF_REDIRECT_MAP: entity work.HF_bpf_redirect_map port map 
    (
        clk               => clk,
        done 		  => HF1_done_s,
        start 		  => start,

        R0                =>  HF1_R0_s             ,
        write_enable_R0   =>  HF1_write_enable_R0_s,
        R1                =>  R1             ,
        R2                =>  R2             ,
        R3                =>  R3             ,
        R4                =>  R4             ,
        R5                =>  R5             ,
        ID                =>  ID             ,

        output_ifindex 	   =>output_ifindex ,	 
        bpf_redirect_wrt   =>bpf_redirect_wrt, 

        mb_map_index      =>  HF1_mb_map_index_s ,
        mb_key            =>  HF1_mb_key_s           ,
        mb_value_to_map   =>  HF1_mb_value_to_map_s  ,
        mb_value_from_map =>  mb_value_from_map,
        mb_wrt_en         =>  HF1_mb_wrt_en_s        ,

        mb_ht_match       =>  mb_ht_match      ,
        mb_ht_lookup      =>  HF1_mb_ht_lookup_s     ,
        mb_ht_update      =>  HF1_mb_ht_update_s     ,
        mb_ht_remove      =>  HF1_mb_ht_remove_s     
    );


    process (clk)
    begin
        if rising_edge(clk) then
            ID_d <= ID;
        end if;
        end process;


        MUX: process (all)
        begin

            HF0_start_s <= '0';
            HF1_start_s <= '0';
            R0 		 <= (others => '0');
            write_enable_R0   <= '0';
            done <= '0';
            mb_map_index <= (others => '0');
            mb_key            <= (others => '0');
            mb_value_to_map   <= (others => '0');
            mb_wrt_en         <= '0';
            mb_ht_lookup      <= '0';
            mb_ht_update      <= '0';
            mb_ht_remove      <= '0';

            case ID_d is

                when x"00" =>
                    R0 		 <= HF0_R0_s 	          ; 	
                    done           <= HF0_done_s;
                    write_enable_R0   <= HF0_write_enable_R0_s ;
                    mb_map_index <= HF0_mb_map_index_s;
                    mb_key            <= HF0_mb_key_s           ;
                    mb_value_to_map   <= HF0_mb_value_to_map_s  ;
                    mb_wrt_en         <= HF0_mb_wrt_en_s        ;     
                    mb_ht_lookup      <= HF0_mb_ht_lookup_s     ;     
                    mb_ht_update      <= HF0_mb_ht_update_s     ;     
                    mb_ht_remove      <= HF0_mb_ht_remove_s     ;     
                when x"01" =>
                    R0 		 <= HF0_R0_s 	          ; 	
                    done           <= HF0_done_s;
                    write_enable_R0   <= HF0_write_enable_R0_s ;
                    mb_map_index <= HF0_mb_map_index_s;
                    mb_key            <= HF0_mb_key_s           ;
                    mb_value_to_map   <= HF0_mb_value_to_map_s  ;
                    mb_wrt_en         <= HF0_mb_wrt_en_s        ;     
                    mb_ht_lookup      <= HF0_mb_ht_lookup_s     ;     
                    mb_ht_update      <= HF0_mb_ht_update_s     ;     
                    mb_ht_remove      <= HF0_mb_ht_remove_s     ;     
                when x"02" =>
                    R0 		 <= HF0_R0_s 	          ; 	
                    done           <= HF0_done_s;
                    write_enable_R0   <= HF0_write_enable_R0_s ;
                    mb_map_index <= HF0_mb_map_index_s;
                    mb_key            <= HF0_mb_key_s           ;
                    mb_value_to_map   <= HF0_mb_value_to_map_s  ;
                    mb_wrt_en         <= HF0_mb_wrt_en_s        ;     
                    mb_ht_lookup      <= HF0_mb_ht_lookup_s     ;     
                    mb_ht_update      <= HF0_mb_ht_update_s     ;     
                    mb_ht_remove      <= HF0_mb_ht_remove_s     ;     
                when x"33" =>
                    R0 		 <= HF1_R0_s 	          ; 	
                    done           <= HF1_done_s;
                    write_enable_R0   <= HF1_write_enable_R0_s ;
                    mb_key            <= HF1_mb_key_s           ;
                    mb_map_index <= HF1_mb_map_index_s;
                    mb_value_to_map   <= HF1_mb_value_to_map_s  ;
                    mb_wrt_en         <= HF1_mb_wrt_en_s        ;     
                    mb_ht_lookup      <= HF1_mb_ht_lookup_s     ;     
                    mb_ht_update      <= HF1_mb_ht_update_s     ;     
                    mb_ht_remove      <= HF1_mb_ht_remove_s     ;     

                when others =>				
                    R0 		 <= (others => '0');
                    write_enable_R0   <= '0';
                    done <= '0';
                    mb_key            <= (others => '0');
                    mb_value_to_map   <= (others => '0');
                    mb_wrt_en         <= '0';
                    mb_ht_lookup      <= '0';
                    mb_ht_update      <= '0';
                    mb_ht_remove      <= '0';
                    mb_map_index <= (others => '0');

            end case;
        end process;

    end Behavioral;
