library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_pkg.all;


entity matrix_acc is
	port(
		clk	: in std_logic;
		rstn	: in std_logic;
		matrix_result	: out	matrix_result_t;
		curr_row_idx	: in	std_logic_vector(1 downto 0);
		pe_col_wires	: in	col_wires
		
);
end entity matrix_acc;


architecture matrix_acc_arch of matrix_acc is
signal matrix_res	: matrix_result_t;
begin

process(clk, rstn)
variable v_counter : integer range 0 to 3 := 0;
begin
matrix_result <= matrix_res;

	if rising_edge(clk) then
		if rstn = '0' then
			matrix_res <= (others => (others => (others => '0')));
			v_counter := 0;
		else
			for i in 0 to pe_col_wires'length-1 loop
				matrix_res(0, i) <= pe_col_wires(i);
			end loop;
			for row in 1 to matrix_res'length-1 loop
				for col in 0 to matrix_res'length-1 loop
					matrix_res(row, col) <= matrix_res(row-1, col);
				end loop;
			end loop;
		end if;
		
	end if;	

end process;

end architecture matrix_acc_arch;
