library verilog;
use verilog.vl_types.all;
entity hazard_detect is
    port(
        rst_b           : in     vl_logic;
        mask_of_real_read_reg: in     vl_logic_vector(2 downto 0);
        read_reg_num    : in     vl_logic;
        IDEX_rd_we      : in     vl_logic;
        IDEX_is_alu_for_mem_addr: in     vl_logic;
        IDEX_rd_num     : in     vl_logic_vector(3 downto 0);
        stall           : out    vl_logic;
        IFID_Write      : out    vl_logic;
        PCWrite         : out    vl_logic
    );
end hazard_detect;
