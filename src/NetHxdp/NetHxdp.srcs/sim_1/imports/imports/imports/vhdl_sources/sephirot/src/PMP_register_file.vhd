library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity gr_regfile is

    generic
    (
        XDP_MD_PAGE : std_logic_vector(3 downto 0) := x"1";
        STACK_PAGE : std_logic_vector(3 downto 0) := x"2"
    );
    Port (
             clk            : in std_logic;
             rst            : in std_logic;
             flush_pipeline : in std_logic;
             pc_idle : in std_logic;

             -- interface for helper functions
             gpr_0_out : out std_logic_vector(63 downto 0);
             gpr_1   : out std_logic_vector(63 downto 0);
             gpr_2   : out std_logic_vector(63 downto 0);
             gpr_3   : out std_logic_vector(63 downto 0);
             gpr_4   : out std_logic_vector(63 downto 0);
             gpr_5   : out std_logic_vector(63 downto 0);

             gpr_0_in    : in std_logic_vector(63 downto 0);
             w_e_0_hf : in std_logic;

             -- SYLLABLE FROM FETCH
             syllable_0_in  : in std_logic_vector(63 downto 0);
             syllable_1_in  : in std_logic_vector(63 downto 0);
             syllable_2_in  : in std_logic_vector(63 downto 0);
             syllable_3_in  : in std_logic_vector(63 downto 0);

             -- SYLLABLE TO DECODE
             syllable_0_out  : out std_logic_vector(63 downto 0);
             syllable_1_out  : out std_logic_vector(63 downto 0);
             syllable_2_out  : out std_logic_vector(63 downto 0);
             syllable_3_out  : out std_logic_vector(63 downto 0);

             -- syllable 0 in-out
             add_src_0        : in std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_src_0_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_0_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_0_exe    : in std_logic_vector(3 downto 0); -- address of syllable 0 result from execution stage
             add_dst_0_fetch  : in std_logic_vector(3 downto 0); -- address of syllable 0 dst reg from fetch stage
             w_e_0            : in std_logic;
             cont_src_0       : out std_logic_vector(63 downto 0); -- syllable 0 source operand
             cont_dst_0_exe   : in std_logic_vector(63 downto 0);  -- syllable 0 result from execution stage
             cont_dst_0_fetch : out std_logic_vector(63 downto 0);  -- syllable 0 preftech from fetch stage

             -- syllable 1 in-out
             add_src_1        : in std_logic_vector(3 downto 0); -- address of syllable 1 source operand  
             add_src_1_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_1_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_1_exe    : in std_logic_vector(3 downto 0); -- address of syllable 1 result from execution stage
             add_dst_1_fetch  : in std_logic_vector(3 downto 0); -- address of syllable 1 dst reg from fetch stage
             w_e_1            : in std_logic;
             cont_src_1       : out std_logic_vector(63 downto 0); -- syllable 1 source operand
             cont_dst_1_exe   : in std_logic_vector(63 downto 0);  -- syllable 1 result from execution stage
             cont_dst_1_fetch : out std_logic_vector(63 downto 0);  -- syllable 1 preftech from fetch stage

             -- syllable 2 in-out
             add_src_2        : in std_logic_vector(3 downto 0); -- address of syllable 2 source operand  
             add_src_2_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_2_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_2_exe    : in std_logic_vector(3 downto 0); -- address of syllable 2 result from execution stage
             add_dst_2_fetch  : in std_logic_vector(3 downto 0); -- address of syllable 2 dst reg from fetch stage
             w_e_2            : in std_logic;
             cont_src_2       : out std_logic_vector(63 downto 0); -- syllable 2 source operand
             cont_dst_2_exe   : in std_logic_vector(63 downto 0);  -- syllable 2 result from execution stage
             cont_dst_2_fetch : out std_logic_vector(63 downto 0);  -- syllable 2 preftech from fetch stage

             -- syllable 3 in-out
             add_src_3        : in std_logic_vector(3 downto 0); -- address of syllable 3 source operand  
             add_src_3_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_3_to_dec : out std_logic_vector(3 downto 0); -- address of syllable 0 source operand  
             add_dst_3_exe    : in std_logic_vector(3 downto 0); -- address of syllable 3 result from execution stage
             add_dst_3_fetch  : in std_logic_vector(3 downto 0); -- address of syllable 3 dst reg from fetch stage
             w_e_3            : in std_logic;
             cont_src_3       : out std_logic_vector(63 downto 0); -- syllable 3 source operand
             cont_dst_3_exe   : in std_logic_vector(63 downto 0);  -- syllable 3 result from execution stage
             cont_dst_3_fetch : out std_logic_vector(63 downto 0)  -- syllable 3 preftech from fetch stage

         );

end gr_regfile;

architecture Behavioral of gr_regfile is

    type gpr_type is array (10 downto 0) of std_logic_vector(63 downto 0);

    signal reg_file : gpr_type; 

