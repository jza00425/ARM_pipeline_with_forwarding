
`include "arm_defines.vh"
`include "internal_defines.vh"

module hazard_detect (
	input wire rst_b,
	input wire [2:0] mask_of_real_read_reg,
	input wire [3:0] read_reg_num [2:0],
	input wire IDEX_rd_we,
	input wire EXMEM_rd_we,
	input wire [3:0] IDEX_rd_num,
	input wire [3:0] EXMEM_rd_num,
	output logic stall,
	output logic IFID_Write,
	output logic PCWrite
);

always_comb begin
	if (((IDEX_rd_we == 1'b1) &&
	    (((IDEX_rd_num == read_reg_num[0]) && (mask_of_real_read_reg[0] == 1'b1)) ||
	     ((IDEX_rd_num == read_reg_num[1]) && (mask_of_real_read_reg[1] == 1'b1)) ||
	     ((IDEX_rd_num == read_reg_num[2]) && (mask_of_real_read_reg[2] == 1'b1)))
	    ) || ~rst_b) begin
			    stall = 1'b1;
			    IFID_Write = 1'b0;
			    PCWrite = 1'b0;
	end else if ((EXMEM_rd_we == 1'b1) &&
	    	     (((EXMEM_rd_num == read_reg_num[0]) && (mask_of_real_read_reg[0] == 1'b1)) ||
		      ((EXMEM_rd_num == read_reg_num[1]) && (mask_of_real_read_reg[1] == 1'b1)) ||
		      ((EXMEM_rd_num == read_reg_num[2]) && (mask_of_real_read_reg[2] == 1'b1)))
	     	    ) begin
			    stall = 1'b1;
			    IFID_Write = 1'b0;
			    PCWrite = 1'b0;
	end else begin
		stall = 1'b0;
		IFID_Write = 1'b1;
		PCWrite = 1'b1;
	end
end
endmodule
		
