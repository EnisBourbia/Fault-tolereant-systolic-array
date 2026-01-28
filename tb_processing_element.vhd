library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_processing_element is
end tb_processing_element;


architecture tb_processing_element_arch of tb_processing_element is

component processing_element
	port(
		clk	: in std_logic;
		rstn	: in std_logic;
		--a	: in 	std_logic_vector(0 to 7);
		--b	: in	std_logic_vector(0 to 7);
		left_neighbor	: in	std_logic_vector(0 to 7);
		right_neighbor	: out	std_logic_vector(0 to 7);
		top_neighbor	: in	std_logic_vector(0 to 7);
		bottom_neighbor		: out	std_logic_vector(0 to 7);
		result          : out std_logic_vector(15 downto 0)
	);
end component;

signal clock	: std_logic := '0';
signal reset	: std_logic := '0';
constant clk_period : time := 20 ns;

signal left_neighbor	: std_logic_vector(0 to 7) := "00000000";
signal top_neighbor	: std_logic_vector(0 to 7) := "00000000";

signal right_neighbor	: std_logic_vector(0 to 7);
signal bottom_neighbor	: std_logic_vector(0 to 7);
signal acc_result	: std_logic_vector(15 downto 0);

begin

pe: processing_element port map (
	clk => clock,
	rstn => reset,
	left_neighbor => left_neighbor,
	top_neighbor => top_neighbor,
	bottom_neighbor => bottom_neighbor,
	right_neighbor => right_neighbor
);

clk :process
begin
clock <= '0';
wait for clk_period/2;
clock <= '1';
wait for clk_period/2;
clock <= '0';
end process;


stim_proc: process
begin
wait for 20 ns;
reset <= '0';

wait for 20 ns;
reset <= '1';
left_neighbor <= "00000010";
top_neighbor <= "00000010";

wait for 20 ns;
reset <= '1';
left_neighbor <= "00000010";
top_neighbor <= "00000010";

wait for 20 ns;
reset <= '1';
left_neighbor <= "00000000";
top_neighbor <= "00000000";



wait;
end process;
end;