
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_id_stage (
	input clk,
	input rst_b,
	input wire [31:0] inst,
	input wire [31:0] data0,
	input wire [31:0] data1,
	input wire [31:0] data2,
	input wire [31:0] cpsr_out,
	input wire [31:0] EXID_cpsr,
	input wire EXID_rd_we,
	input wire MEMID_rd_we,
	input wire EXID_cpsr_we,
	input wire EXID_is_alu_for_mem_addr,
	input wire EXID_alu_or_mac,
	input wire [31:0] EXID_forward_data,
	input wire [31:0] MEMID_forward_data,
	input wire [3:0] EXID_rd_num,
	input wire [3:0] MEMID_rd_num,
	output wire [3:0] data0_reg_num,
	output wire [3:0] data1_reg_num,
	output wire [3:0] data2_reg_num,
	output wire real_PCWrite,
	output logic halted,
	output logic [31:0] IDEX_rs_or_rd_data,
	output logic [31:0] IDEX_rn_data,
	output logic [31:0] IDEX_rm_data,
	output logic IDEX_rd_we,
	output logic IDEX_cpsr_we,
	output logic IDEX_rd_data_sel,
	output logic IDEX_is_imm,
	output logic IDEX_alu_or_mac,
	output logic IDEX_up_down,
	output logic IDEX_mac_sel,
	output logic [3:0] IDEX_alu_sel,
	output logic [3:0] IDEX_cpsr_mask,
	output logic IDEX_is_alu_for_mem_addr,
	output logic IDEX_rd_sel,
	output logic [3:0] IDEX_mem_write_en,
	output logic IDEX_ld_byte_or_word,
	output logic [31:0] IDEX_cpsr,
	output logic [11:0] IDEX_inst_11_0,
	output logic [3:0] IDEX_inst_19_16,
	output logic [3:0] IDEX_inst_15_12,
	output wire real_IFID_Write
);

wire rd_we;
wire pc_we;
wire PCWrite;
wire cpsr_we;
wire rd_sel;
wire rd_data_sel;
wire is_imm;
wire [3:0] mem_write_en;
wire ld_byte_or_word;
wire alu_or_mac;
wire up_down;
wire mac_sel;
wire [2:0] mask_of_real_read_reg;
wire [3:0] read_reg_num [2:0];
wire [3:0] alu_sel;
wire [3:0] cpsr_mask;
wire is_alu_for_mem_addr;
wire stall;
wire ctrl_halted;
wire IFID_Write;
wire [1:0] forward_sel [0:2];

assign real_PCWrite = pc_we & PCWrite;
assign real_IFID_Write = IFID_Write & ~ctrl_halted;
assign data0_reg_num = read_reg_num[0];
assign data1_reg_num = read_reg_num[1];
assign data2_reg_num = read_reg_num[2];

hazard_detect detector (
	.rst_b(rst_b),
	.mask_of_real_read_reg(mask_of_real_read_reg),
	.read_reg_num(read_reg_num),
	.IDEX_rd_we(EXID_rd_we),
	.IDEX_is_alu_for_mem_addr(EXID_is_alu_for_mem_addr),
	// .EXMEM_rd_we(MEMID_rd_we),
	.IDEX_rd_num(EXID_rd_num),
	// .EXMEM_rd_num(MEMID_rd_num),
	.stall(stall),
	.IFID_Write(IFID_Write),
	.PCWrite(PCWrite)
);

arm_forwarding forwarding (
	.data0_reg_num(read_reg_num[0]),
	.data1_reg_num(read_reg_num[1]),
	.data2_reg_num(read_reg_num[2]),
	.mask_of_real_read_reg(mask_of_real_read_reg),
	.EXID_rd_we(EXID_rd_we),
	.MEMID_rd_we(MEMID_rd_we),
	.EXID_rd_num(EXID_rd_num),
	.MEMID_rd_num(MEMID_rd_num),
	.EXID_alu_or_mac(EXID_alu_or_mac),
	.EXID_is_alu_for_mem_addr(EXID_is_alu_for_mem_addr),
	.forward(forward_sel)
);

