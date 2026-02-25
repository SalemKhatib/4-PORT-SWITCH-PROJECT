module arbiter (
	input  logic       clk,
	input  logic       rst_n,
	input  logic [3:0] req,
	output logic [3:0] grant
);

	// Internal State
	logic [1:0] priority_ptr;
	logic [1:0] next_priority;
	logic [3:0] next_grant;

	// --- 1. Combinational Logic ---
	// Use 'automatic' so variables i and idx are local to this block
	always_comb begin
		// Local variables (Best Practice: Declare temporary vars here)
		integer i;
		logic [1:0] idx;
		logic found_req;

		// Default values
		next_grant    = 4'b0000;
		next_priority = priority_ptr;
		found_req     = 1'b0;

		// Loop through all 4 ports starting from priority_ptr
		for (i = 0; i < 4; i++) begin
			// 2-bit arithmetic automatically wraps around (Modulo 4)
			idx = priority_ptr + i[1:0];

			if (!found_req && req[idx]) begin
				next_grant[idx] = 1'b1;
				next_priority   = idx + 1'b1; // Move pointer to next agent
				found_req       = 1'b1;       // Stop searching
			end
		end
	end

	// --- 2. Sequential Logic ---
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			priority_ptr <= 2'd0;
			grant        <= 4'b0000;
		end else begin
			priority_ptr <= next_priority;
			grant        <= next_grant;
		end
	end

endmodule