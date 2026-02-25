class agent extends component_base;
	sequencer seq;
	driver    drv;
	monitor   mon;

	function new(string name, component_base parent=null);
		super.new(name, parent);
		seq = new("seq", this);
		drv = new("drv", this);
		mon = new("mon", this);
	endfunction

	function void connect(virtual port_if vif);
		drv.vif = vif;
		mon.vif = vif;
		drv.seq2drv = seq.seq2drv; // Connect sequencer to driver
	endfunction

	task run(int n);
		fork
			seq.run(n);
			drv.run();
			mon.run();
		join_any
	endtask
endclass