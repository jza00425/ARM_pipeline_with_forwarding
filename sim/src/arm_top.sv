`include "arm_defines.vh"
`include "internal_defines.vh"

module register #(parameter WIDTH = 32, parameter RESET_VALUE = 0) (
	input wire [(WIDTH - 1):0] d,
	input wire clk,
	input wire rst_b,
	input wire enable,
	output logic [(WIDTH - 1):0] q
);

always_ff @(posedge clk or negedge rst_b) begin
	if (~rst_b) begin
		q <= RESET_VALUE;
	end else if (enable) begin
		q <= d;
	end
end
endmodule

module arm_top (
	input wire clk,
	input wire reg_mem_clk,
	input wire rst_b,
	input wire [31:0] inst,
	input wire [31:0] mem_data_out,
	output wire [29:0] inst_addr,
	output wire [29:0] mem_addr,
	output wire [31:0] mem_data_in,
	output wire [3:0] mem_write_en,
	output wire halted
);

wire IDEX_internal_halted;
wire EXMEM_internal_halted;
wire MEMWB_internal_halted;
wire [31:0] cpsr_result_in_EX;
wire [31:0] pc_from_regfile;
wire [31:0] next_pc;
wire [31:0] IFID_inst;
wire [31:0] data0;
wire [31:0] data1;
wire [31:0] data2;
wire [31:0] cpsr_out;
wire IFID_Write;
wire EXID_rd_we;
wire MEMID_rd_we;
wire EXID_cpsr_we;
wire [3:0] EXID_rd_num;
wire [3:0] MEMID_rd_num;
wire [3:0] data0_reg_num;
wire [3:0] data1_reg_num;
wire [3:0] data2_reg_num;
wire real_PCWrite;
wire [31:0] IDEX_rs_or_rd_data;
wire [31:0] IDEX_rn_data;
wire [31:0] IDEX_rm_data;
wire IDEX_rd_we;
wire IDEX_cpsr_we;
wire IDEX_rd_data_sel;
wire IDEX_is_imm;
wire IDEX_alu_or_mac;
wire IDEX_up_down;
wire IDEX_mac_sel;
wire [3:0] IDEX_alu_sel;
wire [3:0] IDEX_cpsr_mask;
wire IDEX_is_alu_for_mem_addr;
wire IDEX_rd_sel;
wire [3:0] IDEX_mem_write_en;
wire IDEX_ld_byte_or_word;
wire [31:0] IDEX_cpsr;
wire [11:0] IDEX_inst_11_0;
wire [3:0] IDEX_inst_19_16;
wire [3:0] IDEX_inst_15_12;
wire [31:0] EXMEM_data_result;
wire [31:0] EXMEM_rd_data;
wire EXMEM_rd_we;
wire EXMEM_rd_data_sel;
wire [3:0] EXMEM_des_reg_num;
wire [3:0] EXMEM_mem_write_en;
wire EXMEM_ld_byte_or_word;
wire [31:0] MEMWB_data_read_from_mem;
wire [31:0] MEMWB_rd_data;
wire MEMWB_rd_we;
wire MEMWB_rd_data_sel;
wire [3:0] MEMWB_des_reg_num;
wire [31:0] WB_data;
wire WB_rd_we;
wire [3:0] WB_des_reg_num;
wire EXID_is_alu_for_mem_addr;
wire EXID_alu_or_mac;
wire [31:0] EXID_forward_data;
wire [31:0] MEMID_forward_data;
wire EXMEM_is_alu_for_mem_addr;

assign inst_addr = pc_from_regfile[31:2];

arm_if_stage if_stage(
	.pc(pc_from_regfile),
	.IFID_Write(IFID_Write),
	.inst(inst),
	.clk(clk),
	.next_pc(next_pc),
	.IFID_inst(IFID_inst)
);

