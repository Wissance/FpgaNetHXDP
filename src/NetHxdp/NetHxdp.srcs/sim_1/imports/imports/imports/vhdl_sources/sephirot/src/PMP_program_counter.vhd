library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

library work;
use work.common_pkg.all;

entity PMP_control_unit is

    Port ( 

             clk            : in std_logic;
             start          : in std_logic;
             rst            : in std_logic; -- '1' to reset program counter, from outside

             -- TO UNITS
             reset_units    : out std_logic;
             fetch_flush    : out std_logic;
             decode_flush   : out std_logic;
             gpr_flush      : out std_logic;
             exe_masquerade : out std_logic;

             -- from the control unit
             pc_addr   : in std_logic_vector(15 downto 0); -- branch address from control unit
             pc_add    : in std_logic;    
             pc_load   : in std_logic;
             pc_stop   : in std_logic;
             pc_resume : in std_logic;

             PC         : out std_logic_vector(15 downto 0) -- program counter out
         );

end PMP_control_unit;

architecture Behavioral of PMP_control_unit is

    signal pc_s : std_logic_vector(15 downto 0) := (others => '1');

    type state_type is (RESET, INCREMENT, ADD, LOAD, STOP, TRAP, IDLE);
    signal STATE : state_type;

    signal error_s : std_logic:= '0';
    signal stop_toggle : std_logic:= '0';
    signal status_vector : std_logic_vector(4 downto 0);
    
    attribute max_fanout : integer;
    attribute max_fanout of STATE : signal is 256;

begin

    status_vector <= start & pc_add & pc_load & pc_stop & pc_resume;

    process (clk)
    begin

        if rising_edge (clk) then

            -- DEFINE STATE TRANSITIONS
            if (rst = '1') then

                STATE <= RESET;
                pc_s <= (others => '0');

            else

                if std_match(status_vector,"10000") then

                    if (stop_toggle = '1') then
                        STATE <= STOP;
                    else 
                        STATE <= INCREMENT;
                        pc_s <= pc_s + 1;
                    end if;


                elsif std_match(status_vector,"1---1") then

                STATE <= INCREMENT;
                pc_s <= pc_s +1;

            elsif std_match(status_vector,"0----") then

            STATE <= IDLE;

        elsif std_match(status_vector,"11000") then

            STATE <= ADD;
            pc_s <= pc_s + pc_addr-1;

        elsif std_match(status_vector,"10100") then

            STATE <= LOAD;
            pc_s <= pc_addr-1;

        elsif std_match(status_vector,"10010") or (stop_toggle = '1') then

            STATE <= STOP;

        else

            STATE <= TRAP;

        end if;

    end if;

end if;

end process;


OUPUTS: process (STATE)
begin

    error_s <= '0';
    reset_units <= '0'; 
    fetch_flush <= '0';
    decode_flush <= '0';
    gpr_flush <= '0';
    stop_toggle <= '0';
    exe_masquerade <='0';

    case STATE is

        when RESET => 
            reset_units <= '1';

        when INCREMENT =>
		null;

        when ADD =>
            fetch_flush <= '1';
            decode_flush <= '1';
            gpr_flush <= '1';

        when LOAD =>
            fetch_flush <= '1';
            decode_flush <= '1';
            gpr_flush <= '1';

        when STOP =>
            stop_toggle <= '1';
            exe_masquerade <= '1';

        when TRAP =>
            error_s <= '1';
            reset_units <='1';

        when IDLE =>
            reset_units <= '1';

    end case;
end process;

PC <= pc_s; 

end Behavioral;
