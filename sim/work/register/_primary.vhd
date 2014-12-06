library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        WIDTH           : integer := 32;
        RESET_VALUE     : integer := 0
    );
    port(
        d               : in     vl_logic_vector;
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        enable          : in     vl_logic;
        q               : out    vl_logic_vector
    );
end \register\;
