
`include "arm_defines.vh"
`include "internal_defines.vh"

module arm_mac(
	input wire [31:0] mac_op1,
	input wire [31:0] mac_op2,
	input wire [31:0] mac_acc,
	input wire mac_sel,
	input wire alu_or_mac,
	output logic [31:0] mac_out,
	output wire [3:0] mac_cpsr
);

  logic	      [31:0]  result;
  logic	      [31:0]  high32;
  logic		      n_flag, z_flag, v_flag, c_flag;

  assign mac_out = result;
  assign mac_cpsr = {n_flag, z_flag, v_flag, c_flag};
  always_comb begin
	  if (alu_or_mac == 1'b1) begin
		  result = 'x;
		  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
		  z_flag = (result == 0) ? 1 : 0;
		  c_flag = 1'bx;
		  v_flag = 1'bx;
	  end else begin
		  if (mac_sel == 1'b1) begin
			  {high32, result} = mac_op1 * mac_op2  + mac_acc;
		  end else begin
			  {high32, result} = mac_op1 * mac_op2;
		  end
		  n_flag = (result[31] == 1) ? 1'b1 : 1'b0;
		  z_flag = (result == 0) ? 1 : 0;
		  c_flag = 1'bx;
		  v_flag = 1'bx;
	  end
  end
endmodule
