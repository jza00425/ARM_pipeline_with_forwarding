
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_forwarding (
	input wire [3:0] data0_reg_num,
	input wire [3:0] data1_reg_num,
	input wire [3:0] data2_reg_num,
	input wire [2:0] mask_of_real_read_reg,
	input wire EXID_rd_we,
	input wire MEMID_rd_we,
	input wire [3:0] EXID_rd_num,
	input wire [3:0] MEMID_rd_num,
	input wire EXID_alu_or_mac,
	input wire EXID_is_alu_for_mem_addr,
	output logic [1:0] forward[0:2]
);

logic is_EXID_rd_num_matter;

always_comb begin
	if (((EXID_alu_or_mac == 1'b0) ||
	     ((EXID_alu_or_mac == 1'b1) && (EXID_is_alu_for_mem_addr == 1'b0))) && (EXID_rd_we == 1'b1)) begin 
	     is_EXID_rd_num_matter = 1'b1;
    	end else begin
		is_EXID_rd_num_matter = 1'b0;
	end
end

always_comb begin
	if ((is_EXID_rd_num_matter == 1'b1) && 
	    (EXID_rd_num == data0_reg_num) &&
	    (mask_of_real_read_reg[0] == 1'b1)) begin
	    forward[0] = 2'b01;
    end else if ((MEMID_rd_we == 1'b1) && 
	         (MEMID_rd_num == data0_reg_num) &&
	 	 (mask_of_real_read_reg[0] == 1'b1)) begin
		 forward[0] = 2'b10;
	 end else begin
		 forward[0] = 2'b00;
	 end
 end

always_comb begin
	if ((is_EXID_rd_num_matter == 1'b1) && 
	    (EXID_rd_num == data1_reg_num) &&
	    (mask_of_real_read_reg[1] == 1'b1)) begin
	    forward[1] = 2'b01;
    end else if ((MEMID_rd_we == 1'b1) && 
	         (MEMID_rd_num == data1_reg_num) &&
	 	 (mask_of_real_read_reg[1] == 1'b1)) begin
		 forward[1] = 2'b10;
	 end else begin
		 forward[1] = 2'b00;
	 end
 end

always_comb begin
	if ((is_EXID_rd_num_matter == 1'b1) && 
	    (EXID_rd_num == data2_reg_num) &&
	    (mask_of_real_read_reg[2] == 1'b1)) begin
	    forward[2] = 2'b01;
    end else if ((MEMID_rd_we == 1'b1) && 
	         (MEMID_rd_num == data2_reg_num) &&
	 	 (mask_of_real_read_reg[2] == 1'b1)) begin
		 forward[2] = 2'b10;
	 end else begin
		 forward[2] = 2'b00;
	 end
 end


 endmodule
