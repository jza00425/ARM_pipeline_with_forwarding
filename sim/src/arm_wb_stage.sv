
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_wb_stage (
	input wire clk,
	input wire [31:0] MEMWB_data_read_from_mem,
	input wire [31:0] MEMWB_rd_data,
	input wire MEMWB_rd_we,
	input wire MEMWB_rd_data_sel,
	input wire [3:0] MEMWB_des_reg_num,
	output wire [31:0] WB_data,
	output wire WB_rd_we,
	output wire [3:0] WB_des_reg_num
);

assign WB_data = (MEMWB_rd_data_sel) ? MEMWB_rd_data : MEMWB_data_read_from_mem;
assign WB_rd_we = MEMWB_rd_we;
assign WB_des_reg_num = MEMWB_des_reg_num;

endmodule



