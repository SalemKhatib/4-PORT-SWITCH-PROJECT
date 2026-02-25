class packet_vc extends component_base;
	agent agt;

	
	mailbox #(packet) scb_exp_mbx; 
	mailbox #(packet) scb_act_mbx; 

	function new(string name, component_base parent=null);
		super.new(name, parent);
		agt = new("agent", this);
	endfunction

	function void configure(virtual port_if vif, int port_id);
		//Connect Agent to Interface
		agt.connect(vif);
		
		//Configure Sequencer with Port ID (Critical for Source Encoding)
		agt.seq.port_id = port_id;
		
		//Expose Mailboxes for the Scoreboard
		
		this.scb_exp_mbx = agt.seq.seq2chk; 
		
		this.scb_act_mbx = agt.mon.mon2chk; 
	endfunction

	task run(int n);
		

		agt.run(n);
	endtask
endclass