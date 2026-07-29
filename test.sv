
class test extends uvm_test;
	`uvm_component_utils(test)

 env env_h;
 alu_config m_cfg;

 function new(string name="test",uvm_component parent);
	super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
	super.build_phase(phase);

  m_cfg=alu_config::type_id::create("m_cfg");
  //virtual_get
  if(!uvm_config_db#(virtual alu_if)::get(this,"","alu_if",m_cfg.vif))
	`uvm_fatal(get_type_name,"Can't get the interface")
  m_cfg.input_agent_is_active=UVM_ACTIVE;
  m_cfg.output_agent_is_active=UVM_PASSIVE;

  uvm_config_db#(alu_config)::set(this,"*","alu_config",m_cfg);

  env_h=env::type_id::create("env_h",this);

 endfunction

 function void end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
   uvm_top.print_topology();
endfunction



endclass


class test1 extends test;
	`uvm_component_utils(test1)

	seq s1;
	seq_1 s2;
	cycle_seq s3;
	err_seq e1;

 function new(string name="test1",uvm_component parent);
	super.new(name,parent);
 endfunction


 function void build_phase(uvm_phase phase);
	super.build_phase(phase);
 endfunction


 task run_phase(uvm_phase phase);

	phase.raise_objection(this);
	s1=seq::type_id::create("s1");
	s2=seq_1::type_id::create("s2");
	s3=cycle_seq::type_id::create("s3");
	e1=err_seq::type_id::create("e1");




	//s1.start(env_h.inp_agt_h.seqr_h);

	fork
//	begin
	s1.start(env_h.inp_agt_h.seqr_h);
//	#25;
	s2.start(env_h.inp_agt_h.seqr_h);
//	end
	s3.start(env_h.inp_agt_h.seqr_h);
	e1.start(env_h.inp_agt_h.seqr_h);
	join
	#50;
	phase.drop_objection(this);


 endtask

endclass
 


