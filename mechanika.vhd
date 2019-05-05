library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mechanika is
    Port ( CLK_50MHz : in  STD_LOGIC;
			  RESET : in STD_LOGIC;
           CIRCLE_OUT_X : out  STD_LOGIC_VECTOR (9 downto 0);
           CIRCLE_OUT_Y : out  STD_LOGIC_VECTOR (8 downto 0);
           PLAYER_A_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           PLAYER_B_IN : in  STD_LOGIC_VECTOR (15 downto 0);
			  PAUSE : IN STD_LOGIC;
			  TRAP : out STD_LOGIC;
           GOL : out  STD_LOGIC_VECTOR (1 downto 0);
           FRAME_OX_OUT : out  STD_LOGIC_VECTOR (7 downto 0);
			  POINTS : OUT STD_LOGIC_VECTOR (7 downto 0));
end Mechanika;

architecture Behavioral of Mechanika is

	constant horizontal_max : integer := 639;
	constant vertical_max : integer := 479;
	constant r : integer := 3;
	constant frame_OY : integer := 15;
	constant player_width : integer := 5;
	constant max_points : integer := 15;
	constant player_a_x : integer := 35;
	constant player_b_x : integer := 599;
   constant starting_ball_speed : integer := 150000;
	
	signal frame_OX : integer range 10 to 200 := 10;
	
	signal player_a_y : integer range 0 to vertical_max;
	signal player_b_y : integer range 0 to vertical_max;
	
	signal player_a_length : integer range 0 to 100;
	signal player_b_length : integer range 0 to 100;
	
	signal player_a_points : integer range 0 to max_points := 0;
	signal player_b_points : integer range 0 to max_points := 0;
	
	signal cir_x : integer range 0 to horizontal_max := horizontal_max / 2;
	signal cir_y : integer range 0 to vertical_max := vertical_max / 2;
	
	signal direction_x : integer range -1 to 1 := 1;
	signal direction_y : integer range -1 to 1 := 1;
	
	signal ball_counter : integer range 0 to starting_ball_speed;
	
   signal clk_gol : STD_LOGIC := '0';
   signal clk_gol_cnt : integer range 0 to starting_ball_speed + 50000;
   
	signal clk_ball : STD_LOGIC := '0';
	signal clk_ball_cnt : integer range 0 to starting_ball_speed;
	
	signal probability : integer range 0 to 1000;
	signal trap_buffer : STD_LOGIC := '0';
   
	signal gol_time_counter : integer range 0 to 300;  

   signal thr_proc_1 : STD_LOGIC := '0';
   signal thr_proc_2 : STD_LOGIC := '0';
   
   signal locker : STD_LOGIC := '0';
	

begin

   circle_out_X <= std_logic_vector(to_unsigned( cir_x, 10 ));
   circle_out_Y <= std_logic_vector(to_unsigned( cir_y, 9 ));
   
   frame_ox_out <= STD_LOGIC_VECTOR( to_unsigned( frame_ox, 8 ) );			
   points <= STD_LOGIC_VECTOR ( to_unsigned ( player_a_points, 4 ) ) & STD_LOGIC_VECTOR ( to_unsigned ( player_b_points, 4 ) );
   
   player_A_y <= to_integer( unsigned( PLAYER_A_IN (8 downto 0) ) );
   player_A_length <= to_integer( unsigned( PLAYER_A_IN (15 downto 9) ) );
   
   player_B_y <= to_integer( unsigned( PLAYER_B_IN (8 downto 0) ) );
   player_B_length <= to_integer( unsigned( PLAYER_B_IN (15 downto 9) ) );
  
----------------------------------------------------------------------------------
	
	process(CLK_50MHz)
   begin
	
		if (rising_edge(CLK_50MHZ)) then
				if clk_ball_cnt < ball_counter then
					clk_ball_cnt <= clk_ball_cnt + 1;
				else
					clk_ball <= not clk_ball;
					clk_ball_cnt <= 0;
				end if;
				
            if clk_gol_cnt < starting_ball_speed + 50000 then
					clk_gol_cnt <= clk_gol_cnt + 1;
				else
					clk_gol <= not clk_gol;
					clk_gol_cnt <= 0;
				end if;
            
				if probability < 1000 then
						probability <= probability + 1;
				else
						probability <= 0;
				end if;
		end if;
		
	end process;

----------------------------------------------------------------------------------

	process ( clk_gol )
	begin

		if ( rising_edge( clk_gol ) ) then
            if ( thr_proc_1 = '1' ) then
                  if ( gol_time_counter < 200 ) then
                        thr_proc_2 <= '1';
                        gol_time_counter <= gol_time_counter + 1;
                  else
                        if ( player_a_points < max_points AND player_b_points < max_points ) then
                              thr_proc_2 <= '0';
                        end if;
                        gol_time_counter <= 0;
                  end if;
            else
                  thr_proc_2 <= '0';
                  gol_time_counter <= 0;
            end if;
       end if;
		
	end process;
	