arm_control ctrl (
	.inst(inst),
	.cpsr_out(cpsr_out),
	.rd_we(rd_we),
	.pc_we(pc_we),
	.cpsr_we(cpsr_we),
	.rd_sel(rd_sel), 	//1:dcd_rd; 0:dcd_mul_rd
	.rd_data_sel(rd_data_sel),	//1:alu_result; 0:LD, mem_data
	.halted(ctrl_halted),
	.is_imm(is_imm),
	.mem_write_en(mem_write_en),
	.ld_byte_or_word(ld_byte_or_word),	//1: byte; 0: word
	.alu_or_mac(alu_or_mac),	//1: alu; 0: mac
	.up_down(up_down),			//for LD/ST, calculate mem_addr by add or sub op2
	.mac_sel(mac_sel), 		//MUL/MULA
	.mask_of_real_read_reg(mask_of_real_read_reg),
	.read_reg_num(read_reg_num),
	.alu_sel(alu_sel),
	.cpsr_mask(cpsr_mask),
	.is_alu_for_mem_addr(is_alu_for_mem_addr)
);

always_ff @ (posedge clk) begin
	if (~rst_b) begin
		IDEX_rd_we <= 1'b0;
		IDEX_cpsr_we <= 1'b0;
		IDEX_rd_sel <= 1'bx;
		IDEX_rd_data_sel <= 1'bx;
		IDEX_is_imm <= 1'bx;
		IDEX_mem_write_en <= 4'h0;
		IDEX_ld_byte_or_word <= 1'bx;
		IDEX_alu_or_mac <= 1'bx;
		IDEX_up_down <= 1'bx;
		IDEX_mac_sel <= 1'bx;
		IDEX_alu_sel <= 4'hx;
		IDEX_cpsr_mask <= 4'hx;
		IDEX_is_alu_for_mem_addr <= 1'bx;
		IDEX_cpsr <= 'x;
		IDEX_inst_11_0 <= inst[11:0];
		IDEX_inst_19_16 <= inst[19:16];
		IDEX_inst_15_12 <= inst[15:11];
		IDEX_rs_or_rd_data <= 'x;
		IDEX_rn_data <= 'x;
		IDEX_rm_data <= 'x;
		halted <= ctrl_halted;
	end else if ((stall == 1'b1) || (ctrl_halted == 1'b1)) begin
		IDEX_rd_we <= 1'b0;
		IDEX_cpsr_we <= 1'b0;
		IDEX_rd_sel <= 1'bx;
		IDEX_rd_data_sel <= 1'bx;
		IDEX_is_imm <= 1'bx;
		IDEX_mem_write_en <= 4'h0;
		IDEX_ld_byte_or_word <= 1'bx;
		IDEX_alu_or_mac <= 1'bx;
		IDEX_up_down <= 1'bx;
		IDEX_mac_sel <= 1'bx;
		IDEX_alu_sel <= 4'hx;
		IDEX_cpsr_mask <= 4'hx;
		IDEX_is_alu_for_mem_addr <= 1'bx;
		IDEX_cpsr <= 'x;
		IDEX_inst_11_0 <= inst[11:0];
		IDEX_inst_19_16 <= inst[19:16];
		IDEX_inst_15_12 <= inst[15:11];
		IDEX_rs_or_rd_data <= 'x;
		IDEX_rn_data <= 'x;
		IDEX_rm_data <= 'x;
		halted <= ctrl_halted;
	end else begin
		IDEX_rd_we <= rd_we;
		IDEX_cpsr_we <= cpsr_we;
		IDEX_rd_sel <= rd_sel;
		IDEX_rd_data_sel <= rd_data_sel;
		IDEX_is_imm <= is_imm;
		IDEX_mem_write_en <= mem_write_en;
		IDEX_ld_byte_or_word <= ld_byte_or_word;
		IDEX_alu_or_mac <= alu_or_mac;
		IDEX_up_down <= up_down;
		IDEX_mac_sel <= mac_sel;
		IDEX_alu_sel <= alu_sel;
		IDEX_cpsr_mask <= cpsr_mask;
		IDEX_is_alu_for_mem_addr <= is_alu_for_mem_addr;
		IDEX_cpsr = (EXID_cpsr_we == 1'b0) ? cpsr_out : EXID_cpsr;
		IDEX_inst_11_0 <= inst[11:0];
		IDEX_inst_19_16 <= inst[19:16];
		IDEX_inst_15_12 <= inst[15:12];
		// IDEX_rs_or_rd_data <= data2;
		IDEX_rs_or_rd_data <= (forward_sel[2] == 2'b01) ? EXID_forward_data: ((forward_sel[2] == 2'b10) ? MEMID_forward_data : data2);
		IDEX_rn_data <= (forward_sel[0] == 2'b01) ? EXID_forward_data: ((forward_sel[0] == 2'b10) ? MEMID_forward_data : data0);
		IDEX_rm_data <= (forward_sel[1] == 2'b01) ? EXID_forward_data: ((forward_sel[1] == 2'b10) ? MEMID_forward_data : data1);
		// IDEX_rm_data <= data1;
		halted <= ctrl_halted;
	end
end
endmodule
