
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_control(
	input [31:0] inst,
	input [31:0] cpsr_out,
	output logic rd_we,
	output logic pc_we,
	output logic cpsr_we,
	// output logic rn_sel,	//1:dcd_rn; 0:dcd_mul_rn
	output logic rd_sel, 	//1:dcd_rd; 0:dcd_mul_rd
	output logic rd_data_sel,	//1:alu_result; 0:LD, mem_data
	output logic halted,
	output is_imm,
	output logic [3:0] mem_write_en,
	output logic ld_byte_or_word,	//1: byte; 0: word
	output logic alu_or_mac,	//1: alu; 0: mac
	output up_down,			//for LD/ST, calculate mem_addr by add or sub op2
	output mac_sel, 		//MUL/MULA
	// output is_for_store,
	output logic [2:0] mask_of_real_read_reg,
	output logic [3:0] read_reg_num [2:0],
	// output logic swi,
	output [3:0] alu_sel,
	output logic [3:0] cpsr_mask,
	output is_alu_for_mem_addr
);

logic exc_en;

// assign is_for_store = (inst[27:26] == 2'b01) && (inst[20] == 0);
/*
 * Data Processing Instruction, when inst[25] == 1, operand2 is immediate.
 * But Single Data Transfer Instruction, when inst[25] == 0, operand2 is
 * immediate
 */
assign is_imm = ((~inst[26] & inst[25]) | (inst[26] & ~inst[25])) ? 1'b1 : 1'b0;
assign is_alu_for_mem_addr = (inst[27:26] == 2'b01) ? 1'b1 : 1'b0;
assign up_down = (inst[23]) ? 1'b1 : 1'b0;
assign mac_sel = (inst[21]) ? 1'b1 : 1'b0;
assign alu_sel = inst[24:21];

always_comb begin
	if (inst[20] == 1'b1) begin
		case (inst[27:24])
			`OPD_AND, `OPD_EOR, `OPD_TST, `OPD_TEQ, `OPD_ORR, `OPD_MOV, `OPD_BIC, `OPD_MVN: cpsr_mask = 4'b1110;
			default: cpsr_mask = 4'b1111;
		endcase
	end else begin
		cpsr_mask = 4'b0000;
	end
end

always_comb begin
	case (inst[31:28])
		 `COND_EQ: exc_en = cpsr_out[30] ? 1'b1 : 1'b0;
		 `COND_NE: exc_en = cpsr_out[30] ? 1'b0 : 1'b1;
	         `COND_GE: exc_en = (cpsr_out[31] == cpsr_out[28]) ? 1'b1 : 1'b0;
		 `COND_LT: exc_en = (cpsr_out[31] != cpsr_out[28]) ? 1'b1 : 1'b0;
		 `COND_GT: exc_en = (~cpsr_out[30] && (cpsr_out[31] == cpsr_out[28])) ? 1'b1 : 1'b0;
		 `COND_LE: exc_en = (cpsr_out[30] || (cpsr_out[31] != cpsr_out[28])) ? 1'b1 : 1'b0;
		 default: exc_en = 1;
	 endcase
end

always_comb begin
	if (!exc_en) begin
		// swi = 1'b0;
		rd_we = 1'b0;
		pc_we = 1'b1;
		cpsr_we = 1'b0;
		// rn_sel = 1'bx;
		rd_sel = 1'bx;
		rd_data_sel = 1'bx;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'bx;
		mask_of_real_read_reg = 3'b000;
		read_reg_num = '{3'bxxx, 3'bxxx, 3'bxxx};
	end else if (inst[27:24] == 4'hf) begin		//SWI
		// swi = 1'b1;
		rd_we = 1'b0;
		pc_we = 1'b0;
		cpsr_we = 1'b0;
		// rn_sel = 1'bx;
		rd_sel = 1'bx;
		rd_data_sel = 1'bx;
		halted = 1'b1;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'bx;
		mask_of_real_read_reg = 3'b000;
		read_reg_num = '{3'bxxx, 3'bxxx, 3'bxxx};
	end else if (inst[27:26] == 2'b01) begin	//Single Data Transfer
		// swi = 1'b0;
		pc_we = 1'b1;
		cpsr_we = 1'b0;
		// rn_sel = 1'b1;
		rd_sel = 1'b1;
		halted = 1'b0;
		alu_or_mac = 1'b1;
		mask_of_real_read_reg[0] = 1'b1;
		mask_of_real_read_reg[1] = (inst[25] == 1'b1) ? 1'b1 : 1'b0;
		read_reg_num[0] = inst[19:16];
		read_reg_num[1] = inst[3:0];
		ld_byte_or_word = (inst[22]) ? 1'b1 : 1'b0;
		if (inst[20] == 1'b1) begin 	//LOAD
			rd_we = 1'b1;
			rd_data_sel = 1'b0;
			mask_of_real_read_reg[2] = 1'b0;
			mem_write_en = 4'h0;
			read_reg_num[2] = 3'bxxx;
		end else begin			//STORE
			rd_we = 1'b0;
			rd_data_sel = 1'bx;
			mask_of_real_read_reg[2] = 1'b1;
			mem_write_en = 4'hf;
			read_reg_num[2] = inst[15:12];
		end
	end else if ((inst[27:25] == 3'b000) && (inst[7:4] == 4'b1001)) begin //MUL
		// swi = 1'b0;
		rd_we = 1'b1;
		pc_we = 1'b1;
		cpsr_we = (inst[20] == 1'b1) ? 1'b1 : 1'b0;
		// rn_sel = 1'b0;
		rd_sel = 1'b0;
		rd_data_sel = 1'b1;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'b0;
		mask_of_real_read_reg[0] = (inst[21] == 1'b1) ? 1'b1 : 1'b0; 
		mask_of_real_read_reg[1] = 1'b1;
		mask_of_real_read_reg[2] = 1'b1;
		read_reg_num[0] = inst[15:12];
		read_reg_num[1] = inst[3:0];
		read_reg_num[2] = inst[11:8];
	end else begin	//DATA PROCESSING
		// swi = 1'b0;
		rd_we = ((inst[27:24] == `OPD_TST) || (inst[27:24] == `OPD_TEQ) || (inst[27:24] == `OPD_CMP) || (inst[27:24] == `OPD_CMN)) ? 1'b0 : 1'b1;
		pc_we = 1'b1;
		cpsr_we = (inst[20] == 1'b1) ? 1'b1 : 1'b0;
		// rn_sel = 1'b1;
		rd_sel = 1'b1;
		rd_data_sel = 1'b1;
		halted = 1'b0;
		mem_write_en = 0;
		ld_byte_or_word = 1'bx;
		alu_or_mac = 1'b1;
		mask_of_real_read_reg[0] = (inst[24:21] != 4'b1101) ? 1'b1 : 1'b0; 
		mask_of_real_read_reg[1] = (inst[25] == 1'b0) ? 1'b1 : 1'b0;
		mask_of_real_read_reg[2] = ((inst[25] == 1'b0) && (inst[4] == 1'b1)) ? 1'b1 : 1'b0;
		read_reg_num[0] = inst[19:16];
		read_reg_num[1] = inst[3:0];
		read_reg_num[2] = inst[11:8];
	end
end
endmodule
