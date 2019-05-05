library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity KbdDecode is
	Port (  KbdDO : in  STD_LOGIC_VECTOR( 7 downto 0 );
           KbdE0, KbdF0, KbdDataRdy : in  STD_LOGIC;
           CLK_50MHz : in STD_LOGIC; 
			  PUSHED_KEYS : out STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
			  PAUSE : out STD_LOGIC;
			  RESET : out STD_LOGIC);
end KbdDecode;

architecture Behavioral of KbdDecode is

   signal clk : STD_LOGIC := '0';
   signal counter : integer range 0 to 2500000;
   signal hold_time : integer range 0 to 4000;
   signal stay_time : integer range 0 to 2000;
   signal R_Pressed : STD_LOGIC := '0';
   signal Reset_buffer : STD_LOGIC := '1';
	signal pause_buffer : STD_LOGIC := '0';

begin



   process ( CLK_50MHz )
   begin
		if ( rising_edge ( CLK_50MHz ) ) then
            if counter < 25000 then
               counter <= counter + 1;
            else
               clk <= not clk;
               counter <= 0;
            end if;
            PAUSE <= pause_buffer;
		end if;
   

   end process;
   

	process( KbdDataRdy, CLK_50MHz )
	begin
      if ( rising_edge ( CLK_50MHz ) AND KbdDataRdy = '1' ) then      
         case KbdF0 & KbdE0 & KbdDO is

-- wcisniecia klawiszy

         when "00" & X"1D" => -- "W" 
            pushed_keys(3) <= '1';

         when "00" & X"1B" => -- "S" 
            pushed_keys(2) <= '1';

         when "01" & X"75" => -- "Gora"
            pushed_keys(1) <= '1';

         when "01" & X"72" => -- "Dol"
            pushed_keys(0) <= '1';      

         when "00" & X"2D" => -- "R"
            R_Pressed <= '1';
			
			when "00" & X"4D" => -- "P"
               pause_buffer <= not pause_buffer;

-- puszczenia klawiszy

         when "10" & X"1D" => -- "W"
            pushed_keys(3) <= '0';

         when "10" & X"1B" => -- "S"
            pushed_keys(2) <= '0';

         when "11" & X"75" => -- "Gora"
            pushed_keys(1) <= '0';

         when "11" & X"72" => -- "Dol"
            pushed_keys(0) <= '0';

         when "10" & X"2D" => -- "R"
         	R_Pressed <= '0';

-- #

         when others =>
            NULL;
                       
                       
         end case;
      end if;
		
  end process;
  
  
  
  process (clk)
  begin
  
      if ( rising_edge( clk ) ) then
         if ( R_pressed = '1' ) then
            stay_time <= 0;
            if ( hold_time < 4000 ) then
               hold_time <= hold_time + 1;
            else
               RESET <= '1';
               reset_buffer <= '1';
            end if;
         else
            hold_time <= 0;
            if ( reset_buffer = '1' ) then
               if ( stay_time < 2000 ) then
                  stay_time <= stay_time + 1;
               else
                  RESET <= '0';
                  reset_buffer <= '0';
               end if;
            end if;
         end if;
      end if;
    
  end process;

end Behavioral;

