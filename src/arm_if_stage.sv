
module arm_if_stage (
	input wire [31:0] pc,
	input wire IFID_Write,
	input wire [31:0] inst,
	input wire clk,
	output wire [31:0] next_pc,
	output logic [31:0] IFID_inst
);

assign next_pc = pc + 32'h4;

always_ff @ (posedge clk iff IFID_Write == 1) begin
	IFID_inst <= inst;
end

endmodule
