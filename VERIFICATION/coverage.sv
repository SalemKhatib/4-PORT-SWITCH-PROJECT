`include "packet_data.sv" 

class switch_coverage;
	
	packet pkt;
	int current_dest; 
	int current_src;  
	
	covergroup cg_packet;
		
		//Source Port Coverage 
		
		cp_source: coverpoint current_src {
			bins src[] = {[0:3]}; 
		}

		//Destination Port Coverage
		cp_dest: coverpoint current_dest {
			bins dest[] = {[0:3]};
		}

		//Cross Coverage
		cross_src_dest: cross cp_source, cp_dest;

	endgroup

	function new();
		cg_packet = new();
	endfunction

	
	function int onehot_to_int(bit [3:0] oh);
		case(oh)
			4'b0001: return 0;
			4'b0010: return 1;
			4'b0100: return 2;
			4'b1000: return 3;
			default: return 0; // Fallback
		endcase
	endfunction

	
	function void sample(packet p, int dest_port);
		this.pkt = p;
		this.current_dest = dest_port; 
		
		
		this.current_src = onehot_to_int(p.source);
		
		cg_packet.sample();
	endfunction

endclass