`include "defines.sv"
`uvm_analysis_imp_decl(_from_drv)
`uvm_analysis_imp_decl(_from_mon)

class alu_scoreboard extends uvm_scoreboard();

`uvm_component_utils(alu_scoreboard)

	logic [`POW_2_N-1:0] SHIFT_BY;
	reg [3:0] count;

	uvm_analysis_imp_from_drv #(trans, alu_scoreboard) inp_analysis_export;
	uvm_analysis_imp_from_mon #(trans, alu_scoreboard) out_analysis_export;

	trans driver_packet[$];
	trans monitor_packet[$];
	trans ref_output, prev_output, condition_packet;

	function new(string name = "alu_scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		inp_analysis_export=new("inp_analysis_export",this);
		out_analysis_export=new("out_analysis_export",this);
		ref_output=new();
		prev_output=new();
		condition_packet=new();
	endfunction
	

	virtual function void write_from_mon(trans t);
		`uvm_info(get_type_name, "Scoreboard received packet from monitor", UVM_NONE);
		monitor_packet.push_back(t);
	endfunction

	virtual function void write_from_drv(trans u);
		`uvm_info(get_type_name, "Scoreboard received packet from the driver", UVM_NONE);
		condition_packet = u;
		driver_packet.push_back(u);
	endfunction

	virtual task run_phase(uvm_phase phase);
		trans packet2;
		trans packet1;

		super.run_phase(phase);

		forever begin

			wait(driver_packet.size() > 0);
			packet2 = driver_packet.pop_front();

			if(!((((condition_packet.mode == 1) &&
				(condition_packet.cmd < 4 || (condition_packet.cmd > 7 && condition_packet.cmd < 11))) ||
				((condition_packet.mode == 0) &&
				(condition_packet.cmd < 6 || condition_packet.cmd == 12 || condition_packet.cmd == 13))) &&
				(condition_packet.inp_valid == 1 || condition_packet.inp_valid == 2)))
			begin
				wait(monitor_packet.size() > 0);
				packet1 = monitor_packet.pop_front();
			end

			// Reference model
			begin
				ref_output.rst = packet2.rst;
				ref_output.ce = packet2.ce;
				ref_output.mode = packet2.mode;
				ref_output.cmd = packet2.cmd;
				ref_output.inp_valid = packet2.inp_valid;
				ref_output.ce = packet2.ce;
				ref_output.OA = packet2.OA;
				ref_output.OB = packet2.OB;
				ref_output.cin = packet2.cin;

				if(packet2.rst) begin
					ref_output.res = 'b0;
					ref_output.oflow = 1'b0;
					ref_output.cout = 1'b0;
					ref_output.g = 1'b0;
					ref_output.l = 1'b0;
					ref_output.e = 1'b0;
					ref_output.err = 1'b0;
				end
				else begin
					if(packet2.ce) begin

						if(packet2.mode) begin		// Arithmetic operations

							ref_output.res = 'bz;
							ref_output.oflow = 1'bz;
							ref_output.cout = 1'bz;
							ref_output.g = 1'bz;
							ref_output.l = 1'bz;
							ref_output.e = 1'bz;
							ref_output.err = 1'bz;

							if((packet2.cmd < 4) ||
							   (packet2.cmd > 7 && packet2.cmd < 11))
							begin	
							//operations requiring 2 operands

								if(packet2.inp_valid == 2'b00) begin
									ref_output.err = 1'b1;
									count = 0;
								end
								else if(packet2.inp_valid == 2'b11) begin

									case(packet2.cmd)

										4'd0: begin		// ADD
											ref_output.res = packet2.OA + packet2.OB;
											ref_output.cout = (ref_output.res[`WIDTH]) ? 1 : 1'b0;
										end

										4'd1: begin		// SUB
											ref_output.res = packet2.OA - packet2.OB;
											ref_output.oflow = (packet2.OA < packet2.OB) ? 1 : 0;
										end

										4'd2: begin		// ADD_CIN
											ref_output.res = packet2.OA + packet2.OB + packet2.cin;
											ref_output.cout = (ref_output.res[`WIDTH]) ? 1 : 1'b0;
										end

										4'd3: begin		// SUB_CIN
											ref_output.res = (packet2.OA - packet2.OB) - packet2.cin;
											ref_output.oflow =
												(packet2.OA < packet2.OB ||
												(packet2.OA == packet2.OB && packet2.cin)) ? 1 : 0;
										end

										4'd8: begin		// CMP
											if(packet2.OA == packet2.OB)
												{ref_output.g, ref_output.l, ref_output.e} = 3'bzz1;
											else if(packet2.OA > packet2.OB)
												{ref_output.g, ref_output.l, ref_output.e} = 3'b1zz;
											else
												{ref_output.g, ref_output.l, ref_output.e} = 3'bz1z;
										end

										4'd9:
											ref_output.res = (packet2.OA + 1) * (packet2.OB + 1);

										4'd10:
											ref_output.res = (packet2.OA << 1) * packet2.OB;

									endcase

									count = 0;

								end
								else begin		// inp_valid is 01 or 10

									if(count == 15) begin
										ref_output.err = 1;
										count = 0;
									end
									else
										count++;

								end

							end

							if((packet2.cmd == 4) || (packet2.cmd == 5)) begin

								if((packet2.inp_valid == 2'b00) ||
								   (packet2.inp_valid == 2'b10))
									ref_output.err = 1;
								else begin

									if(packet2.cmd == 4)
										ref_output.res = packet2.OA + 1;
									else
										ref_output.res = packet2.OA - 1;

								end

							end

							if((packet2.cmd == 6) || (packet2.cmd == 7)) begin

								if((packet2.inp_valid == 2'b00) ||
								   (packet2.inp_valid == 2'b01))
									ref_output.err = 1;
								else begin

									if(packet2.cmd == 6)
										ref_output.res = packet2.OB + 1;
									else
										ref_output.res = packet2.OB - 1;

								end

							end

						end		// Arithmetic operation ends
						else begin		// Logical operations

							ref_output.res = 'bz;
							ref_output.oflow = 1'bz;
							ref_output.cout = 1'bz;
							ref_output.g = 1'bz;
							ref_output.l = 1'bz;
							ref_output.e = 1'bz;
							ref_output.err = 1'bz;

							if((packet2.cmd < 6) ||
							   (packet2.cmd > 11 && packet2.cmd < 14))
							begin		// All 2 operand operations

								if(packet2.inp_valid == 2'b00) begin
									ref_output.err = 1'b1;
									count = 0;
								end
								else if(packet2.inp_valid == 2'b11) begin

									case(packet2.cmd)

										4'd0:
											ref_output.res = {1'b0, packet2.OA & packet2.OB};

										4'd1:
											ref_output.res = {1'b0, ~(packet2.OA & packet2.OB)};

										4'd2:
											ref_output.res = {1'b0, packet2.OA | packet2.OB};

										4'd3:
											ref_output.res = {1'b0, ~(packet2.OA | packet2.OB)};

										4'd4:
											ref_output.res = {1'b0, packet2.OA ^ packet2.OB};

										4'd5:
											ref_output.res = {1'b0, ~(packet2.OA ^ packet2.OB)};

										4'd12: begin
											SHIFT_BY = packet2.OB[2:0];
											ref_output.res =
												16'h00FF &
												({1'b0, (packet2.OA << SHIFT_BY |
												packet2.OA >> (`WIDTH - SHIFT_BY))});
											ref_output.err =(packet2.OPB[7:4]!=4'b0)?1:0;
										end

										4'd13: begin
											SHIFT_BY = packet2.OB[2:0];
											ref_output.res =
												16'h00FF &
												({1'b0, packet2.OA << (`WIDTH - SHIFT_BY) |
												packet2.OA >> SHIFT_BY});
											ref_output.err =(packet2.OPB[7:4]!=4'b0)?1:0;
										end

									endcase

									count = 0;

								end
								else begin

									if(count == 15) begin
										ref_output.err = 1;
										count = 0;
									end
									else
										count++;

								end

							end

							if((packet2.cmd == 6) ||
							   (packet2.cmd == 8) ||
							   (packet2.cmd == 9))
							begin

								if((packet2.inp_valid == 2'b00) ||
								   (packet2.inp_valid == 2'b10))
									ref_output.err = 1;
								else begin

									if(packet2.cmd == 6)
										ref_output.res = {1'b0, ~(packet2.OA)};
									else if(packet2.cmd == 8)
										ref_output.res = {1'b0, packet2.OA >> 1};
									else
										ref_output.res = {1'b0, packet2.OA << 1};

								end

							end

							if((packet2.cmd == 7) ||
							   (packet2.cmd == 10) ||
							   (packet2.cmd == 11))
							begin

								if((packet2.inp_valid == 2'b00) ||
								   (packet2.inp_valid == 2'b01))
									ref_output.err = 1;
								else begin

									if(packet2.cmd == 7)
										ref_output.res = {1'b0, ~(packet2.OB)};
									else if(packet2.cmd == 10)
										ref_output.res = {1'b0, packet2.OB >> 1};
									else
										ref_output.res = {1'b0, packet2.OB << 1};

								end

							end

						end		
						prev_output = ref_output;
					end			// ce = 1 ends
					else
					begin
						ref_output.res = prev_output.res;
						ref_output.oflow = prev_output.oflow;
						ref_output.cout = prev_output.cout;
						ref_output.g = prev_output.g;
						ref_output.l = prev_output.l;
						ref_output.e = prev_output.e;
						ref_output.err = prev_output.err;
					end
				end
			end

			if((((packet2.mode == 1) && (packet2.cmd < 4 || (packet2.cmd > 7 && packet2.cmd < 11)))||((packet2.mode == 0) && (packet2.cmd < 6 || packet2.cmd == 12 || packet2.cmd == 13))) && (packet2.inp_valid == 1 || packet2.inp_valid == 2))
			begin
					`uvm_info(get_type_name(), $sformatf("\n------------------------------------------------------------------------------"), UVM_NONE);
					$display("	         SCOREBOARD WAITING FOR BOTH APERAND TO BE VALID											");
					$display("------------------------------------------------------------------------------");
			end
			else
			begin		// Compare 
				$display("Field\t\t|\tReference Output\t|\tActual Response");
				$display("--------------|-------------------------------|----------------------------");
				$display("rst\t\t|\t\t%b\t\t|\t\t%b", ref_output.rst, packet2.rst);
				$display("ce\t\t|\t\t%b\t\t|\t\t%b", ref_output.ce, packet2.ce);
				$display("mode\t\t|\t\t%b\t\t|\t\t%b", ref_output.mode, packet2.mode);
				$display("cmd\t\t|\t\t%0d\t\t|\t\t%0d", ref_output.cmd, packet2.cmd);
				$display("inp_valid\t|\t\t%b\t\t|\t\t%b", ref_output.inp_valid, packet2.inp_valid);
				$display("opa\t\t|\t\t%0d\t\t|\t\t%0d", ref_output.opa, packet2.opa);
				$display("opb\t\t|\t\t%0d\t\t|\t\t%0d	", ref_output.opb, packet2.opb);
				$display("cin\t\t|\t\t%b\t\t|\t\t%b", ref_output.cin, packet2.cin);
				$display("res\t\t|\t\t%0d\t\t|\t\t%0d", ref_output.res, packet1.res);
				$display("err\t\t|\t\t%b\t\t|\t\t%b", ref_output.err, packet1.err);
				$display("oflow\t\t|\t\t%b\t\t|\t\t%b", ref_output.oflow, packet1.oflow);
				$display("cout\t\t|\t\t%b\t\t|\t\t%b", ref_output.cout, packet1.cout);
				$display("g\t\t|\t\t%b\t\t|\t\t%b", ref_output.g, packet1.g);
				$display("l\t\t|\t\t%b\t\t|\t\t%b", ref_output.l, packet1.l);
				$display("e\t\t|\t\t%b\t\t|\t\t%b", ref_output.e, packet1.e);
				if((packet1.res === ref_model_output.res) && (packet1.err === ref_model_output.err) && (packet1.oflow === ref_model_output.oflow) && (packet1.cout === ref_model_output.cout) && (packet1.g === ref_model_output.g) && (packet1.l === ref_model_output.l) && (packet1.e === ref_model_output.e))
				begin
					`uvm_info(get_type_name(), $sformatf("\n----------------------------------------------------------------------------"), UVM_NONE);
					$display("	           		TEST PASS																	");
					$display("----------------------------------------------------------------------------");
				end
				else
				begin
					`uvm_info(get_type_name(), $sformatf("\n----------------------------------------------------------------------------"), UVM_NONE);
					$display("	           		TEST FAILED																	");
					$display("----------------------------------------------------------------------------");
				end
			end
		end
	endtask
endclass
