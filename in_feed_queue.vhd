library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_pkg.all;
--type Matrix_4x4 is array (0 to 3, 0 to 3) of std_logic_vector(0 to 7);


entity in_feed_queue is
	generic(
		rows	: natural := 4;
		cols	: natural := 4;
		w	: natural := 8
	);

	port(
			clk : in 	std_logic;
			rstn: in 	std_logic;
			--curr_matrix_idx	: out	std_logic_vector(0 to w-1);
			input_matrix_a	: in	matrix_t; --array (0 to rows-1, 0 to cols-1) of std_logic_vector(0 to w-1)
			input_matrix_b	: in	matrix_t;
			matrix_ready	: in	std_logic;
			result_matrix   : out   matrix_result_t -- Only for testing
	);
end;

 
architecture in_feed_queue_arch of in_feed_queue is



 type t_state is (idle, sending, waiting);
 signal curr_state : t_state := idle;
 signal next_state : t_state := idle;
 signal counter : integer range 0 to 20 := 0;


component processing_element
	port(
		clk	: in std_logic;
		rstn	: in std_logic;
		--a	: in 	std_logic_vector(0 to 7);
		--b	: in	std_logic_vector(0 to 7);
		left_neighbor	: in	std_logic_vector(7 downto 0);
		right_neighbor	: out	std_logic_vector(7 downto 0);
		top_neighbor	: in	std_logic_vector(7 downto 0);
		bottom_neighbor		: out	std_logic_vector(7 downto 0);
		result          : out std_logic_vector(15 downto 0)
	);
end component;


type pe_matrix_t is array(0 to rows, 0 to cols) of std_logic_vector(w-1 downto 0);
signal col_wires : pe_matrix_t;
signal row_wires : pe_matrix_t;


type input_array_t is array(0 to 7) of std_logic_vector(w-1 downto 0); -- Sized to max rows/cols
signal col_feeds : input_array_t;
signal row_feeds : input_array_t;

begin
--curr_matrix_idx <= std_logic_vector(to_signed(counter, curr_matrix_idx'length));


gen_process_element_row: for row in 1 to rows generate
 gen_process_element_col: for col in 1 to cols generate
	signal left_input_mux : std_logic_vector(w-1 downto 0);
	signal top_input_mux  : std_logic_vector(w-1 downto 0);
begin
left_input_mux <= col_feeds(row) when (col = 1) else col_wires(row, col-1);
top_input_mux  <= row_feeds(col) when (row = 1) else row_wires(row-1, col);

  U: processing_element port map (
  	clk	=> clk,
	rstn	=> rstn,
	left_neighbor => left_input_mux,
	right_neighbor	=> col_wires(row, col),
	top_neighbor	=> top_input_mux,
	bottom_neighbor => row_wires(row, col),
	result => result_matrix(row-1, col-1)
 );
 end generate;
end generate;

process(clk, rstn) is
begin
	if rising_edge(clk) then
		if rstn = '0' then
			curr_state <= idle;
			counter <= 0;
		else 
		case curr_state is
			when sending => counter <= counter + 1;
			when others => counter <= 0;
		end case; 
		curr_state <= next_state;
		end if;
	end if;
end process;

process(curr_state, counter, matrix_ready, input_matrix_a, input_matrix_b)
variable idx_offset : integer;
begin
 next_state <= curr_state;

col_feeds <= (others => (others => '0'));
row_feeds <= (others => (others => '0'));


	case curr_state is
		when idle =>
			if matrix_ready = '1' then
				next_state <= sending;
			end if;
		when sending =>
			for i in 0 to rows-1 loop
				if counter >= i then
					idx_offset := counter - i;
					if idx_offset < cols then
                            			col_feeds(i+1) <= input_matrix_b(i, idx_offset);
                       				row_feeds(i+1) <= input_matrix_a(idx_offset, i);
                        		end if;
				end if;
			end loop;
			if counter = 9 then
				next_state <= waiting;
			end if;
		when waiting =>
			next_state <= idle;
	end case;
end process;

end;