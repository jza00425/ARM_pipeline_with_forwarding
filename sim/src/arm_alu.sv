
`include "arm_defines.vh"
`include "internal_defines.vh"


module arm_alu(
	input wire alu_or_mac,
	input wire [31:0] alu_op1,
	input wire [31:0] alu_op2,
	input wire [3:0] alu_sel,
	input wire alu_cin,
	input wire is_alu_for_mem_addr,
	input wire up_down,
	input wire potential_cout,
	output wire [31:0] alu_out,
	output wire [3:0] alu_cpsr
);

  logic [31:0] result;
  logic cout;
  logic n_flag, z_flag, c_flag, v_flag;

  assign carry_in = {31'd0, alu_cin};
  assign alu_out = result;
  assign alu_cpsr = {n_flag, z_flag, c_flag, v_flag};

  always_comb begin
	  if (alu_or_mac == 1'b0) begin
		  result = 'x;
		  n_flag = 1'bx; z_flag = 1'bx; c_flag = 1'bx; v_flag = 1'bx;
	  end else begin 
		  if (is_alu_for_mem_addr == 1) begin
			  result = (up_down) ? (unsigned'(alu_op1) + unsigned'(alu_op2)) : (unsigned'(alu_op1) - unsigned'(alu_op2));
			  n_flag = 1'bx; z_flag = 1'bx; c_flag = 1'bx; v_flag = 1'bx;
		  end else begin
			  case(alu_sel)
				  `OPD_AND: {cout, result} = alu_op1 & alu_op2;
				  `OPD_EOR: {cout, result} = alu_op1 ^ alu_op2;
				  `OPD_SUB: {cout, result} = alu_op1 - alu_op2;
				  // `OPD_SUB: signed'({cout, result}) = signed'(alu_op1) - signed'(alu_op2);
				  `OPD_RSB: {cout, result} = alu_op2 - alu_op1;
				  `OPD_ADD: {cout, result} = alu_op1 + alu_op2;
				  `OPD_ADC: {cout, result} = alu_op1 + alu_op2 + carry_in;
				  `OPD_SBC: {cout, result} = alu_op1 - alu_op2 + carry_in - 1;
				  `OPD_RSC: {cout, result} = alu_op2 - alu_op1 + carry_in - 1;
				  `OPD_TST: {cout, result} = alu_op1 & alu_op2;
				  `OPD_TEQ: {cout, result} = alu_op1 ^ alu_op2;
				  `OPD_CMP: {cout, result} = alu_op1 - alu_op2;
				  `OPD_CMN: {cout, result} = alu_op1 + alu_op2;
				  `OPD_ORR: {cout, result} = alu_op1 | alu_op2;
				  `OPD_MOV: {cout, result} = alu_op2;
				  `OPD_BIC: {cout, result} = alu_op1 & ~alu_op2;
				  `OPD_MVN: {cout, result} = ~alu_op2;
			  endcase

			  case(alu_sel)
				  `OPD_AND, `OPD_EOR, `OPD_TST, `OPD_TEQ, `OPD_ORR, `OPD_MOV, `OPD_BIC, `OPD_MVN: begin
					  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
					  z_flag = (result == 32'b0) ? 1'b1 : 1'b0;
					  c_flag = potential_cout;
					  v_flag = 1'bx;
				  end
				  `OPD_SUB, `OPD_SBC, `OPD_CMP: begin
					  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
					  z_flag = (result == 32'b0) ? 1'b1 : 1'b0;
					  c_flag = cout;
					  if (((alu_op1[31] == 1) && (alu_op2[31] == 0) && (result[31] == 0)) ||
					      ((alu_op1[31] == 0) && (alu_op2[31] == 1) && (result[31] == 1)))
						  v_flag = 1;
					  else  
						  v_flag = 0;
				  end
				  `OPD_RSB, `OPD_RSC: begin
					  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
					  z_flag = (result == 32'b0) ? 1'b1 : 1'b0;
					  c_flag = cout;
					  if (((alu_op1[31] == 1) && (alu_op2[31] == 0) && (result[31] == 1)) ||
					      ((alu_op1[31] == 0) && (alu_op2[31] == 1) && (result[31] == 0)))
						  v_flag = 1;
					  else  
						  v_flag = 0;
				  end
				  // `OPD_ADD, `OPD_ADC, `OPD_CMN: begin
				  default: begin
					  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
					  z_flag = (result == 32'b0) ? 1'b1 : 1'b0;
					  c_flag = cout;
					  if (((alu_op1[31] == 0) && (alu_op2[31] == 0) && (result[31] == 1)) ||
					      ((alu_op1[31] == 1) && (alu_op2[31] == 1) && (result[31] == 0)))
						  v_flag = 1;
					  else  
						  v_flag = 0;
				  end
			  endcase
		  end
	  end
  end
endmodule
