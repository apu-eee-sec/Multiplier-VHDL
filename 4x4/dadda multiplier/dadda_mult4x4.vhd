library ieee;
use ieee.std_logic_1164.all;

entity dadda_mult4x4 is
    port (
        A : in std_logic_vector(3 downto 0);
        B : in std_logic_vector(3 downto 0);
        P : out std_logic_vector(7 downto 0) );
end dadda_mult4x4;

architecture arch of dadda_mult4x4 is

    -- generate partial products
    function gen_pp(B, A: std_logic) return std_logic is
    begin
        if (A = '1' and B = '1') then
            return '1';
        else
            return '0';
        end if;
    end gen_pp;



    function exact_HA(a, b : std_logic) return std_logic_vector is
        variable result : std_logic_vector(1 downto 0);
    begin
        result(0) := a xor b;  -- Sum
        result(1) := a and b;  -- Carry
        return result;
    end exact_HA;

    function exact_FA(a, b, c : std_logic) return std_logic_vector is
        variable result : std_logic_vector(1 downto 0);
    begin
        result(0) := a xor b xor c;                        -- Sum
        result(1) := (a and b) or (c and b) or (a and c);  -- Carry
        return result;
    end exact_FA;


    function approx_HA(a, b : std_logic) return std_logic_vector is
        variable result : std_logic_vector(1 downto 0);
    begin
        result(0) := a or b;   -- Sum
        result(1) := a and b;  -- Carry
        return result;
    end approx_HA;

    -- approximate 3:2 compressor
    function approx_32(P0, P1, P2: std_logic) return std_logic_vector is
        variable result: std_logic_vector(1 downto 0);
    begin
        result(1) := (P0 and P1) or P2;  -- First output
        result(0) := P0 or P1;           -- Second output
        return result;
    end approx_32;

    -- approximate 4:2 compressor
    function approx_42(P0, P1, P2, P3: std_logic) return std_logic_vector is
        variable result: std_logic_vector(1 downto 0);
    begin
        result(1) := (P0 and P1) or P2 or P3;  -- First output
        result(0) := P0 or P1 or (P2 and P3);  -- Second output
        return result;
    end approx_42;
	
	

begin
    process(A, B)
        variable Adder_results: std_logic_vector(1 downto 0);
        variable sum: std_logic_vector(5 downto 0);
        variable carry: std_logic_vector(1 downto 0);
    begin
        -- First reduction stage
        P(0) <= gen_pp(B(0), A(0));
        P(1) <= gen_pp(B(0), A(1)) or gen_pp(B(1), A(0));

        Adder_results := approx_32(gen_pp(B(0), A(2)), gen_pp(B(1), A(1)), gen_pp(B(2), A(0)));
        sum(0) := Adder_results(0);
        sum(1) := Adder_results(1);

        Adder_results := approx_42(gen_pp(B(0), A(3)), gen_pp(B(1), A(2)), gen_pp(B(2), A(1)), gen_pp(B(3), A(0)));
        sum(2) := Adder_results(0);
        sum(3) := Adder_results(1);

        Adder_results := approx_HA(gen_pp(B(2), A(2)), gen_pp(B(3), A(1)));
        sum(4) := Adder_results(0);
        carry(0) := Adder_results(1);

        Adder_results := exact_HA(gen_pp(B(2), A(3)), gen_pp(B(3), A(2)));
        sum(5) := Adder_results(0);
        carry(1) := Adder_results(1);

        -- Second reduction stage
        Adder_results := approx_HA(sum(0), sum(1));
        P(2) <= Adder_results(0);

        Adder_results := exact_FA(sum(2), sum(3), Adder_results(1));
        P(3) <= Adder_results(0);

        Adder_results := exact_FA(gen_pp(B(1), A(3)), sum(4), Adder_results(1));
        P(4) <= Adder_results(0);

        Adder_results := exact_FA(carry(0), sum(5), Adder_results(1));
        P(5) <= Adder_results(0);

        Adder_results := exact_FA(gen_pp(B(3), A(3)), carry(1), Adder_results(1));
        P(6) <= Adder_results(0);
        P(7) <= Adder_results(1);
    end process;
end arch;