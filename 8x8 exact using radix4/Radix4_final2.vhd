library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Radix4_accu8x8 is
    Port (
    
        -- Szero_out, Splus1_out, Sminus1_out, Splus2_out, Sminus2_out: out STD_LOGIC_VECTOR(3 downto 0);
        -- Sgen0,Sgen1,Sgen2,Sgen3: out STD_LOGIC_VECTOR(15 downto 0);
        -- Ssum0, Ssum1, Ssum2, Ssum3, Ssum4, Ssum5, Ssum6: out STD_LOGIC_VECTOR(3 downto 0);
        -- Scout: out STD_LOGIC_VECTOR(9 downto 0);
        -- Sa_comp : out STD_LOGIC_VECTOR(7 downto 0);
        
        a,b  : in  STD_LOGIC_VECTOR(7 downto 0);
        prod : out STD_LOGIC_VECTOR(15 downto 0)
    );
end Radix4_accu8x8;


architecture Behavioral of Radix4_accu8x8 is

signal zero_out, plus1_out, minus1_out, plus2_out, minus2_out: STD_LOGIC_VECTOR(3 downto 0);
signal a_comp : STD_LOGIC_VECTOR(7 downto 0);

type pp_array0 is array(3 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal gen: pp_array0;

type pp_array1 is array(7 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
signal s1, s2: pp_array1;
signal sum: pp_array1;
signal carries : pp_array1;
signal cout: STD_LOGIC_VECTOR (9 downto 0):= (others=>'0');

type pp_array2 is array(2 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
signal x1, x2: pp_array2;
signal sum_final: pp_array2;
signal carries_final : pp_array2;
signal cout_final: STD_LOGIC_VECTOR (4 downto 0):= (others=>'0');

begin

--    lut_inst0: LUT6_2
--        generic map(INIT => X"F000000F81818181") 
--        port map(
--            I0 => '0', 
--            I1 => b(0),  
--            I2 => b(1), 
--            I3 => b(2),  
--            I4 => b(3), 
--            I5 => '1', 
--            O5 => zero_out(0), 
--            O6 => zero_out(1));
--	lut_inst1: LUT6_2
--        generic map(INIT => X"F000000F81818181") 
--        port map(
--            I0 => b(3), 
--            I1 => b(4),  
--            I2 => b(5), 
--            I3 => b(6),  
--            I4 => b(7), 
--            I5 => '1', 
--            O5 => zero_out(2), 
--            O6 => zero_out(3));
			

	lut_inst2: LUT6_2
        generic map(INIT => X"00000FF006060606") 
        port map(
            I0 => '0', 
            I1 => b(0),  
            I2 => b(1), 
            I3 => b(2),  
            I4 => b(3), 
            I5 => '1', 
            O5 => plus1_out(0), 
            O6 => plus1_out(1));
	lut_inst3: LUT6_2
        generic map(INIT => X"00000FF006060606") 
        port map(
            I0 => b(3), 
            I1 => b(4),  
            I2 => b(5), 
            I3 => b(6),  
            I4 => b(7), 
            I5 => '1', 
            O5 => plus1_out(2), 
            O6 => plus1_out(3));
			
			
	lut_inst4: LUT6_2
        generic map(INIT => X"0FF0000060606060") 
        port map(
            I0 => '0', 
            I1 => b(0),  
            I2 => b(1), 
            I3 => b(2),  
            I4 => b(3), 
            I5 => '1', 
            O5 => minus1_out(0), 
            O6 => minus1_out(1));
	lut_inst5: LUT6_2
        generic map(INIT => X"0FF0000060606060") 
        port map(
            I0 => b(3), 
            I1 => b(4),  
            I2 => b(5), 
            I3 => b(6),  
            I4 => b(7), 
            I5 => '1', 
            O5 => minus1_out(2), 
            O6 => minus1_out(3));
			
	
	lut_inst6: LUT6_2
        generic map(INIT => X"0000F00008080808") 
        port map(
            I0 => '0', 
            I1 => b(0),  
            I2 => b(1), 
            I3 => b(2),  
            I4 => b(3), 
            I5 => '1', 
            O5 => plus2_out(0), 
            O6 => plus2_out(1));
	lut_inst7: LUT6_2
        generic map(INIT => X"0000F00008080808") 
        port map(
            I0 => b(3), 
            I1 => b(4),  
            I2 => b(5), 
            I3 => b(6),  
            I4 => b(7), 
            I5 => '1', 
            O5 => plus2_out(2), 
            O6 => plus2_out(3));
			
			
	lut_inst8: LUT6_2
        generic map(INIT => X"000F000010101010") 
        port map(
            I0 => '0', 
            I1 => b(0),  
            I2 => b(1), 
            I3 => b(2),  
            I4 => b(3), 
            I5 => '1', 
            O5 => minus2_out(0), 
            O6 => minus2_out(1));
	lut_inst9: LUT6_2
        generic map(INIT => X"000F000010101010") 
        port map(
            I0 => b(3), 
            I1 => b(4),  
            I2 => b(5), 
            I3 => b(6),  
            I4 => b(7), 
            I5 => '1', 
            O5 => minus2_out(2), 
            O6 => minus2_out(3));
            
            
    -- 2's complement of 'a'
    a_comp <= STD_LOGIC_VECTOR(not UNSIGNED(a) + 1);
    

	all_pp_gen:
	for j in 0 to 3 generate
	   gen(j)(0) <= (plus1_out(j) and a(0)) or (minus1_out(j) and a_comp(0));
        pp_gen1:
        for i in 1 to 7 generate
            gen(j)(i) <= (plus1_out(j) and a(i)) or (minus1_out(j) and a_comp(i)) or (plus2_out(j) and a(i-1)) or (minus2_out(j) and a_comp(i-1));
        end generate pp_gen1;
        gen(j)(8) <= (plus1_out(j) and a(7)) or (minus1_out(j) and a_comp(7)) or (plus2_out(j) and a(7)) or (minus2_out(j) and a_comp(7));
    
        pp_fill1:
           for i in 9 to 15 generate
               gen(j)(i) <= gen(j)(8);
        end generate pp_fill1;
    end generate all_pp_gen;
    
	
	s1(0)(0) <= gen(0)(0) and '0';
    s2(0)(0) <= gen(0)(0) xor '0';
    s1(0)(1) <= gen(0)(1) and '0';
    s2(0)(1) <= gen(0)(1) xor '0';
    s1(0)(2) <= gen(0)(2) and gen(1)(0);
    s2(0)(2) <= gen(0)(2) xor gen(1)(0);
    s1(0)(3) <= gen(0)(3) and gen(1)(1);
    s2(0)(3) <= gen(0)(3) xor gen(1)(1);

	prep_01: for j in 1 to 3 generate 
	GEN_SUM0: for i in 0 to 3 generate       
            s1(j)(i) <= gen(0)(i+j*4) and gen(1)(i-2+j*4);
            s2(j)(i) <= gen(0)(i+j*4) xor gen(1)(i-2+j*4);
        end generate;
    end generate;
	
    row01: for j in 0 to 3 generate  
        carry_inst0: CARRY4
        port map (
            DI      => s1(j),        
            S       => s2(j),        
            O       => sum(j),       
            CO      => carries(j),   
            CI      => cout(j),       
            CYINIT  => '0'        
        );  
        cout(j+1) <= carries(j)(3);          --Final carry-out
    end generate;
    
    
    s1(4)(0) <= '0';
    s2(4)(0) <= gen(2)(0) xor '0';
    s1(4)(1) <= '0';
    s2(4)(1) <= gen(2)(1) xor '0';
    s1(4)(2) <= gen(2)(2) and gen(3)(0);
    s2(4)(2) <= gen(2)(2) xor gen(3)(0);
    s1(4)(3) <= gen(2)(3) and gen(3)(1);
    s2(4)(3) <= gen(2)(3) xor gen(3)(1);

	prep_23: for j in 1 to 2 generate 
	GEN_SUM1: for i in 0 to 3 generate       
            s1(j+4)(i) <= gen(2)(i+j*4) and gen(3)(i-2+j*4);
            s2(j+4)(i) <= gen(2)(i+j*4) xor gen(3)(i-2+j*4);
        end generate;
    end generate;
	
    row23: for j in 4 to 6 generate  
        -- Carry Chain Instantiation
        carry_inst1: CARRY4
        port map (
            DI      => s1(j),        
            S       => s2(j),        
            O       => sum(j),       
            CO      => carries(j),   
            CI      => cout(j+1),  
            CYINIT  => '0'        
        );
        cout(j+2) <= carries(j)(3);         --Final carry-out
    end generate;
	
	
	
	prep_final: for j in 0 to 2 generate 
	GEN_SUM2: for i in 0 to 3 generate       
            x1(j)(i) <= sum(j+1)(i) and sum(j+4)(i);
            x2(j)(i) <= sum(j+1)(i) xor sum(j+4)(i);
        end generate;
    end generate;
	final_sum: for j in 0 to 2 generate 
        carry_inst2: CARRY4
        port map (
            DI      => x1(j),        
            S       => x2(j),      
            O       => sum_final(j),       
            CO      => carries_final(j),  
            CI      => cout_final(j),   
            CYINIT  => '0'       
        );
        cout_final(j+1) <= carries_final(j)(3);       --Final carry-out
    end generate;
	
	final_prod0: for i in 0 to 3 generate
	   prod(i) <= sum(0)(i);
	   prod(i+4) <= sum_final(0)(i);
       prod(i+8) <= sum_final(1)(i);
	   prod(i+12) <= sum_final(2)(i);
	end generate;

	

	
	
    -- Ssum0<= sum(0);
    -- Ssum1<= sum(1);
    -- Ssum2<= sum(2);
    -- Ssum3<= sum(3);
    -- Ssum4<= sum(4);
    -- Ssum5<= sum(5);
    -- Ssum6<= sum(6);
    -- Scout <= cout;
    
    -- Sa_comp <= a_comp;
    
   -- Szero_out <= zero_out; 
    -- Splus1_out <= plus1_out; 
    -- Sminus1_out <= minus1_out;
    -- Splus2_out <= plus2_out;
    -- Sminus2_out <= minus2_out;
   
    -- Sgen0 <= gen(0);
    -- Sgen1 <= gen(1);
    -- Sgen2 <= gen(2);
    -- Sgen3 <= gen(3);
    
end Behavioral;