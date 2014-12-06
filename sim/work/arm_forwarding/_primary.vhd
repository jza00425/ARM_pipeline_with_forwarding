library verilog;
use verilog.vl_types.all;
entity arm_forwarding is
    port(
        data0_reg_num   : in     vl_logic_vector(3 downto 0);
        data1_reg_num   : in     vl_logic_vector(3 downto 0);
        data2_reg_num   : in     vl_logic_vector(3 downto 0);
        mask_of_real_read_reg: in     vl_logic_vector(2 downto 0);
        EXID_rd_we      : in     vl_logic;
        MEMID_rd_we     : in     vl_logic;
        EXID_rd_num     : in     vl_logic_vector(3 downto 0);
        MEMID_rd_num    : in     vl_logic_vector(3 downto 0);
        EXID_alu_or_mac : in     vl_logic;
        EXID_is_alu_for_mem_addr: in     vl_logic;
        forward         : out    vl_logic
    );
end arm_forwarding;
