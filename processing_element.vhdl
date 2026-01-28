library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_numeric_std.all;
use ieee.numeric_std.all;

entity processing_element is
	port(
		clk	: in std_logic;
		rstn	: in std_logic;

		new_matrix_signal : in	std_logic;

		left_neighbor	: in	std_logic_vector(7 downto 0);
		right_neighbor	: out	std_logic_vector(7 downto 0);

		top_neighbor	: in	std_logic_vector(7 downto 0);
		bottom_neighbor		: out	std_logic_vector(7 downto 0);

		chain_in	: in std_logic_vector(15 downto 0);
		chain_out	: out std_logic_vector(15 downto 0)
	);
end entity processing_element;



architecture processing_element_arch of processing_element is
	signal acc : std_logic_vector(15 downto 0);
	signal shadow_reg : std_logic_vector(15 downto 0);
	signal bottom_reg : std_logic_vector(7 downto 0);
	signal right_reg : std_logic_vector(7 downto 0);

begin
right_neighbor <= right_reg;
bottom_neighbor <= bottom_reg;

chain_out <= shadow_reg;

	process(clk, rstn)
	begin
		if rising_edge(clk) then
			if rstn = '0' then
				acc <= (others => '0');
				shadow_reg <= (others => '0');
				bottom_reg <= (others => '0');
				right_reg <= (others => '0');
			else
				bottom_reg <= top_neighbor;
				right_reg <= left_neighbor;
				if new_matrix_signal = '1' then
					shadow_reg <= acc;
					acc <= std_logic_vector(SIGNED(left_neighbor) * SIGNED(top_neighbor));
				else
					shadow_reg <= chain_in;
					acc <=  std_logic_vector(SIGNED(acc) + (SIGNED(left_neighbor) * SIGNED(top_neighbor)));		
				end if;
				
			end if;
			
		end if;
	end process;

	

end architecture processing_element_arch;