begin

    process(clk)
    begin

        if rising_edge(clk) then

            if (rst = '1') then

                reg_file <= (others => x"0000000000000000");
                reg_file(1) <= XDP_MD_PAGE & x"000000000000000";
                reg_file(10) <= STACK_PAGE & x"000000000000000";

                syllable_0_out <= (others => '0');
                syllable_1_out <= (others => '0');
                syllable_2_out <= (others => '0');
                syllable_3_out <= (others => '0');

                add_src_0_to_dec <=(others => '0');
                add_src_1_to_dec <=(others => '0');
                add_src_2_to_dec <=(others => '0');
                add_src_3_to_dec <=(others => '0');

                add_dst_0_to_dec <=(others => '0');
                add_dst_1_to_dec <=(others => '0');
                add_dst_2_to_dec <=(others => '0');
                add_dst_3_to_dec <=(others => '0');

                cont_src_0 <=(others => '0');
                cont_src_1 <=(others => '0');
                cont_src_2 <=(others => '0');
                cont_src_3 <=(others => '0');
                cont_dst_0_fetch <=(others => '0');
                cont_dst_1_fetch <=(others => '0');
                cont_dst_2_fetch <=(others => '0');
                cont_dst_3_fetch <=(others => '0');

            else

                if (w_e_0 = '1') then
                    reg_file(conv_integer(add_dst_0_exe)) <= cont_dst_0_exe;

                elsif (w_e_1 = '1') then
                    reg_file(conv_integer(add_dst_1_exe)) <= cont_dst_1_exe;

                elsif (w_e_2 = '1') then                
                    reg_file(conv_integer(add_dst_2_exe)) <= cont_dst_2_exe;

                elsif (w_e_3 = '1') then
                    reg_file(conv_integer(add_dst_3_exe)) <= cont_dst_3_exe;

                elsif (w_e_0_hf = '1') then
                    reg_file(0) <= gpr_0_in;
                end if;

            end if;

            if (flush_pipeline = '1') then

                syllable_0_out <= (others => '0');
                syllable_1_out <= (others => '0');
                syllable_2_out <= (others => '0');
                syllable_3_out <= (others => '0');

                add_src_0_to_dec <=(others => '0');
                add_src_1_to_dec <=(others => '0');
                add_src_2_to_dec <=(others => '0');
                add_src_3_to_dec <=(others => '0');

                add_dst_0_to_dec <=(others => '0');
                add_dst_1_to_dec <=(others => '0');
                add_dst_2_to_dec <=(others => '0');
                add_dst_3_to_dec <=(others => '0');

                cont_src_0 <=(others => '0');
                cont_src_1 <=(others => '0');
                cont_src_2 <=(others => '0');
                cont_src_3 <=(others => '0');
                cont_dst_0_fetch <=(others => '0');
                cont_dst_1_fetch <=(others => '0');
                cont_dst_2_fetch <=(others => '0');
                cont_dst_3_fetch <=(others => '0');


            elsif (pc_idle = '0') then

                syllable_0_out <= syllable_0_in;
                syllable_1_out <= syllable_1_in;
                syllable_2_out <= syllable_2_in;
                syllable_3_out <= syllable_3_in;

                add_src_0_to_dec <= add_src_0;
                add_src_1_to_dec <= add_src_1;
                add_src_2_to_dec <= add_src_2;
                add_src_3_to_dec <= add_src_3;

                add_dst_0_to_dec <= add_dst_0_fetch; 
                add_dst_1_to_dec <= add_dst_1_fetch; 
                add_dst_2_to_dec <= add_dst_2_fetch; 
                add_dst_3_to_dec <= add_dst_3_fetch; 

            end if;

            -- cont_0_src MUX
            if ((w_e_0 = '1') and (add_src_0 = add_dst_0_exe)) then
                cont_src_0 <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_src_0 = add_dst_1_exe)) then
                cont_src_0 <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_src_0 = add_dst_2_exe)) then
                cont_src_0 <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_src_0 = add_dst_3_exe)) then
                cont_src_0 <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_src_0 = x"0")) then
                cont_src_0 <= gpr_0_in;
            else
                cont_src_0 <= reg_file(conv_integer(add_src_0));
            end if;

            if ((w_e_0 = '1') and (add_src_1 = add_dst_0_exe)) then
                cont_src_1 <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_src_1 = add_dst_1_exe)) then
                cont_src_1 <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_src_1 = add_dst_2_exe)) then
                cont_src_1 <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_src_1 = add_dst_3_exe)) then
                cont_src_1 <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_src_1 = x"0")) then
                cont_src_1 <= gpr_0_in;
            else
                cont_src_1 <= reg_file(conv_integer(add_src_1));
            end if;

            if ((w_e_0 = '1') and (add_src_2 = add_dst_0_exe)) then
                cont_src_2 <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_src_2 = add_dst_1_exe)) then
                cont_src_2 <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_src_2 = add_dst_2_exe)) then
                cont_src_2 <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_src_2 = add_dst_3_exe)) then
                cont_src_2 <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_src_2 = x"0")) then
                cont_src_2 <= gpr_0_in;
            else
                cont_src_2 <= reg_file(conv_integer(add_src_2));
            end if;

            if ((w_e_0 = '1') and (add_src_3 = add_dst_0_exe)) then
                cont_src_3 <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_src_3 = add_dst_1_exe)) then
                cont_src_3 <= cont_dst_1_exe;
            elsif ((w_e_0 = '1') and (add_src_3 = add_dst_2_exe)) then
                cont_src_3 <= cont_dst_2_exe;
            elsif ((w_e_0 = '1') and (add_src_3 = add_dst_3_exe)) then
                cont_src_3 <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_src_3 = x"0")) then
                cont_src_3 <= gpr_0_in;
            else
                cont_src_3 <= reg_file(conv_integer(add_src_3));
            end if;

            if ((w_e_0 = '1') and (add_dst_0_fetch = add_dst_0_exe)) then
                cont_dst_0_fetch <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_dst_0_fetch = add_dst_1_exe)) then
                cont_dst_0_fetch <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_dst_0_fetch = add_dst_2_exe)) then
                cont_dst_0_fetch <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_dst_0_fetch = add_dst_3_exe)) then
                cont_dst_0_fetch <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_dst_0_fetch = x"0")) then
                cont_dst_0_fetch <= gpr_0_in;
            else
                cont_dst_0_fetch <= reg_file(conv_integer(add_dst_0_fetch));
            end if;

            if ((w_e_0 = '1') and (add_dst_1_fetch = add_dst_0_exe)) then
                cont_dst_1_fetch <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_dst_1_fetch = add_dst_1_exe)) then
                cont_dst_1_fetch <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_dst_1_fetch = add_dst_2_exe)) then
                cont_dst_1_fetch <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_dst_1_fetch = add_dst_3_exe)) then
                cont_dst_1_fetch <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_dst_1_fetch = x"0")) then
                cont_dst_1_fetch <= gpr_0_in;
            else
                cont_dst_1_fetch <= reg_file(conv_integer(add_dst_1_fetch));
            end if;

            if ((w_e_0 = '1') and (add_dst_2_fetch = add_dst_0_exe)) then
                cont_dst_2_fetch <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_dst_2_fetch = add_dst_1_exe)) then
                cont_dst_2_fetch <= cont_dst_1_exe;
            elsif ((w_e_2 = '1') and (add_dst_2_fetch = add_dst_2_exe)) then
                cont_dst_2_fetch <= cont_dst_2_exe;
            elsif ((w_e_3 = '1') and (add_dst_2_fetch = add_dst_3_exe)) then
                cont_dst_2_fetch <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_dst_2_fetch = x"0")) then
                cont_dst_2_fetch <= gpr_0_in;
            else
                cont_dst_2_fetch <= reg_file(conv_integer(add_dst_2_fetch));
            end if;

            if ((w_e_0 = '1') and (add_dst_3_fetch = add_dst_0_exe)) then
                cont_dst_3_fetch <= cont_dst_0_exe;
            elsif ((w_e_1 = '1') and (add_dst_3_fetch = add_dst_1_exe)) then
                cont_dst_3_fetch <= cont_dst_1_exe;
            elsif ((w_e_0 = '1') and (add_dst_3_fetch = add_dst_2_exe)) then
                cont_dst_3_fetch <= cont_dst_2_exe;
            elsif ((w_e_0 = '1') and (add_dst_3_fetch = add_dst_3_exe)) then
                cont_dst_3_fetch <= cont_dst_3_exe;
            elsif ((w_e_0_hf = '1') and (add_dst_3_fetch = x"0")) then
                cont_dst_3_fetch <= gpr_0_in;
            else
                cont_dst_3_fetch <= reg_file(conv_integer(add_dst_3_fetch));
            end if;


        end if;
    end process;

    gpr_0_out <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"0")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"0")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"0")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"0")) else
             reg_file(0);

    gpr_1 <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"1")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"1")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"1")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"1")) else
             reg_file(1);
    
    gpr_2 <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"2")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"2")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"2")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"2")) else
             reg_file(2);


    gpr_3 <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"3")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"3")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"3")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"3")) else
             reg_file(3);
    
    gpr_4 <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"4")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"4")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"4")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"4")) else
             reg_file(4);

    gpr_5 <= cont_dst_0_exe when ((w_e_0 = '1') and (add_dst_0_exe = x"4")) else
             cont_dst_1_exe when ((w_e_1 = '1') and (add_dst_1_exe = x"4")) else
             cont_dst_2_exe when ((w_e_2 = '1') and (add_dst_2_exe = x"4")) else
             cont_dst_3_exe when ((w_e_3 = '1') and (add_dst_3_exe = x"4")) else
             reg_file(4);
end Behavioral;