arm_id_stage id_stage(
	.clk(clk),
	.rst_b(rst_b),
	.inst(IFID_inst),
	.data0(data0),
	.data1(data1),
	.data2(data2),
	.cpsr_out(cpsr_out),
	.EXID_cpsr(cpsr_result_in_EX),
	.EXID_rd_we(EXID_rd_we),
	.MEMID_rd_we(MEMID_rd_we),
	.EXID_cpsr_we(EXID_cpsr_we),
	.EXID_is_alu_for_mem_addr(EXID_is_alu_for_mem_addr),
	.EXID_alu_or_mac(EXID_alu_or_mac),
	.EXID_forward_data(EXID_forward_data),
	.MEMID_forward_data(MEMID_forward_data),
	.EXID_rd_num(EXID_rd_num),
	.MEMID_rd_num(MEMID_rd_num),
	.data0_reg_num(data0_reg_num),
	.data1_reg_num(data1_reg_num),
	.data2_reg_num(data2_reg_num),
	.real_PCWrite(real_PCWrite),
	.halted(IDEX_internal_halted),
	.IDEX_rs_or_rd_data(IDEX_rs_or_rd_data),
	.IDEX_rn_data(IDEX_rn_data),
	.IDEX_rm_data(IDEX_rm_data),
	.IDEX_rd_we(IDEX_rd_we),
	.IDEX_cpsr_we(IDEX_cpsr_we),
	.IDEX_rd_data_sel(IDEX_rd_data_sel),
	.IDEX_is_imm(IDEX_is_imm),
	.IDEX_alu_or_mac(IDEX_alu_or_mac),
	.IDEX_up_down(IDEX_up_down),
	.IDEX_mac_sel(IDEX_mac_sel),
	.IDEX_alu_sel(IDEX_alu_sel),
	.IDEX_cpsr_mask(IDEX_cpsr_mask),
	.IDEX_is_alu_for_mem_addr(IDEX_is_alu_for_mem_addr),
	.IDEX_rd_sel(IDEX_rd_sel),
	.IDEX_mem_write_en(IDEX_mem_write_en),
	.IDEX_ld_byte_or_word(IDEX_ld_byte_or_word),
	.IDEX_cpsr(IDEX_cpsr),
	.IDEX_inst_11_0(IDEX_inst_11_0),
	.IDEX_inst_19_16(IDEX_inst_19_16),
	.IDEX_inst_15_12(IDEX_inst_15_12),
	.real_IFID_Write(IFID_Write)
);

arm_ex_stage ex_stage(
	.clk(clk),
	.IDEX_rd_we(IDEX_rd_we),
	.IDEX_cpsr_we(IDEX_cpsr_we),
	.IDEX_rd_data_sel(IDEX_rd_data_sel),
	.IDEX_is_imm(IDEX_is_imm),
	.IDEX_alu_or_mac(IDEX_alu_or_mac),
	.IDEX_up_down(IDEX_up_down),
	.IDEX_mac_sel(IDEX_mac_sel),
	.IDEX_alu_sel(IDEX_alu_sel),
	.IDEX_cpsr_mask(IDEX_cpsr_mask),
	.IDEX_is_alu_for_mem_addr(IDEX_is_alu_for_mem_addr),
	.IDEX_rd_sel(IDEX_rd_sel),
	.IDEX_mem_write_en(IDEX_mem_write_en),
	.IDEX_ld_byte_or_word(IDEX_ld_byte_or_word),
	.IDEX_cpsr(IDEX_cpsr),
	.IDEX_inst_11_0(IDEX_inst_11_0),
	.IDEX_inst_19_16(IDEX_inst_19_16),
	.IDEX_inst_15_12(IDEX_inst_15_12),
	.IDEX_rs_or_rd_data(IDEX_rs_or_rd_data),
	.IDEX_rn_data(IDEX_rn_data),
	.IDEX_rm_data(IDEX_rm_data),
	.IDEX_internal_halted(IDEX_internal_halted),
	.cpsr_result_in_EX(cpsr_result_in_EX),
	.cpsr_we(EXID_cpsr_we),
	.EXID_rd_we(EXID_rd_we),
	.EXID_rd_num(EXID_rd_num),
	.EXID_is_alu_for_mem_addr(EXID_is_alu_for_mem_addr),
	.EXID_alu_or_mac(EXID_alu_or_mac),
	.EXID_forward_data(EXID_forward_data),
	.EXMEM_data_result(EXMEM_data_result),
	.EXMEM_rd_data(EXMEM_rd_data),
	.EXMEM_rd_we(EXMEM_rd_we),
	.EXMEM_rd_data_sel(EXMEM_rd_data_sel),
	.EXMEM_des_reg_num(EXMEM_des_reg_num),
	.EXMEM_mem_write_en(EXMEM_mem_write_en),
	.EXMEM_internal_halted(EXMEM_internal_halted),
	.EXMEM_is_alu_for_mem_addr(EXMEM_is_alu_for_mem_addr),
	.EXMEM_ld_byte_or_word(EXMEM_ld_byte_or_word)
);

