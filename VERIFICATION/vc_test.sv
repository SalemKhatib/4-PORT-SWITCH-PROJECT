module vc_test;
import packet_pkg::*;

bit clk = 0; 
always #5 clk = ~clk;
bit rst_n;

port_if p0(clk, rst_n);
packet_vc vc0;
scoreboard scb;


assign p0.ready      = 1'b1;          
assign p0.valid_out  = p0.valid_in;   
assign p0.source_out = p0.source_in;  
assign p0.target_out = p0.target_in;  
assign p0.data_out   = p0.data_in;    
// ==========================================

initial begin
	rst_n = 0;
	repeat(5) @(posedge clk);
	rst_n = 1;

	$display("\n[VC_TEST] Starting Unit Test with LOOPBACK");

	vc0 = new("VC_Port0", null);
	scb = new("Scoreboard", null);

	vc0.configure(p0, 0);

	scb.exp_mbx[0] = vc0.scb_exp_mbx;
	scb.act_mbx[0] = vc0.scb_act_mbx;

	
	for(int i=1; i<4; i++) begin
		scb.exp_mbx[i] = new();
		scb.act_mbx[i] = new();
	end

	fork
		scb.run();      
		vc0.run(20);    
	join_any

	#1000;
	scb.report();
	$finish;
end
endmodule