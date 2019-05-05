
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Grafika is
	 Port ( pix_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  pix_y : in  STD_LOGIC_VECTOR (8 downto 0);
			  CLK_50MHz : in  STD_LOGIC;
			  cir_in_vec_x : in  STD_LOGIC_VECTOR (9 downto 0);
			  cir_in_vec_y : in  STD_LOGIC_VECTOR (8 downto 0);
			  player_A_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  player_B_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  gol : in STD_LOGIC_VECTOR (1 downto 0);
			  frame_ox_in : in STD_LOGIC_VECTOR (7 downto 0);
			  points : in STD_LOGIC_VECTOR (7 downto 0);
			  TRAP : IN STD_LOGIC;
			  RGB : out  STD_LOGIC_VECTOR (2 downto 0));
end grafika;

architecture Behavioral of Grafika is
	type SmallerInteger is range 0 to 640;

----------------------------------------------------------------------------------

	function SquareRoot (Arg: unsigned) return unsigned is 

		constant AMSB: integer:= Arg'length-1; 
		constant RMSB: integer:= (Arg'length/2) - 1; 
		variable Root: unsigned(RMSB downto 0); 
		variable Test: unsigned(RMSB+1 downto 0); 
		variable Rest: unsigned(AMSB+1 downto 0); 

	begin 
			 Root := (others => '0'); 
			 Rest := '0' & Arg; 
			 for i in RMSB downto 0 loop 
				 Test := Root(RMSB-1 downto 0 ) & "01";   
				  if Test(RMSB-i+1 downto 0) > 
					  Rest(AMSB+1 downto 2*i) then 
						Root := Root(RMSB-1 downto 0) & '0'; 
				  else 
						Root := Root(RMSB-1 downto 0) & '1'; 
						Rest(AMSB downto i*2) := Rest(AMSB downto i*2) - 
						Test(RMSB-i+1 downto 0); 
				  end if; 
			 end loop; 
		return Root; 
	end;

----------------------------------------------------------------------------------

	function Horizontal( pos_x, pos_y, pix_x, pix_y : SmallerInteger ) return STD_LOGIC is
			constant width : SmallerInteger := 10;
			constant height : SmallerInteger := 1;
	begin
			if ( pix_x >= pos_x AND pix_x <= pos_x + width ) then
					if ( pix_y >= pos_y AND pix_y <= pos_y + height ) then
							return '1';
					else
							return '0';
					end if;
			else
					return '0';
			end if;
	end;
			
----------------------------------------------------------------------------------

	function Vertical( pos_x, pos_y, pix_x, pix_y : SmallerInteger ) return STD_LOGIC is
			constant width : SmallerInteger := 1;
			constant height : SmallerInteger := 15;
	begin
			if ( pix_x >= pos_x AND pix_x <= pos_x + width ) then
					if ( pix_y >= pos_y AND pix_y <= pos_y + height ) then
							return '1';
					else
							return '0';
					end if;
			else
					return '0';
			end if;
	end;
   
----------------------------------------------------------------------------------

   function DrawSegment( pos_x, pos_y, pix_x, pix_y, Sum_input : SmallerInteger ) return STD_LOGIC is
         constant width : SmallerInteger := 10;
			constant height : SmallerInteger := 15;
         variable Sum : SmallerInteger;
   
   begin
         Sum := Sum_input;
         
         if ( Sum >= 64 ) then
               if ( Horizontal( pos_x, pos_y, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 64;
         end if;
         
         if ( Sum >= 32 ) then
               if ( Vertical( pos_x + width, pos_y, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 32;
         end if;
         
         if ( Sum >= 16 ) then
               if ( Vertical( pos_x + width, pos_y + height, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 16;
         end if;
        
         if ( Sum >= 8  ) then
               if ( Horizontal( pos_x, pos_y + 2 * height, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 8;
         end if;
         
         if ( Sum >= 4 ) then
               if ( Vertical( pos_x, pos_y + height, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 4;
         end if;
         
         if ( Sum >= 2 ) then
               if ( Vertical( pos_x, pos_y, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 2;
         end if;
         
         if ( Sum >= 1 ) then
               if ( Horizontal( pos_x, pos_y + height, pix_x, pix_y ) = '1' ) then
                     return '1';
               end if;
               Sum := Sum - 1;
         end if;
         
         return '0';
        
   end;

----------------------------------------------------------------------------------

	function SingleDigit( pos_x, pos_y, number, pix_x, pix_y : SmallerInteger ) return STD_LOGIC is 
         variable bool : STD_LOGIC;
			
	begin
         bool := '0';
			case number is
					when 0 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 126 ) = '1' ) then
                           bool := '1';
                     end if;
               when 1 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 48 ) = '1' ) then
                           bool := '1';
                     end if;
               when 2 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 109 ) = '1' ) then
                           bool := '1';
                     end if;
               when 3 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 121 ) = '1' ) then
                           bool := '1';
                     end if;
               when 4 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 51 ) = '1' ) then
                           bool := '1';
                     end if;
               when 5 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 91 )= '1' ) then
                           bool := '1';
                     end if;
               when 6 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 95 )= '1' ) then
                           bool := '1';
                     end if;
               when 7 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 112 )= '1' ) then
                           bool := '1';
                     end if;
               when 8 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 127 )= '1' ) then
                           bool := '1';
                     end if;
               when 9 =>
                     if ( DrawSegment( pos_x, pos_y, pix_x, pix_y, 123 )= '1' ) then
                           bool := '1';
                     end if;
               when others =>
                     return '0';
			end case;
         if ( bool = '1') then
               return '1';
         else
               return '0';
         end if;
	end;

