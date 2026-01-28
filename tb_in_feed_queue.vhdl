library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_pkg.all; 

entity tb_in_feed_queue is
end;

architecture tb_arch of tb_in_feed_queue is


    constant CLK_PERIOD : time := 20 ns;
    signal clk          : std_logic := '0';
    signal rstn         : std_logic := '0';
    signal load_enable  : std_logic := '0';
    

    signal input_mat_a    : matrix_t := (others => (others => std_logic_vector(to_signed(16, 8))));
    signal input_mat_b    : matrix_t := (others => (others => std_logic_vector(to_signed(16, 8))));
    signal idx_monitor  : std_logic_vector(0 to 7);
    

    signal result_mat   : matrix_result_t; 

    component in_feed_queue 
        port(
            clk             : in std_logic;
            rstn            : in std_logic;
            curr_matrix_idx : out std_logic_vector(7 downto 0);
            input_matrix_a    : in  matrix_t;
	    input_matrix_b    : in  matrix_t;
            matrix_ready    : in  std_logic;
            result_matrix   : out matrix_result_t
        );
    end component;

begin


    uut: in_feed_queue port map (
        clk             => clk,
        rstn            => rstn,
        curr_matrix_idx => idx_monitor,
        input_matrix_a    => input_mat_a,
	input_matrix_b    => input_mat_b,
        matrix_ready    => load_enable,
        result_matrix   => result_mat
    );


    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    
    stim_proc: process
    begin

        report "Status: Resetting...";
        rstn <= '0';
        wait for 50 ns;
        

        report "Status: Starting Matrix Feed...";
        rstn <= '1';
        wait for CLK_PERIOD; 
        load_enable <= '1'; 
        wait for CLK_PERIOD; 
        load_enable <= '0';


        wait for 1 us;


        report "Status: Verifying Results...";
        
        for i in 0 to 3 loop
            for j in 0 to 3 loop

                -- Row * Col = (16*16) + (16*16) + (16*16) + (16*16) = 256 * 4 = 1024
                
                assert to_integer(signed(result_mat(i, j))) = 1024
                    report "ERROR at [" & integer'image(i) & "][" & integer'image(j) & "]: " &
                           "Expected 1024, got " & integer'image(to_integer(signed(result_mat(i, j))))
                    severity error;
            end loop;
        end loop;

        report "Status: Test Complete. If no errors above, test PASSED.";
        wait; 
    end process;

end;