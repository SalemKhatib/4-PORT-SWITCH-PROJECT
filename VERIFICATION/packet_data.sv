class packet;
	//  1. Data Fields 
	rand bit [3:0] source;
	rand bit [3:0] target;
	rand bit [7:0] data;

	string name;

	// 2. Constructor
	function new(string name="packet");
		this.name = name;
	endfunction

	// 3. Constraints  
	constraint valid_dest {
		target != 4'b0000;      
	}
	constraint no_loopback {
		source != target;       
	}

	// 4. Helper 
	function void display();
		$display("Packet: Src=%b Tgt=%b Data=%h", source, target, data);
	endfunction
endclass