library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
 
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity Vga_Driver is
    Port ( CLK_50MHz : in  STD_LOGIC;
           RGB : in  STD_LOGIC_VECTOR (2 downto 0);
           VGA_R : out  STD_LOGIC;
           VGA_G : out  STD_LOGIC;
           VGA_B : out  STD_LOGIC;
           VGA_HS : out  STD_LOGIC;
           VGA_VS : out  STD_LOGIC;
           PIX_X : out  STD_LOGIC_VECTOR (9 downto 0);
           PIX_Y : out  STD_LOGIC_VECTOR (8 downto 0));
end vga_driver;
 
architecture Behavioral of Vga_Driver is
    constant vertical_sync_pulse_time : integer := 521;
	 constant vertical_pulse_width : integer := 2;
	 constant vertical_front_porch : integer := 10;
	 constant vertical_back_porch : integer := 29;
	 
	 constant horizontal_sync_pulse_time : integer := 800;
	 constant horizontal_pulse_width : integer := 96;
	 constant horizontal_front_porch : integer := 16;
	 constant horizontal_back_porch : integer := 48;
   
    signal clk_25 : STD_LOGIC := '0';
    signal h_cnt : integer := 0;
    signal v_cnt : integer := 0;
   
begin
 
    clk_div : process(CLK_50MHz)
    begin
        if (rising_edge(CLK_50MHZ)) then
            clk_25 <= not clk_25;
        end if;
    end process clk_div;
   
    counters : process(clk_25)
    begin
        if (rising_edge(clk_25)) then
            if ( h_cnt < horizontal_sync_pulse_time - 1) then
                h_cnt <= h_cnt + 1;
            else
                h_cnt <= 0;
               
                if ( v_cnt < vertical_sync_pulse_time - 1) then
                    v_cnt <= v_cnt + 1;
                else
                    v_cnt <= 0;
                end if;
            end if;
        end if;
    end process counters;
   
    h_sync : process(h_cnt)
    begin
      if (h_cnt < horizontal_pulse_width ) then
         VGA_HS <= '0';
      else
         VGA_HS <= '1';
      end if;
    end process h_sync;
   
    v_sync : process(v_cnt)
    begin
      if (v_cnt < vertical_pulse_width ) then
         VGA_VS <= '0';
      else
         VGA_VS <= '1';
      end if;
    end process v_sync;
   
    color_pixel : process(h_cnt, v_cnt, RGB)
    begin
        if (( h_cnt >= horizontal_pulse_width + horizontal_back_porch and h_cnt < horizontal_sync_pulse_time - horizontal_front_porch ) and (v_cnt >= vertical_pulse_width + vertical_back_porch and v_cnt < vertical_sync_pulse_time - vertical_front_porch )) then
            VGA_R <= RGB(2);
            VGA_G <= RGB(1);
            VGA_B <= RGB(0);
           
            PIX_X <= std_logic_vector(to_unsigned(h_cnt - ( horizontal_pulse_width + horizontal_back_porch ), 10));
            PIX_Y <= std_logic_vector(to_unsigned(v_cnt - ( vertical_pulse_width + vertical_back_porch ), 9));
        else
            VGA_R <= '0';
            VGA_G <= '0';
            VGA_B <= '0';
           
            PIX_X <= std_logic_vector(to_unsigned(640, 10));
            PIX_Y <= std_logic_vector(to_unsigned(480, 9));
        end if;
    end process color_pixel;
   
end Behavioral;