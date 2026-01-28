library ieee;
use ieee.std_logic_1164.all;

package matrix_pkg is
  type matrix_t is array (0 to 3, 0 to 3)
      of std_logic_vector(7 downto 0);

  type matrix_result_t is array (0 to 3, 0 to 3)
      of std_logic_vector(15 downto 0);

  type col_wires is array (0 to 3) of std_logic_vector(15 downto 0);
end package;