class agent_1 extends uvm_agent;
	`uvm_component_utils(agent_1)
	driver drvh;
	monitor_1 monh;
	sequencer seqrh;
	uvm_analysis_port #(seq_item)ap;  
	function new(string name="agent",uvm_component parent);
		super.new(name,parent);
		ap=new("agent_1_analysis_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monh=monitor_1::type_id::create("monh",this);
		if(get_is_active()==UVM_ACTIVE)begin
		drvh=driver::type_id::create("drvh",this);
		seqrh=sequencer::type_id::create("seqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		monh.mon1_ap.connect(ap);
		if(get_is_active()==UVM_ACTIVE)
			drvh.seq_item_port.connect(seqrh.seq_item_export);
	endfunction
endclass

