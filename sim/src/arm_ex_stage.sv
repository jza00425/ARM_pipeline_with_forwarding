
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_ex_stage (
	input wire clk,
	input wire IDEX_rd_we,
	input wire IDEX_cpsr_we,
	input wire IDEX_rd_data_sel,
	input wire IDEX_is_imm,
	input wire IDEX_alu_or_mac,
	input wire IDEX_up_down,
	input wire IDEX_mac_sel,
	input wire [3:0] IDEX_alu_sel,
	input wire [3:0] IDEX_cpsr_mask,
	input wire IDEX_is_alu_for_mem_addr,
	input wire IDEX_rd_sel,
	input wire [3:0] IDEX_mem_write_en,
	input wire IDEX_ld_byte_or_word,
	input wire [31:0] IDEX_cpsr,
	input wire [11:0] IDEX_inst_11_0,
	input wire [3:0] IDEX_inst_19_16,
	input wire [3:0] IDEX_inst_15_12,
	input wire [31:0] IDEX_rs_or_rd_data,
	input wire [31:0] IDEX_rn_data,
	input wire [31:0] IDEX_rm_data,
	input wire IDEX_internal_halted,
	output wire [31:0] cpsr_result_in_EX,
	output wire cpsr_we,
	output wire EXID_rd_we,
	output wire [3:0] EXID_rd_num,
	output wire EXID_is_alu_for_mem_addr,
	output wire EXID_alu_or_mac,
	output wire [31:0] EXID_forward_data,
	output logic [31:0] EXMEM_data_result,
	output logic [31:0] EXMEM_rd_data,
	output logic EXMEM_rd_we,
	output logic EXMEM_rd_data_sel,
	output logic [3:0] EXMEM_des_reg_num,
	output logic [3:0] EXMEM_mem_write_en,
	output logic EXMEM_internal_halted,
	output logic EXMEM_is_alu_for_mem_addr,
	output logic EXMEM_ld_byte_or_word
);

wire [31:0] operand2;
wire potential_cout;
wire [31:0] alu_out;
wire [3:0] alu_cpsr;
wire [31:0] mac_out;
wire [3:0] mac_cpsr;
wire [3:0] final_cpsr_mask;
wire [3:0] tmp_cpsr;

assign final_cpsr_mask = (IDEX_alu_or_mac) ? IDEX_cpsr_mask : 4'b1100;
assign tmp_cpsr = (IDEX_alu_or_mac) ? alu_cpsr : mac_cpsr; 
assign cpsr_result_in_EX = ({~final_cpsr_mask, 28'hfffffff} & IDEX_cpsr) | {(final_cpsr_mask & tmp_cpsr), 28'h0000000};
assign cpsr_we = IDEX_cpsr_we;
assign EXID_rd_we = IDEX_rd_we;
assign EXID_rd_num = (IDEX_rd_sel == 1'b1) ? IDEX_inst_15_12 : IDEX_inst_19_16;
assign EXID_is_alu_for_mem_addr = IDEX_is_alu_for_mem_addr;
assign EXID_alu_or_mac = IDEX_alu_or_mac;
assign EXID_forward_data = alu_out;

arm_barrel_shift barrel_shift (
	.inst_11_0(IDEX_inst_11_0),
	.rm_data_in(IDEX_rm_data),
	.rs_data_in(IDEX_rs_or_rd_data),
	.cpsr(IDEX_cpsr),
	.is_imm(IDEX_is_imm),
	.operand2(operand2),
	.potential_cout(potential_cout)
);


arm_alu alu (
	.alu_or_mac(IDEX_alu_or_mac),
	.alu_op1(IDEX_rn_data),
	.alu_op2(operand2),
	.alu_sel(IDEX_alu_sel),
	.alu_cin(IDEX_cpsr[29]),
	.is_alu_for_mem_addr(IDEX_is_alu_for_mem_addr),
	.up_down(IDEX_up_down),
	.potential_cout(potential_cout),
	.alu_out(alu_out),
	.alu_cpsr(alu_cpsr)
);

arm_mac mac (
	.mac_op1(IDEX_rm_data),
	.mac_op2(IDEX_rs_or_rd_data),
	.mac_acc(IDEX_rn_data),
	.mac_sel(IDEX_mac_sel),
	.alu_or_mac(IDEX_alu_or_mac),
	.mac_out(mac_out),
	.mac_cpsr(mac_cpsr)
);

always_ff @ (posedge clk) begin
	EXMEM_internal_halted <= IDEX_internal_halted;
	EXMEM_data_result <= (IDEX_alu_or_mac) ? alu_out : mac_out;
	EXMEM_rd_data <= IDEX_rs_or_rd_data;
	EXMEM_rd_we <= IDEX_rd_we;
	EXMEM_rd_data_sel <= IDEX_rd_data_sel;
	EXMEM_des_reg_num <= (IDEX_rd_sel == 1'b1) ? IDEX_inst_15_12 : IDEX_inst_19_16;
	EXMEM_mem_write_en <= IDEX_mem_write_en;
	EXMEM_ld_byte_or_word <= IDEX_ld_byte_or_word;
	EXMEM_is_alu_for_mem_addr <= IDEX_is_alu_for_mem_addr;
end
endmodule
