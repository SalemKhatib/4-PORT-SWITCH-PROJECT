class sequencer extends component_base;
	mailbox #(packet) seq2chk; 
	mailbox #(packet) seq2drv; 
	
	int port_id; 

	function new(string name, component_base parent=null);
		super.new(name, parent);
		seq2chk = new();
		seq2drv = new();
	endfunction

	task run(int n);
		packet pkt, pkt_copy;
		
		$display("[SEQ] %s: Starting generation of %0d packets for Port %0d...", name, n, port_id);

		repeat(n) begin
			//Construct the packet
			
			
			pkt = new("pkt", port_id);

			
			
			if (!pkt.randomize()) begin
				$error("[SEQ] %s: Randomization Failed! Check constraints.", name);
				$finish;
			end

			//Clone for Verification
			
			pkt_copy = pkt.clone(); 

			$display("[SEQ] %s: Sending Packet ID %0d (Type: %s, Target: %b)", 
					 name, pkt.id, pkt.p_type.name(), pkt.target);
			
			//Send to components
			seq2chk.put(pkt_copy); 
			seq2drv.put(pkt);      
		end
		
		$display("[SEQ] %s: Finished generation.", name);
	endtask
endclass