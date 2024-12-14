library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_Std.all;
use ieee.std_logic_unsigned.all;

entity i_mem is

    --generic (init_file: string:="/home/marco/projects/sephirot/roms/xdp1_steps.bin");
    generic (init_file: string:="XDP_DROP_early_exit.bin");
    --generic (init_file: string:="/home/marco/hdl_sources/sephirot/roms/call_test.bin");

    

    port ( 
             --AXI/mem interface
             axi_clock : in std_logic;
             we: in std_logic;
             axi_addr : in std_logic_vector(31 downto 0); 
             axi_data_out : out std_logic_vector(255 downto 0);
             axi_data_in     : in std_logic_vector (255 downto 0);

             -- AXIS interface
             clock : in std_logic;
             reset : in std_logic;
             addr  : in std_logic_vector(15 downto 0);
             data_out : out std_logic_vector(255 downto 0)
         );

end i_mem;

architecture behavioral of i_mem is

    type mem_type is array (0 to 255) of std_logic_vector(255 downto 0) ;

    impure function InitRamFromFile (RamFileName : in string) return mem_type is
        FILE ramfile : text is in RamFileName;
        variable RamFileLine : line;
        variable ram : mem_type;
    begin
        for i in mem_type'range loop
            readline(ramfile, RamFileLine);
            --if (RamFileLine(RamFileLine'high)='#') then report "ciao"; end if;
            hread(RamFileLine, ram(i));
        end loop;
        return ram;
    end function;

    signal mem1: mem_type:=InitRamFromFile(init_file);
    signal axi_addr_s : std_logic_vector (7 downto 0);
    signal data_out_s : std_logic_vector(255 downto 0);                                                  

begin  

    axi_addr_s <= axi_addr(7 downto 0);

    process(axi_clock)
    begin

        if rising_edge(axi_clock) then

            if we = '1' then

                mem1(to_integer(unsigned(axi_addr_s))) <= axi_data_in;

            end if;
                            axi_data_out <= mem1(to_integer(unsigned(axi_addr_s)));

        end if;

    end process;
            
             process(clock)
       begin
   
           if rising_edge (clock) then
   
               data_out <= mem1(to_integer(unsigned(addr(7 downto 0))))(255 downto 0);

           end if;
   
       end process;
               
            
--data_out <= (others => ('0')) when addr = x"ffff" else data_out_s;


end behavioral;
