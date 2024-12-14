library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity PMP_data_RAM is

    Port ( 

             clk         : in std_logic;
             reset       : in std_logic;

             -- Read 
             read_add_0  : in std_logic_vector(7 downto 0);
             read_add_1  : in std_logic_vector(7 downto 0);
             read_add_2  : in std_logic_vector(7 downto 0);
             read_add_3  : in std_logic_vector(7 downto 0);

             data_out_0  : out std_logic_vector(63 downto 0);
             data_out_1  : out std_logic_vector(63 downto 0);
             data_out_2  : out std_logic_vector(63 downto 0);
             data_out_3  : out std_logic_vector(63 downto 0);

             --Write
             wrt_add_0   : in std_logic_vector(7 downto 0);
             wrt_add_1   : in std_logic_vector(7 downto 0);
             wrt_add_2   : in std_logic_vector(7 downto 0);
             wrt_add_3   : in std_logic_vector(7 downto 0);

             wrt_en_0    : in std_logic;
             wrt_en_1    : in std_logic;
             wrt_en_2    : in std_logic;
             wrt_en_3    : in std_logic;

             data_in_0   : in std_logic_vector(63 downto 0);  
             data_in_1   : in std_logic_vector(63 downto 0);  
             data_in_2   : in std_logic_vector(63 downto 0);  
             data_in_3   : in std_logic_vector(63 downto 0)  

         );

end PMP_data_RAM;

architecture Behavioral of PMP_data_RAM is

    type RAM_type is array(0 to 255) of std_logic_vector(31 downto 0);


    signal data_RAM_lower : RAM_type;                                                     
    signal data_RAM_upper : RAM_type;                                                     

begin   

    process(clk) 
    begin

        if rising_edge(clk) then

            if (reset = '1') then 

                data_RAM_lower <= (others => x"00000000");
                data_RAM_upper <= (others => x"00000000");

            else

                data_out_0(31 downto 0) <= data_RAM_lower(conv_integer(read_add_0)); 
                data_out_0(63 downto 32) <= data_RAM_upper(conv_integer(read_add_0)); 
                data_out_1(31 downto 0) <= data_RAM_lower(conv_integer(read_add_1)); 
                data_out_1(63 downto 32) <= data_RAM_upper(conv_integer(read_add_1)); 
                data_out_2(31 downto 0) <= data_RAM_lower(conv_integer(read_add_2)); 
                data_out_2(63 downto 32) <= data_RAM_upper(conv_integer(read_add_2)); 
                data_out_3(31 downto 0) <= data_RAM_lower(conv_integer(read_add_3)); 
                data_out_3(63 downto 32) <= data_RAM_upper(conv_integer(read_add_3)); 

                if (wrt_en_0 = '1') then
                    data_RAM_lower(conv_integer(wrt_add_0)) <= data_in_0(31 downto 0);
                    data_RAM_upper(conv_integer(wrt_add_0)) <= data_in_0(63 downto 32);
                end if;

                if (wrt_en_1 = '1') then
                    data_RAM_lower(conv_integer(wrt_add_1)) <= data_in_1(31 downto 0);
                    data_RAM_upper(conv_integer(wrt_add_1)) <= data_in_1(63 downto 32);
                end if;
                
                if (wrt_en_2 = '1') then
                    data_RAM_lower(conv_integer(wrt_add_2)) <= data_in_2(31 downto 0);
                    data_RAM_upper(conv_integer(wrt_add_2)) <= data_in_2(63 downto 32);
                end if;
                
                if (wrt_en_3 = '1') then
                    data_RAM_lower(conv_integer(wrt_add_3)) <= data_in_3(31 downto 0);
                    data_RAM_upper(conv_integer(wrt_add_3)) <= data_in_3(63 downto 32);
                end if;
                
            end if;

        end if;

    end process;


end Behavioral;
