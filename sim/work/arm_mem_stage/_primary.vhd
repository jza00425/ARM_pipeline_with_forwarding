library verilog;
use verilog.vl_types.all;
entity arm_mem_stage is
    port(
        clk             : in     vl_logic;
        EXMEM_data_result: in     vl_logic_vector(31 downto 0);
        EXMEM_rd_data   : in     vl_logic_vector(31 downto 0);
        EXMEM_rd_we     : in     vl_logic;
        EXMEM_rd_data_sel: in     vl_logic;
        EXMEM_des_reg_num: in     vl_logic_vector(3 downto 0);
        EXMEM_mem_write_en: in     vl_logic_vector(3 downto 0);
        EXMEM_ld_byte_or_word: in     vl_logic;
        mem_data_out    : in     vl_logic_vector(31 downto 0);
        EXMEM_internal_halted: in     vl_logic;
        EXMEM_is_alu_for_mem_addr: in     vl_logic;
        mem_addr        : out    vl_logic_vector(29 downto 0);
        mem_write_en    : out    vl_logic_vector(3 downto 0);
        mem_data_in     : out    vl_logic_vector(31 downto 0);
        MEMID_rd_we     : out    vl_logic;
        MEMID_rd_num    : out    vl_logic_vector(3 downto 0);
        MEMID_forward_data: out    vl_logic_vector(31 downto 0);
        MEMWB_data_read_from_mem: out    vl_logic_vector(31 downto 0);
        MEMWB_rd_data   : out    vl_logic_vector(31 downto 0);
        MEMWB_rd_we     : out    vl_logic;
        MEMWB_rd_data_sel: out    vl_logic;
        MEMWB_internal_halted: out    vl_logic;
        MEMWB_des_reg_num: out    vl_logic_vector(3 downto 0)
    );
end arm_mem_stage;
