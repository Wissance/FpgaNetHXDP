library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package marcux_pkg is

	function jhash (i_vector : std_logic_vector(63 downto 0))
	return std_logic_vector;
	
	function log_2 (x: positive) return natural;

end package marcux_pkg;

-- Package Body Section
package body marcux_pkg is

	function jhash (i_vector : in std_logic_vector(63 downto 0))
	return std_logic_vector is
	begin

		return i_vector(63 downto 56) xor 
			   i_vector(55 downto 48) xor
			   i_vector(47 downto 40) xor
			   i_vector(39 downto 32) xor
			   i_vector(31 downto 24) xor
			   i_vector(23 downto 16) xor
			   i_vector(15 downto 8) xor
			   i_vector(7  downto 0);
	end function;
	
	
	function log_2 (x : in positive)
    return natural is
    variable i : natural;
    begin
         i := 0;
         while (2**i < x) and i < 31 loop 
           i := i + 1;
           end loop;
           return i;

    end function;

end marcux_pkg;
