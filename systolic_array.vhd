library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_pkg.all;

entity systolic_array is
	port(
		clk	:in	std_logic;
		rstn	:in	std_logic;
		input_matrix_a	: in	matrix_t;
		input_matrix_b	: in	matrix_t;
		final_matrix	: out	matrix_result_t;
		output_vote	: out 	std_logic;
		process_en	: in	std_logic
		--output_matrix_x 	: in	matrix_t;
		--output_matrix_y 	: in	matrix_t;
		--output_matrix_z 	: in	matrix_t
);

end entity systolic_array;


architecture systolic_array_arch of systolic_array is

component in_feed_queue
	generic(
		rows	: natural := 4;
		cols	: natural := 4;
		w	: natural := 8
	);

	port(
			clk : in 	std_logic;
			rstn: in 	std_logic;
			input_matrix_a	: in	matrix_t; --array (0 to rows-1, 0 to cols-1) of std_logic_vector(0 to w-1)
			input_matrix_b	: in	matrix_t;
			matrix_ready	: in	std_logic;
			result_matrix   : out   matrix_result_t
	);
end component;

signal matrix_output_1 : matrix_result_t;
signal matrix_output_2 : matrix_result_t;
signal matrix_output_3 : matrix_result_t;

begin


systolic_array_1: in_feed_queue port map (
	clk => clk,
	rstn => rstn,
	input_matrix_a => input_matrix_a,
	input_matrix_b => input_matrix_b,
	matrix_ready  => process_en,
	result_matrix   => matrix_output_1
);

systolic_array_2: in_feed_queue port map (
	clk => clk,
	rstn => rstn,
	input_matrix_a => input_matrix_a,
	input_matrix_b => input_matrix_b,
	matrix_ready  => process_en,
	result_matrix   => matrix_output_2
);

systolic_array_3: in_feed_queue port map (
	clk => clk,
	rstn => rstn,
	input_matrix_a => input_matrix_a,
	input_matrix_b => input_matrix_b,
	matrix_ready  => process_en,
	result_matrix   => matrix_output_3
);



process(matrix_output_1, matrix_output_2, matrix_output_3)
begin
	output_vote <= '1';

	if matrix_output_1 = matrix_output_2 OR matrix_output_1 = matrix_output_3 then
		final_matrix <= matrix_output_1;
	elsif matrix_output_2 = matrix_output_3 then
		final_matrix <= matrix_output_2;
	else
		final_matrix <= (others=> (others => (others => '0')));
		output_vote <= '0';
	end if;

end process;


end architecture systolic_array_arch;

