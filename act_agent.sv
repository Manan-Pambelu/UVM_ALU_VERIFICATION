class alu_act_agent extends uvm_agent;

	`uvm_component_utils(alu_act_agent)

	alu_sequencer sqr_h;
	alu_driver drv_h;
	alu_act_monitor act_mon_h;

	function new(string name="alu_act_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		sqr_h=alu_sequencer::type_id::create("sqr_h",this);
		drv_h=alu_driver::type_id::create("drv_h",this);
		act_mon_h=alu_act_monitor::type_id::create("act_mon_h",this);

	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv_h.seq_item_port.connect(sqr_h.seq_item_export);
	endfunction

endclass
