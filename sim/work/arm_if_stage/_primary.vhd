library verilog;
use verilog.vl_types.all;
entity arm_if_stage is
    port(
        pc              : in     vl_logic_vector(31 downto 0);
        IFID_Write      : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        clk             : in     vl_logic;
        next_pc         : out    vl_logic_vector(31 downto 0);
        IFID_inst       : out    vl_logic_vector(31 downto 0)
    );
end arm_if_stage;
