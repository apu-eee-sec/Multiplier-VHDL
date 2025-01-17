library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity dadda_mult4x4_tb is
end dadda_mult4x4_tb;

architecture testbench of dadda_mult4x4_tb is
    component dadda_mult4x4
        port (
            A : in std_logic_vector(3 downto 0);
            B : in std_logic_vector(3 downto 0);
            P : out std_logic_vector(7 downto 0));
    end component;

    signal A_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal B_tb : std_logic_vector(3 downto 0) := (others => '0');
    signal P_tb : std_logic_vector(7 downto 0);

    signal expected_output : std_logic_vector(7 downto 0);
    signal correct_count : integer := 0;
    signal total_tests : integer := 0;
    signal accuracy : real := 0.0;

begin
    UUT: dadda_mult4x4
        port map (
            A => A_tb,
            B => B_tb,
            P => P_tb );

    stim_process: process
        variable A_int, B_int : integer;
        variable P_int : integer;
    begin
        for A_int in 0 to 15 loop
            for B_int in 0 to 15 loop
                A_tb <= std_logic_vector(to_unsigned(A_int, 4));
                B_tb <= std_logic_vector(to_unsigned(B_int, 4));
                expected_output <= std_logic_vector(to_unsigned(A_int * B_int, 8));
                wait for 2 ns;
				
                P_int := to_integer(unsigned(P_tb));
                if P_int = A_int * B_int then
                    correct_count <= correct_count + 1;
                end if;
                total_tests <= total_tests + 1;
            end loop;
        end loop;

        accuracy <= (correct_count * 100.0) / total_tests;

        report "Accuracy of dadda_mult4x4: " & real'image(accuracy) & "%";

        wait;
    end process;
end testbench;