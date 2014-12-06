library verilog;
use verilog.vl_types.all;
entity arm_id_stage is
    port(
        clk             : in     vl_logic;
        rst_b           : in     vl_logic;
        inst            : in     vl_logic_vector(31 downto 0);
        data0           : in     vl_logic_vector(31 downto 0);
        data1           : in     vl_logic_vector(31 downto 0);
        data2           : in     vl_logic_vector(31 downto 0);
        cpsr_out        : in     vl_logic_vector(31 downto 0);
        EXID_cpsr       : in     vl_logic_vector(31 downto 0);
        EXID_rd_we      : in     vl_logic;
        MEMID_rd_we     : in     vl_logic;
        EXID_cpsr_we    : in     vl_logic;
        EXID_is_alu_for_mem_addr: in     vl_logic;
        EXID_alu_or_mac : in     vl_logic;
        EXID_forward_data: in     vl_logic_vector(31 downto 0);
        MEMID_forward_data: in     vl_logic_vector(31 downto 0);
        EXID_rd_num     : in     vl_logic_vector(3 downto 0);
        MEMID_rd_num    : in     vl_logic_vector(3 downto 0);
        data0_reg_num   : out    vl_logic_vector(3 downto 0);
        data1_reg_num   : out    vl_logic_vector(3 downto 0);
        data2_reg_num   : out    vl_logic_vector(3 downto 0);
        real_PCWrite    : out    vl_logic;
        halted          : out    vl_logic;
        IDEX_rs_or_rd_data: out    vl_logic_vector(31 downto 0);
        IDEX_rn_data    : out    vl_logic_vector(31 downto 0);
        IDEX_rm_data    : out    vl_logic_vector(31 downto 0);
        IDEX_rd_we      : out    vl_logic;
        IDEX_cpsr_we    : out    vl_logic;
        IDEX_rd_data_sel: out    vl_logic;
        IDEX_is_imm     : out    vl_logic;
        IDEX_alu_or_mac : out    vl_logic;
        IDEX_up_down    : out    vl_logic;
        IDEX_mac_sel    : out    vl_logic;
        IDEX_alu_sel    : out    vl_logic_vector(3 downto 0);
        IDEX_cpsr_mask  : out    vl_logic_vector(3 downto 0);
        IDEX_is_alu_for_mem_addr: out    vl_logic;
        IDEX_rd_sel     : out    vl_logic;
        IDEX_mem_write_en: out    vl_logic_vector(3 downto 0);
        IDEX_ld_byte_or_word: out    vl_logic;
        IDEX_cpsr       : out    vl_logic_vector(31 downto 0);
        IDEX_inst_11_0  : out    vl_logic_vector(11 downto 0);
        IDEX_inst_19_16 : out    vl_logic_vector(3 downto 0);
        IDEX_inst_15_12 : out    vl_logic_vector(3 downto 0);
        real_IFID_Write : out    vl_logic
    );
end arm_id_stage;