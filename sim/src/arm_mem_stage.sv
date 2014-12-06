
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_mem_stage (
	input wire clk,
	input wire [31:0] EXMEM_data_result,
	input wire [31:0] EXMEM_rd_data,
	input wire EXMEM_rd_we,
	input wire EXMEM_rd_data_sel,
	input wire [3:0] EXMEM_des_reg_num,
	input wire [3:0] EXMEM_mem_write_en,
	input wire EXMEM_ld_byte_or_word,
	input wire [31:0] mem_data_out,
	input wire EXMEM_internal_halted,
	input wire EXMEM_is_alu_for_mem_addr,
	output wire [29:0] mem_addr,
	output logic [3:0] mem_write_en,
	output wire [31:0] mem_data_in,
	output wire MEMID_rd_we,
	output wire [3:0] MEMID_rd_num,
	output wire [31:0] MEMID_forward_data,
	output logic [31:0] MEMWB_data_read_from_mem,
	output logic [31:0] MEMWB_rd_data,
	output logic MEMWB_rd_we,
	output logic MEMWB_rd_data_sel,
	output logic MEMWB_internal_halted,
	output logic [3:0] MEMWB_des_reg_num
);

wire [4:0] word_offset;
wire [63:0] for_modified_mem_data_out;
wire [31:0] modified_mem_data_out;
wire [31:0] modified_mem_data_in;
wire [31:0] data_read_from_mem;

assign word_offset = {3'b0, EXMEM_data_result[1:0]} << 3; 
assign for_modified_mem_data_out = {2{mem_data_out}};
assign modified_mem_data_out = for_modified_mem_data_out[word_offset + 31 -: 32];
assign modified_mem_data_in = {4{EXMEM_rd_data[7:0]}};

assign mem_addr = EXMEM_data_result[31:2];
assign mem_data_in = (EXMEM_ld_byte_or_word) ? modified_mem_data_in : EXMEM_rd_data;
assign MEMID_rd_we = EXMEM_rd_we;
assign MEMID_rd_num = EXMEM_des_reg_num;
assign data_read_from_mem = (EXMEM_ld_byte_or_word) ? {24'h000000, modified_mem_data_out[7:0]} : modified_mem_data_out;
assign MEMID_forward_data = (EXMEM_is_alu_for_mem_addr == 1'b1) ? data_read_from_mem : EXMEM_data_result;

always_comb begin
	if ((EXMEM_ld_byte_or_word == 1'b0) && (EXMEM_mem_write_en == 4'hf)) begin
		mem_write_en = 4'hf;
	end else if ((EXMEM_ld_byte_or_word == 1'b1) && (EXMEM_mem_write_en == 4'hf)) begin
		// mem_write_en[0] = (EXMEM_data_result[1:0] == 2'b00) ? 1'b1 : 1'b0;
		// mem_write_en[1] = (EXMEM_data_result[1:0] == 2'b01) ? 1'b1 : 1'b0;
		// mem_write_en[2] = (EXMEM_data_result[1:0] == 2'b10) ? 1'b1 : 1'b0;
		// mem_write_en[3] = (EXMEM_data_result[1:0] == 2'b11) ? 1'b1 : 1'b0;
		// reason: in arm_mem.v input we2 is we2[0:3], the opposite of
		// mem_write_en[3:0]
		mem_write_en[3] = (EXMEM_data_result[1:0] == 2'b00) ? 1'b1 : 1'b0;
		mem_write_en[2] = (EXMEM_data_result[1:0] == 2'b01) ? 1'b1 : 1'b0;
		mem_write_en[1] = (EXMEM_data_result[1:0] == 2'b10) ? 1'b1 : 1'b0;
		mem_write_en[0] = (EXMEM_data_result[1:0] == 2'b11) ? 1'b1 : 1'b0;
	end else begin
		mem_write_en = 4'h0;
	end
end

always_ff @ (posedge clk) begin
	MEMWB_internal_halted <= EXMEM_internal_halted;
	MEMWB_data_read_from_mem <= data_read_from_mem;
	MEMWB_rd_data <= EXMEM_data_result;
	MEMWB_rd_we <= EXMEM_rd_we;
	MEMWB_rd_data_sel <= EXMEM_rd_data_sel;
	MEMWB_des_reg_num <= EXMEM_des_reg_num;
end
endmodule