----------------------------------------------------------------------------------

	process (clk_ball) -- poruszanie pilka
	begin
	
		if (rising_edge( clk_ball )) then
			if ( pause = '0' ) then
					if ( ball_counter > 75000 ) then
							ball_counter <= ball_counter - 50;
					elsif ( ball_counter > 50000 ) then
                     ball_counter <= ball_counter - 10;
               elsif ( ball_counter > 10000 ) then
                     ball_counter <= ball_counter - 1;
               end if;
			
					cir_x <= cir_x + direction_x;
					cir_y <= cir_y + direction_y;
			
				-- uderzenie gracza w sciane od srodka mapy	
					if ( cir_x - r + direction_x <= player_a_x + player_width AND cir_x - r + direction_x > player_a_x AND cir_y <= player_a_y + player_a_length AND cir_y >= player_a_y ) then
							direction_x <= 1;
							if ( cir_x - r < player_a_x + player_width AND cir_x + r > player_a_x ) then
									cir_x <= player_a_x + player_width + r + 1;
							end if;
							if ( probability < 150 ) then
									trap <= '1';
									trap_buffer <= '1';
							end if;
					end if;
					
					if ( cir_x + r + direction_x >= player_b_x AND cir_x + r + direction_x < player_b_x + player_width AND cir_y <= player_b_y + player_b_length AND cir_y >= player_b_y ) then
							direction_x <= -1;
							if ( cir_x + r > player_b_x AND cir_x - r < player_b_x + player_width ) then
									cir_x <= player_b_x - r - 1;
							end if;
							if ( probability < 150 ) then
									trap <= '1';
									trap_buffer <= '1';
							end if;
					end if;
					
				-- uderzenie gracza od spodu lub gory
					if ( cir_y - r + direction_y <= player_a_y + player_a_length AND cir_y - r + direction_y > player_a_y + player_a_length / 2 AND cir_x >= player_a_x AND cir_x <= player_a_x + player_width ) then
							direction_y <= 1;
							if ( cir_y - r > player_a_y + player_a_length / 2 AND cir_y - r < player_a_y + player_a_length) then
									cir_y <= player_a_y + player_a_length + r;
							end if;
					end if;
					
					if ( cir_y + r + direction_y >= player_a_y AND cir_x >= player_a_x AND cir_x <= player_a_x + player_width AND cir_y + r + direction_y < player_a_y + player_a_length ) then
							direction_y <= -1;
							if ( cir_y + r > player_a_y AND cir_y + r < player_a_y + player_a_length / 2 ) then
									cir_y <= player_a_y - r;
							end if;
					end if;
							
					if ( cir_y - r + direction_y <= player_b_y + player_b_length AND cir_y - r + direction_y > player_b_y + player_b_length / 2 AND cir_x >= player_b_x AND cir_x <= player_b_x + player_width) then
							direction_y <= 1;
							if ( cir_y - r > player_b_y + player_b_length / 2 AND cir_y - r < player_b_y + player_b_length ) then
									cir_y <= player_b_y + player_b_length + r;
							end if;
					end if;
			
					if ( cir_y + r + direction_y >= player_b_y AND cir_x >= player_b_x AND cir_x <= player_b_x + player_width AND cir_y + r + direction_y < player_b_y + player_b_length ) then
							direction_y <= -1;
							if ( cir_y + r > player_b_y AND cir_y + r < player_b_y + player_b_length / 2 ) then
									cir_y <= player_b_y - r;
							end if;
					end if;	
					
				-- krawedz mapy OX
					if ( cir_y + r + direction_y >= vertical_max - frame_ox OR cir_y - r + direction_y <= frame_ox) then
							direction_y <= direction_y * (-1);
					end if;
					
				-- uderzenie w pulapke
					if ( trap_buffer = '1' AND ( cir_x - r = horizontal_max/2 OR cir_x + r = horizontal_max/2 ) ) then
							direction_x <= direction_x * (-1);
							trap <= '0';
							trap_buffer <= '0';
					end if;
					
               
				-- krawedz mapy OY (jakis gol)
					if ( RESET = '0' AND thr_proc_2 = '0' AND locker = '0' ) then
                     if ( cir_x + r >= horizontal_max - frame_oy ) then
                           player_a_points <= player_a_points + 1;
                           gol <= "10";
                           thr_proc_1 <= '1';
                           locker <= '1';
                           frame_ox <= frame_ox + 4;
                           direction_x <= 1;
                           if ( probability < 500 ) then
                                 direction_y <= 1;
                           else
                                 direction_y <= -1;
                           end if;
                     elsif ( cir_x - r <= frame_oy ) then
                           player_b_points <= player_b_points + 1;
                           gol <= "01";
                           thr_proc_1 <= '1';
                           locker <= '1';
                           frame_ox <= frame_ox + 4;
                           direction_x <= -1;
                           if ( probability < 500 ) then
                                 direction_y <= 1;
                           else
                                 direction_y <= -1;
                           end if;
                     else
                           thr_proc_1 <= '0';
                           gol <= "00";
                     end if;
					else    
                     trap <= '0';
                     trap_buffer <= '0';
                     ball_counter <= starting_ball_speed;
                     cir_x <= horizontal_max / 2;
                     cir_y <= vertical_max / 2;
					end if;
               
			end if;
         
         if ( locker = '1' AND thr_proc_2 = '1' ) then
               locker <= '0';
         end if;
			
		-- przycisk reset
         if ( RESET = '1' ) then
					trap <= '0';
					trap_buffer <= '0';
					gol <= "11";
					thr_proc_1 <= '0';
               locker <= '0';
					player_a_points <= 0;
					player_b_points <= 0;
					frame_ox <= 10;
					if ( probability < 250 ) then
							direction_x <= 1;
							direction_y <= -1;
					elsif ( probability < 500 ) then
							direction_x <= -1;
							direction_y <= -1;
					elsif ( probability < 750 ) then
							direction_x <= -1;
							direction_y <= 1;
					else
							direction_x <= 1;
							direction_y <= 1;
					end if;
         end if;
         			
		end if;
	end process;

end Behavioral;