arm_mem_stage mem_stage (
	.clk(clk),
	.EXMEM_data_result(EXMEM_data_result),
	.EXMEM_rd_data(EXMEM_rd_data),
	.EXMEM_rd_we(EXMEM_rd_we),
	.EXMEM_rd_data_sel(EXMEM_rd_data_sel),
	.EXMEM_des_reg_num(EXMEM_des_reg_num),
	.EXMEM_mem_write_en(EXMEM_mem_write_en),
	.EXMEM_ld_byte_or_word(EXMEM_ld_byte_or_word),
	.mem_data_out(mem_data_out),
	.EXMEM_internal_halted(EXMEM_internal_halted),
	.EXMEM_is_alu_for_mem_addr(EXMEM_is_alu_for_mem_addr),
	.mem_addr(mem_addr),
	.mem_data_in(mem_data_in),
	.mem_write_en(mem_write_en),
	.MEMID_rd_we(MEMID_rd_we),
	.MEMID_rd_num(MEMID_rd_num),
	.MEMID_forward_data(MEMID_forward_data),
	.MEMWB_data_read_from_mem(MEMWB_data_read_from_mem),
	.MEMWB_rd_data(MEMWB_rd_data),
	.MEMWB_rd_we(MEMWB_rd_we),
	.MEMWB_rd_data_sel(MEMWB_rd_data_sel),
	.MEMWB_internal_halted(MEMWB_internal_halted),
	.MEMWB_des_reg_num(MEMWB_des_reg_num)
);

arm_wb_stage wb_stage (
	.clk(clk),
	.MEMWB_data_read_from_mem(MEMWB_data_read_from_mem),
	.MEMWB_rd_data(MEMWB_rd_data),
	.MEMWB_rd_we(MEMWB_rd_we),
	.MEMWB_rd_data_sel(MEMWB_rd_data_sel),
	.MEMWB_des_reg_num(MEMWB_des_reg_num),
	.WB_data(WB_data),
	.WB_rd_we(WB_rd_we),
	.WB_des_reg_num(WB_des_reg_num)
);

regfile register_file(
	.rn_data(data0),
	.rm_data(data1),
	.rs_data(data2),
	.pc_out(pc_from_regfile),
	.cpsr_out(cpsr_out),
	.rn_num(data0_reg_num),
	.rm_num(data1_reg_num),
	.rs_num(data2_reg_num),
	.rd_num(WB_des_reg_num),
	.rd_data(WB_data),
	.rd_we(WB_rd_we),
	.pc_in(next_pc),
	.pc_we(real_PCWrite),
	.cpsr_in(cpsr_result_in_EX),
	.cpsr_we(EXID_cpsr_we),
	.clk(reg_mem_clk),
	.rst_b(rst_b),
	.halted(MEMWB_internal_halted)
);

register #(1, 0) Halt(
	.q(halted),
	.d(MEMWB_internal_halt),
	.clk(clk),
	.enable(1'b1),
	.rst_b(rst_b)
);

// register #(1, 0) Halt(halted, internal_halt, clk, 1'b1, rst_b);

endmodule
