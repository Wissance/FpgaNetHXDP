library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common_pkg.all;
entity fetch_stage is

    generic (

                SYLLABLE_0_OFFSET : integer :=0; 
                SYLLABLE_1_OFFSET : integer :=64;
                SYLLABLE_2_OFFSET : integer :=128;
                SYLLABLE_3_OFFSET : integer :=192

            );

    port ( 
             clk            : in std_logic; -- system clock
             reset          : in std_logic; -- system reset
             instr          : in std_logic_vector(255 downto 0); -- instruction ==> 8 syllables
             fetch_flush    : in std_logic;
             pc_idle        : in std_logic;

             syllable_0 : out std_logic_vector(63 downto 0); -- syllable 0
             syllable_1 : out std_logic_vector(63 downto 0); -- syllable 1
             syllable_2 : out std_logic_vector(63 downto 0); -- syllable 2
             syllable_3 : out std_logic_vector(63 downto 0); -- syllable 3

             -- Early Exit interface
             early_exit : out std_logic;
             xdp_action : out std_logic_vector(31 downto 0);

             -- General purpose registers prefetch

             gr_src_0     : out std_logic_vector (3 downto 0); -- address of first operand of syllable 0
             gr_src_1     : out std_logic_vector (3 downto 0);
             gr_src_2     : out std_logic_vector (3 downto 0);
             gr_src_3     : out std_logic_vector (3 downto 0); 

             gr_dst_0     : out std_logic_vector (3 downto 0); -- address of first operand of syllable 0
             gr_dst_1     : out std_logic_vector (3 downto 0);
             gr_dst_2     : out std_logic_vector (3 downto 0);
             gr_dst_3     : out std_logic_vector (3 downto 0) 

         );

end entity fetch_stage;

architecture behavioural of fetch_stage is

    signal syllable_0_s : std_logic_vector(63 downto 0); -- syllable 0
    signal syllable_1_s : std_logic_vector(63 downto 0); -- syllable 1
    signal syllable_2_s : std_logic_vector(63 downto 0); -- syllable 2
    signal syllable_3_s : std_logic_vector(63 downto 0); -- syllable 3

    signal gr_src_0_s   : std_logic_vector (3 downto 0); -- address of first operand of syllable 0
    signal gr_src_1_s   : std_logic_vector (3 downto 0);
    signal gr_src_2_s   : std_logic_vector (3 downto 0);
    signal gr_src_3_s   : std_logic_vector (3 downto 0); 

    signal gr_dst_0_s   : std_logic_vector (3 downto 0); -- address of first operand of syllable 0
    signal gr_dst_1_s   : std_logic_vector (3 downto 0);
    signal gr_dst_2_s   : std_logic_vector (3 downto 0);
    signal gr_dst_3_s   : std_logic_vector (3 downto 0);

begin	

    -- Output
    fetch_out : process(clk)
    begin

        if rising_edge(clk) then

            -- Default case
            if (reset = '1') or (fetch_flush = '1') then

                syllable_0 <= (others => '0'); 
                syllable_1 <= (others => '0'); 
                syllable_2 <= (others => '0'); 
                syllable_3 <= (others => '0'); 

                gr_src_0 <= (others => '0');  
                gr_src_1 <= (others => '0'); 
                gr_src_2 <= (others => '0'); 
                gr_src_3 <= (others => '0'); 

                gr_dst_0 <= (others => '0'); 
                gr_dst_1 <= (others => '0'); 
                gr_dst_2 <= (others => '0'); 
                gr_dst_3 <= (others => '0'); 

                early_exit <= '0';
                xdp_action <= (others => '0');

            else

                if (pc_idle = '0') then

                    syllable_0 <= instr(SYLLABLE_0_OFFSET+63 downto SYLLABLE_0_OFFSET);
                    syllable_1 <= instr(SYLLABLE_1_OFFSET+63 downto SYLLABLE_1_OFFSET);
                    syllable_2 <= instr(SYLLABLE_2_OFFSET+63 downto SYLLABLE_2_OFFSET);
                    syllable_3 <= instr(SYLLABLE_3_OFFSET+63 downto SYLLABLE_3_OFFSET);

                    gr_src_0 <= instr(15+SYLLABLE_0_OFFSET downto 12+SYLLABLE_0_OFFSET);
                    gr_src_1 <= instr(15+SYLLABLE_1_OFFSET downto 12+SYLLABLE_1_OFFSET);
                    gr_src_2 <= instr(15+SYLLABLE_2_OFFSET downto 12+SYLLABLE_2_OFFSET);
                    gr_src_3 <= instr(15+SYLLABLE_3_OFFSET downto 12+SYLLABLE_3_OFFSET);

                    gr_dst_0 <= instr(11+SYLLABLE_0_OFFSET downto 8+SYLLABLE_0_OFFSET);
                    gr_dst_1 <= instr(11+SYLLABLE_1_OFFSET downto 8+SYLLABLE_1_OFFSET);
                    gr_dst_2 <= instr(11+SYLLABLE_2_OFFSET downto 8+SYLLABLE_2_OFFSET);
                    gr_dst_3 <= instr(11+SYLLABLE_3_OFFSET downto 8+SYLLABLE_3_OFFSET);

                end if;

                --DETECT EARLY EXIT

                if std_match(instr(7 downto 0), EXIT_IMMEDIATE_OPC) then

                    early_exit <= '1';
                    xdp_action <= instr(63 downto 32);

                else

                    early_exit <= '0';
                    xdp_action <= (others => '0');

                end if;

            end if;

        end if;

    end process fetch_out;

--xdp_action <= instr(63 downto 32);

--early_exit <= '1' when (instr(7 downto 0) = EXIT_IMMEDIATE_OPC and reset = '0') else
--              '0';

end architecture behavioural;

