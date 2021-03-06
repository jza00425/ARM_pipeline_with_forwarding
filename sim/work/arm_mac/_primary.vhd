library verilog;
use verilog.vl_types.all;
entity arm_mac is
    port(
        mac_op1         : in     vl_logic_vector(31 downto 0);
        mac_op2         : in     vl_logic_vector(31 downto 0);
        mac_acc         : in     vl_logic_vector(31 downto 0);
        mac_sel         : in     vl_logic;
        alu_or_mac      : in     vl_logic;
        mac_out         : out    vl_logic_vector(31 downto 0);
        mac_cpsr        : out    vl_logic_vector(3 downto 0)
    );
end arm_mac;
