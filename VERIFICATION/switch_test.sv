import packet_pkg::*; 

module switch_test;

	//Clock & Reset Generation
	bit clk;
	bit rst_n;

	always #5 clk = ~clk; 

	//Interface Instantiation (One per Port)
	
	port_if p0(clk, rst_n);
	port_if p1(clk, rst_n);
	port_if p2(clk, rst_n);
	port_if p3(clk, rst_n);

	//DUT Instantiation (The Switch)
	
	switch_4port DUT (
		.clk(clk),
		.rst_n(rst_n),
		.p0(p0), .p1(p1), .p2(p2), .p3(p3), 
		.valid_o(), .data_o(), .dest_o()    
	);

	//Verification Components
	packet_vc vc0, vc1, vc2, vc3;
	scoreboard scb;

	initial begin
		//Initialize 
		clk = 0;
		rst_n = 0;
		
		$display("------------------------------------------------");
		$display("       STARTING STAGE B VERIFICATION            ");
		$display("------------------------------------------------");

		//Construct Components
		
		vc0 = new("VC_Port0", null);
		vc1 = new("VC_Port1", null);
		vc2 = new("VC_Port2", null);
		vc3 = new("VC_Port3", null);
		scb = new("Scoreboard", null);

		//Configure VCs
		
		vc0.configure(p0, 0); 
		vc1.configure(p1, 1);
		vc2.configure(p2, 2);
		vc3.configure(p3, 3);

		//Connect Scoreboard to VCs
		
		scb.exp_mbx[0] = vc0.scb_exp_mbx; scb.act_mbx[0] = vc0.scb_act_mbx;
		scb.exp_mbx[1] = vc1.scb_exp_mbx; scb.act_mbx[1] = vc1.scb_act_mbx;
		scb.exp_mbx[2] = vc2.scb_exp_mbx; scb.act_mbx[2] = vc2.scb_act_mbx;
		scb.exp_mbx[3] = vc3.scb_exp_mbx; scb.act_mbx[3] = vc3.scb_act_mbx;

		//Run the Test
		#20 rst_n = 1; 
		
		
		fork
			scb.run();      
			vc0.run(2000);
			vc1.run(2000);
			vc2.run(2000);
			vc3.run(2000);
		join_any

		//Drain & Report
		#1000000; 
		scb.report();
		$finish;
	end
endmodule