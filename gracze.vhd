library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Gracze is
    Port ( CLK_50MHz : in  STD_LOGIC;
           PUSHED_KEYS : in  STD_LOGIC_VECTOR (3 downto 0);
           FRAME_OX_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           PLAYER_A : out  STD_LOGIC_VECTOR (15 downto 0);
           PLAYER_B : out  STD_LOGIC_VECTOR (15 downto 0);
			  GOL : in STD_LOGIC_VECTOR (1 downto 0);
			  PAUSE : IN STD_LOGIC;
			  RESET : in STD_LOGIC);
end gracze;

----------------------------------------------------------------------------------

architecture Behavioral of Gracze is

	constant horizontal_max : integer := 639;
	constant vertical_max : integer := 479;
	constant player_A_x : integer := 30;
	constant player_B_x : integer := 604;
	constant starting_player_length : integer := 100;
	constant starting_player_speed : integer := 70000;
	
	signal player_A_y : integer range 0 to vertical_max := 200;
	signal player_B_y : integer range 0 to vertical_max := 200;
	
	signal player_A_length : integer range 0 to starting_player_length := starting_player_length;
	signal player_B_length : integer range 0 to starting_player_length := starting_player_length;

	signal player_A_speed : integer range 70000 to 10000000 := starting_player_speed; -- szybkosc ruchu paletki
	signal player_B_speed : integer range 70000 to 10000000 := starting_player_speed;
	
   signal clk_pl_A : STD_LOGIC := '0';
   signal clk_pl_B : STD_LOGIC := '0';

   signal clk_pl_A_cnt : integer range 0 to 10000000;
   signal clk_pl_B_cnt : integer range 0 to 10000000;

	signal frame_OX : integer range 10 to 200;
	
	signal changed : STD_LOGIC := '0';


begin
	frame_OX <= to_integer( unsigned( FRAME_OX_IN ) );
	
----------------------------------------------------------------------------------
	
   process(CLK_50MHz)
   begin
	
		if (rising_edge(CLK_50MHZ)) then
			if clk_pl_A_cnt < player_A_speed then
				clk_pl_A_cnt <= clk_pl_A_cnt + 1;
			else
				clk_pl_A <= not clk_pl_A;
				clk_pl_A_cnt <= 0;
			end if; 

			if clk_pl_B_cnt < player_B_speed then
				clk_pl_B_cnt <= clk_pl_B_cnt + 1;
			else
				clk_pl_B <= not clk_pl_B;
				clk_pl_B_cnt <= 0;
			end if;
		end if;
		
	end process;
	
----------------------------------------------------------------------------------

   -- ruszanie graczami  
	process (clk_pl_a) 
	begin	
	
		if (rising_edge( clk_pl_a )) then
			if ( pause = '0' ) then
               if ( pushed_keys(3) = '1' AND pushed_keys(2) = '0' ) then
                     if ( player_a_y - frame_ox > 1) then
                           player_a_y <= player_a_y - 1;
                     else
                           player_a_y <= frame_ox;
                     end if;
               end if;
               
               if ( pushed_keys(2) = '1' AND pushed_keys(3) = '0' ) then
                     if ( vertical_max - frame_ox - (player_a_y + player_a_length) > 1) then
                           player_a_y <= player_a_y + 1;
                     else
                           player_a_y <= vertical_max - frame_ox - player_a_length;
                     end if;
               end if;
         end if;
			
         if ( player_a_y < frame_ox) then
              player_a_y <= frame_ox;
         end if;
         
         if ( player_a_y + player_a_length > vertical_max - frame_ox) then
               player_a_y <= vertical_max - frame_ox - player_a_length;
         end if;
        

         player_A <= std_logic_vector( to_unsigned( player_A_length, 7 ) ) & std_logic_vector( to_unsigned( player_A_y, 9 ) );

      end if;
      

	
   end process;
  
---------------------------------------------------------------------------------- 
    
   process (clk_pl_b) 
	begin	
	
    	if (rising_edge( clk_pl_b )) then	
			if ( pause = '0' ) then
               if ( pushed_keys(1) = '1' AND pushed_keys(0) = '0' ) then
                     if ( player_b_y - frame_ox > 1) then
                           player_b_y <= player_b_y - 1;
                     else
                           player_b_y <= frame_ox;
                     end if;
               end if;
               
               if ( pushed_keys(0) = '1' AND pushed_keys(1) = '0' ) then
                     if ( vertical_max - frame_ox - (player_b_y + player_b_length) > 1) then
                           player_b_y <= player_b_y + 1;
                     else
                           player_b_y <= vertical_max - frame_ox - player_b_length;
                     end if;
               end if;
         end if;
			
         if ( player_b_y < frame_ox) then
              player_b_y <= frame_ox;
         end if;
         
         if ( player_b_y + player_b_length > vertical_max - frame_ox) then
               player_b_y <= vertical_max - frame_ox - player_b_length;
         end if;
         			
         player_B <= std_logic_vector( to_unsigned( player_B_length, 7 ) ) & std_logic_vector( to_unsigned( player_B_y, 9 ) );

      end if;
		
         
	end process;  

----------------------------------------------------------------------------------

	process (CLK_50MHz)
	begin
		
		if ( rising_edge( CLK_50MHz ) ) then
				if ( RESET = '0' ) then
							if ( GOL = "10" OR GOL = "01" ) then
									if ( changed = '0' ) then
											if ( GOL = "10" ) then
													player_A_speed <= player_A_speed + (starting_player_speed / 50);
													player_A_length <= player_A_length - ( starting_player_length / 25 );
											else
													player_B_speed <= player_B_speed + (starting_player_speed / 50);
													player_B_length <= player_B_length - ( starting_player_length / 25 );
											end if;
											changed <= '1';
									end if;
							else
									changed <= '0';
							end if;
				 else
							player_A_speed <= starting_player_speed;
							player_B_speed <= starting_player_speed;
							player_A_length <= starting_player_length;
							player_B_length <= starting_player_length;
				 end if;
		end if;
	
	end process;
			
----------------------------------------------------------------------------------

end Behavioral;