----------------------------------------------------------------------------------
	
	function DoubleDigit ( pos_x, pos_y, number, pix_x, pix_y : SmallerInteger ) return STD_LOGIC is
			constant distance : SmallerInteger := 15;
	begin
			if ( number >= 10 ) then
					if ( SingleDigit ( pos_x, pos_y, 1, pix_x, pix_y ) = '1' ) then
							return '1';
					elsif ( SingleDigit ( pos_x + distance, pos_y, number - 10, pix_x, pix_y ) = '1' ) then
							return '1';
					else
							return '0';
					end if;
			else
					if ( SingleDigit ( pos_x + distance, pos_y, number, pix_x, pix_y ) = '1' ) then
							return '1';
					else
							return '0';
					end if;
			end if;
	end;
					
----------------------------------------------------------------------------------
	
	constant horizontal_max : integer := 639;
	constant vertical_max : integer := 479;
	constant r : integer := 3;
	constant frame_oy : integer := 15;
	constant player_a_x : integer := 35;
	constant player_b_x : integer := 599;
	constant player_width : integer := 5;
	constant max_points : integer := 15;

	signal player_a_y : integer range 0 to vertical_max;
	signal player_b_y : integer range 0 to vertical_max;
	
	signal player_a_length : integer range 0 to vertical_max;
	signal player_b_length : integer range 0 to vertical_max;

	signal pix_x_value : integer range 0 to horizontal_max + 1;
	signal pix_y_value : integer range 0 to vertical_max + 1;
	
	signal cir_x : integer range 0 to horizontal_max;
	signal cir_y : integer range 0 to vertical_max;

	signal clk_gol : STD_LOGIC := '0';
	
	signal gol_colour : STD_LOGIC_VECTOR (2 downto 0) := "111";
	
	signal clk_gol_cnt : integer range 0 to 7500000;

   signal frame_OX : integer range 10 to 200;
	
	signal points_a : integer range 0 to max_points;
	signal points_b : integer range 0 to max_points;


begin
	
	points_a <= to_integer( unsigned( points( 7 downto 4 ) ));
	points_b <= to_integer( unsigned( points( 3 downto 0 ) ));

   pix_x_value <= to_integer( unsigned( PIX_X ) );
   pix_y_value <= to_integer( unsigned( PIX_Y ) );

   cir_x <= to_integer( unsigned( cir_in_vec_x ) );
   cir_y <= to_integer( unsigned( cir_in_vec_y ) );

   player_a_y <= to_integer( unsigned (player_A_in(8 downto 0)) );
   player_b_y <= to_integer( unsigned (player_B_in(8 downto 0)) );

   player_A_length <= to_integer( unsigned( PLAYER_A_IN (15 downto 9) ) );
   player_B_length <= to_integer( unsigned( PLAYER_B_IN (15 downto 9) ) );

   frame_ox <= to_integer ( unsigned (frame_ox_in) );
   
   
	
