class alu_test extends uvm_test;
	`uvm_component_utils(alu_test)

	alu_env env_h;
	virtual alu_if vif;

	function new(string name="alu_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		env_h=alu_env::type_id::create("env_h",this);

		if(!uvm_config_db #(virtual alu_if)::get(this,"","alu_if",vif))
			`uvm_fatal(get_type_name(),"configuration failed")
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction
endclass

class test1 extends alu_test;
	`uvm_component_utils(test1)
	 seq seq_h;
	 seq_with_rst swr_h;
	 seq_without_ce  swc_h;
	 seq_with_arithmatic swa_h;
	 seq_with_logical swl_h;
	 seq_timeout_test stt_h;
	 seq_delayed_valid sdv_h;

	function new(string name="", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		phase.raise_objection(this);

		seq_h=seq::type_id::create("seq_h", this);
		swr_h=seq_with_rst::type_id::create("swr_h", this);
		swc_h=seq_without_ce::type_id::create("swc_h", this);
		swa_h=seq_with_arithmatic::type_id::create("swa_h", this);
		swl_h=seq_with_logical::type_id::create("swl_h", this);
		stt_h=seq_timeout_test::type_id::create("stt_h", this);
		sdv_h=seq_delayed_valid::type_id::create("sdv_h", this);

		 
			//seq_h.start(env_h.act_agt_h.sqr_h);

			//swr_h.start(env_h.act_agt_h.sqr_h);

			//swc_h.start(env_h.act_agt_h.sqr_h);

			//swa_h.start(env_h.act_agt_h.sqr_h);

			//swl_h.start(env_h.act_agt_h.sqr_h);

			//stt_h.start(env_h.act_agt_h.sqr_h);

			sdv_h.start(env_h.act_agt_h.sqr_h);

		

		phase.drop_objection(this);
	endtask
endclass

	 




