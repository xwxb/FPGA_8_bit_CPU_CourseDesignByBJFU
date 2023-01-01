library verilog;
use verilog.vl_types.all;
entity light_show is
    port(
        light_clk       : in     vl_logic;
        SW_choose       : in     vl_logic;
        check_in        : in     vl_logic_vector(7 downto 0);
        State           : in     vl_logic_vector(1 downto 0);
        MAR             : in     vl_logic_vector(7 downto 0);
        r0              : in     vl_logic_vector(7 downto 0);
        r1              : in     vl_logic_vector(7 downto 0);
        Z               : in     vl_logic;
        HEX0            : out    vl_logic_vector(6 downto 0);
        HEX1            : out    vl_logic_vector(6 downto 0);
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        HEX4            : out    vl_logic_vector(6 downto 0);
        HEX5            : out    vl_logic_vector(6 downto 0);
        HEX6            : out    vl_logic_vector(6 downto 0);
        HEX7            : out    vl_logic_vector(6 downto 0);
        State_LED       : out    vl_logic_vector(1 downto 0);
        quick_low_led   : out    vl_logic
    );
end light_show;