----------------------------------------------------------------------------------
	
	process(CLK_50MHz)
	begin
	
		if (rising_edge(CLK_50MHZ)) then
				if clk_gol_cnt < 7500000 then  
					clk_gol_cnt <= clk_gol_cnt + 1;
				else
					clk_gol <= not clk_gol;
					clk_gol_cnt <= 0;
				end if;
		end if;
      
	end process;
	
----------------------------------------------------------------------------------

	process (clk_gol)
	begin
	
		if ( rising_edge( clk_gol ) ) then
			if ( points_a = max_points OR points_b = max_points ) then
				gol_colour (2) <= not gol_colour(2);
				gol_colour (0) <= not gol_colour(0);
			elsif ( gol = "01" OR gol = "10" ) then
				gol_colour (1) <= not gol_colour(1);
				gol_colour (0) <= not gol_colour(0);
			else
				gol_colour <= "111";
			end if;
		end if;

	end process;
	
---------------------------------------------------------------------------------

	process (cir_x, cir_y, pix_x_value, pix_y_value, player_a_y, player_a_length, player_b_y, player_b_length, gol, gol_colour, frame_ox, points_a, points_b, trap) 
	begin	
         -- czarne tlo
         if ( pix_y_value > frame_ox AND pix_y_value <  vertical_max - frame_ox AND pix_x_value > frame_oy AND pix_x_value < horizontal_max - frame_oy ) then
               RGB <= "000";
         end if;

      
         -- punktacja
         if ( DoubleDigit( 150, 220, SmallerInteger(points_a), SmallerInteger(pix_x_value), SmallerInteger(pix_y_value) ) = '1' ) then
               RGB <= "111";
         end if;
         
         if ( DoubleDigit( 450, 220, SmallerInteger(points_b), SmallerInteger(pix_x_value), SmallerInteger(pix_y_value) ) = '1' ) then
               RGB <= "111";
         end if;
         
         
         -- pilka
         if ( points_a < max_points AND points_b < max_points) then
            if ( to_integer ( SquareRoot ( to_unsigned( (pix_x_value - cir_x) * (pix_x_value - cir_x) + (pix_y_value - cir_y) * (pix_y_value - cir_y), 20) ) ) <= r ) then
               RGB <= "101";
            end if;
         end if;  

         -- gracz a i b
         if ( (pix_x_value >= player_a_x AND pix_x_value <= player_a_x + player_width) AND (pix_y_value >= player_a_y AND pix_y_value <= player_a_y + player_a_length) ) then
            RGB <= "110";
         end if;
         
         if ( ( pix_x_value >= player_b_x AND pix_x_value <= player_b_x + player_width) AND (pix_y_value >= player_b_y AND pix_y_value <= player_b_y + player_b_length) ) then
            RGB <= "110";
         end if;


         -- tlo i ramka
         if ( pix_y_value <= frame_ox OR pix_y_value >= vertical_max - frame_ox ) then
               if ( pix_x_value <= horizontal_max/2 AND points_a = max_points ) then
                     RGB <= gol_colour;
               elsif ( pix_x_value > horizontal_max/2 AND points_b = max_points ) then
                     RGB <= gol_colour;
               else
                     RGB <= "111";
               end if;
         else
               if ( pix_x_value <= frame_oy ) then
                     if ( points_a = max_points ) then 
                           RGB <= gol_colour;
                     elsif ( gol = "01" AND points_b /= max_points ) then
                           RGB <= gol_colour;
                     else
                           RGB <= "111";
                     end if;
               elsif  ( pix_x_value >= horizontal_max - frame_oy ) then
                     if ( points_b = max_points ) then
                           RGB <= gol_colour;
                     elsif ( gol = "10" AND points_a /= max_points ) then
                           RGB <= gol_colour;
                     else
                           RGB <= "111";
                     end if;
               else
                     NULL;
               end if;
         end if;
        

         -- pulpaka
         if ( trap = '1' AND pix_x_value = horizontal_max/2) then
               if ( pix_y_value > cir_y - r - 10 AND pix_y_value > frame_ox AND pix_y_value < vertical_max - frame_ox AND pix_y_value < cir_y + r + 10 ) then
                        RGB <= "011";
               end if;
         end if;

   end process; 
	
---------------------------------------------------------------------------------

end Behavioral;

