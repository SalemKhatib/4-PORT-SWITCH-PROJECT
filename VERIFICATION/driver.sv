class driver extends component_base; 
	
	virtual port_if vif;          
	mailbox #(packet) seq2drv;    
	
	
	function new(string n, component_base p=null); 
		super.new(n,p); 

	endfunction 

	task run();
		packet p;
		
		vif.valid_in <= 0;
		vif.data_in   <= 0;
		vif.source_in <= 0;
		vif.target_in <= 0;

		forever begin
			
			seq2drv.get(p);
			$display("[%0t] Driver %s: Got packet to send", $time, name);

			
			@(posedge vif.clk);

			
			vif.valid_in  <= 1;
			vif.source_in <= p.source;
			vif.target_in <= p.target;
			vif.data_in   <= p.data;

			
			do begin
				@(posedge vif.clk);
			end while (vif.ready === 0);

			
			vif.valid_in <= 0;
			$display("[%0t] Driver %s: Packet sent successfully", $time, name);
		end
	endtask
	

endclass