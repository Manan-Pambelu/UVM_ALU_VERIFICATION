class input_sequencer extends uvm_sequencer#(trans);
		`uvm_component_utils(input_sequencer)

	 function new(string name="input_sequencer",uvm_component parent);
		 	super.new(name,parent);
		  endfunction

endclass

