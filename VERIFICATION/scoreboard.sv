`include "coverage.sv"

class scoreboard extends component_base;
	
	mailbox #(packet) exp_mbx[4]; 
	mailbox #(packet) act_mbx[4]; 

	packet q0[$];
	packet q1[$];
	packet q2[$];
	packet q3[$];

	packet last_pkt[4]; 
	
	switch_coverage cov; 

	int match_count = 0;
	int mismatch_count = 0;

	function new(string name, component_base parent=null);
		super.new(name, parent);
		cov = new(); 
	endfunction

	task run();
		fork
			monitor_expected(0); monitor_expected(1); monitor_expected(2); monitor_expected(3);
			monitor_actual(0);   monitor_actual(1);   monitor_actual(2);   monitor_actual(3);
		join_none
	endtask

	// PREDICTOR
	task monitor_expected(int port_id);
		packet pkt; 
		packet clone;
		int i; 
		
		forever begin
			exp_mbx[port_id].get(pkt);
			
			
			for (i=0; i<4; i++) begin
				if (pkt.target[i] == 1'b1) begin
					cov.sample(pkt, i); 
				end
			end
			// ------------------------------------

			for (i=0; i<4; i++) begin
				if (pkt.target[i] == 1'b1) begin
					clone = pkt.clone(); 
					case(i)
						0: q0.push_back(clone);
						1: q1.push_back(clone);
						2: q2.push_back(clone);
						3: q3.push_back(clone);
					endcase
				end
			end
		end
	endtask

	//CHECKER
	task monitor_actual(int port_id);
		packet act_pkt;
		int found_idx;
		int q_size; 

		forever begin
			act_mbx[port_id].get(act_pkt);

			
			if (last_pkt[port_id] != null) begin
				if (act_pkt.compare(last_pkt[port_id])) continue; 
			end

			q_size = 0;
			case(port_id)
				0: q_size = q0.size();
				1: q_size = q1.size();
				2: q_size = q2.size();
				3: q_size = q3.size();
			endcase

			if (q_size == 0) continue; 

			
			found_idx = -1;
			case(port_id)
				0: found_idx = find_packet(q0, act_pkt);
				1: found_idx = find_packet(q1, act_pkt);
				2: found_idx = find_packet(q2, act_pkt);
				3: found_idx = find_packet(q3, act_pkt);
			endcase

			if (found_idx != -1) begin
				// Match Found
				case(port_id)
					0: q0.delete(found_idx);
					1: q1.delete(found_idx);
					2: q2.delete(found_idx);
					3: q3.delete(found_idx);
				endcase
				match_count++;
				last_pkt[port_id] = act_pkt; 
				
				
				
				$display("[SCB] PASS: Match at Port %0d (Src:%0d Data:%h)", port_id, act_pkt.source, act_pkt.data);
			end else begin
				// Garbage Filter
				continue; 
			end
		end
	endtask

	
	function int find_packet(ref packet q[$], input packet p_in);
		int i;
		for (i=0; i<q.size(); i++) begin
			// ADD check for target
			if (q[i].source == p_in.source && 
				q[i].data == p_in.data && 
				q[i].target == p_in.target) return i; 
		end
		return -1;
	endfunction

	function void dump_queue(int p);
		$display("      --- Expected Queue for Port %0d (First 5 items) ---", p);
		if (p==0) print_q(q0);
		if (p==1) print_q(q1);
		if (p==2) print_q(q2);
		if (p==3) print_q(q3);
		$display("      ---------------------------------------------------");
	endfunction

	function void print_q(ref packet q[$]);
		int limit; 
		int i;     
		limit = (q.size() > 5) ? 5 : q.size();
		if (q.size() == 0) $display("      [EMPTY]");
		for(i=0; i<limit; i++) begin
			$display("      [%0d] Exp Src=%0d Exp Data=%h", i, q[i].source, q[i].data);
		end
	endfunction
	
	function void report();
		$display("\n========================================");
		$display("       SCOREBOARD REPORT                ");
		$display(" Matches:    %0d", match_count);
		$display(" Mismatches: %0d", mismatch_count);
		if (mismatch_count == 0 && match_count > 0) $display(" STATUS: PASSED");
		else $display(" STATUS: FAILED");
		$display("========================================\n");
	endfunction

endclass