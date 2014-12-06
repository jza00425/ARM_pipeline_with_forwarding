library verilog;
use verilog.vl_types.all;
entity arm_wb_stage is
    port(
        clk             : in     vl_logic;
        MEMWB_data_read_from_mem: in     vl_logic_vector(31 downto 0);
        MEMWB_rd_data   : in     vl_logic_vector(31 downto 0);
        MEMWB_rd_we     : in     vl_logic;
        MEMWB_rd_data_sel: in     vl_logic;
        MEMWB_des_reg_num: in     vl_logic_vector(3 downto 0);
        WB_data         : out    vl_logic_vector(31 downto 0);
        WB_rd_we        : out    vl_logic;
        WB_des_reg_num  : out    vl_logic_vector(3 downto 0)
    );
end arm_wb_stage;
