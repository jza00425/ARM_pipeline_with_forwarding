library verilog;
use verilog.vl_types.all;
entity arm_control is
    port(
        inst            : in     vl_logic_vector(31 downto 0);
        cpsr_out        : in     vl_logic_vector(31 downto 0);
        rd_we           : out    vl_logic;
        pc_we           : out    vl_logic;
        cpsr_we         : out    vl_logic;
        rd_sel          : out    vl_logic;
        rd_data_sel     : out    vl_logic;
        halted          : out    vl_logic;
        is_imm          : out    vl_logic;
        mem_write_en    : out    vl_logic_vector(3 downto 0);
        ld_byte_or_word : out    vl_logic;
        alu_or_mac      : out    vl_logic;
        up_down         : out    vl_logic;
        mac_sel         : out    vl_logic;
        mask_of_real_read_reg: out    vl_logic_vector(2 downto 0);
        read_reg_num    : out    vl_logic;
        alu_sel         : out    vl_logic_vector(3 downto 0);
        cpsr_mask       : out    vl_logic_vector(3 downto 0);
        is_alu_for_mem_addr: out    vl_logic
    );
end arm_control;
