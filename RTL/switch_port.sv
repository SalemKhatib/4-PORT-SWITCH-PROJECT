module switch_port #(
	parameter WIDTH = 8,        // Data Width
	parameter DEPTH = 16        // FIFO Depth
)(
	input  logic             clk,
	input  logic             rst_n,
	port_if                  p_if,
	output logic             req_o,
	output logic [3:0]       dest_o,
	input  logic             grant_i,
	output logic [WIDTH-1:0] data_to_mux
);

	// --- POINTER SIZES ---
	localparam PTR_BITS = $clog2(DEPTH);
	localparam CNT_BITS = $clog2(DEPTH + 1);

	// --- INTERNAL SIGNALS ---
	logic [WIDTH-1:0]    fifo_data [0:DEPTH-1];
	logic [3:0]          fifo_dest [0:DEPTH-1];
	logic [PTR_BITS-1:0] wr_ptr, rd_ptr;
	logic [CNT_BITS-1:0] count;
	logic full, writing, reading;

	// --- FSM STATE DEF ---
	typedef enum logic [1:0] {S_IDLE, S_REQUEST, S_TRANSMIT} state_t;
	state_t current_state, next_state;

	assign full = (count == DEPTH);
	assign writing = p_if.valid_in && (!full || (current_state == S_TRANSMIT));
	assign p_if.ready = (!full || reading); // Flow Control

	// --- 1. FSM NEXT STATE LOGIC ---
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) current_state <= S_IDLE;
		else        current_state <= next_state;
	end

	always_comb begin
		next_state = current_state;
		req_o      = 1'b0;
		reading    = 1'b0;

		case (current_state)
			S_IDLE: begin
				if (count > 0) next_state = S_REQUEST;
			end
			S_REQUEST: begin
				req_o = 1'b1;
				if (grant_i) next_state = S_TRANSMIT;
			end
			S_TRANSMIT: begin
				req_o   = 1'b1;
				reading = 1'b1;
				if (count > 1 && grant_i)   next_state = S_TRANSMIT; // Burst
				else if (count > 1)         next_state = S_REQUEST;  // Pause
				else                        next_state = S_IDLE;     // Done
			end
		endcase
	end

	// --- 2. FIFO LOGIC ---
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wr_ptr <= 0; rd_ptr <= 0; count <= 0;
		end else begin
			// Write
			if (writing) begin
				fifo_data[wr_ptr] <= p_if.data_in;
				fifo_dest[wr_ptr] <= p_if.target_in;
				wr_ptr            <= wr_ptr + 1;
			end
			// Read
			if (reading) rd_ptr <= rd_ptr + 1;
			
			// Count
			if (writing && !reading)      count <= count + 1;
			else if (reading && !writing) count <= count - 1;
		end
	end

	// --- 3. OUTPUTS ---
	assign dest_o      = fifo_dest[rd_ptr];
	assign data_to_mux = fifo_data[rd_ptr];

endmodule