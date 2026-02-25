class monitor extends component_base;
	mailbox #(packet) mon2chk;
	virtual port_if vif; 

	function new(string name, component_base parent=null);
		super.new(name, parent);
		mon2chk = new();
	endfunction

	task run();
		packet pkt;
		

		forever begin
			@(posedge vif.clk);
			// Capture EVERY cycle that valid is high
			if (vif.valid_out === 1'b1) begin
				
				pkt = new();
				pkt.source = vif.source_out;
				pkt.target = vif.target_out;
				pkt.data   = vif.data_out;
				
				$display("[MON] %s: Captured Packet Source:%0d Data:%h", 
						 name, pkt.source, pkt.data);
				mon2chk.put(pkt);
				
				
			end 
			
		end
	endtask
endclass