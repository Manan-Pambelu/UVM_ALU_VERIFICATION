class alu_env extends uvm_env;
	`uvm_component_utils(alu_env)
 
 alu_act_agent act_agt_h;
 alu_pas_agent pas_agt_h;
 alu_scoreboard scb_h;


 function new(string name="env",uvm_component parent);
	super.new(name,parent);
   endfunction

 function void build_phase(uvm_phase phase);
	super.build_phase(phase);

  act_agt_h=alu_act_agent::type_id::create("act_agt_h",this);
  pas_agt_h=alu_pas_agent::type_id::create("pas_agt_h",this);
  scb_h=alu_scoreboard::type_id::create("scb_h",this);

 endfunction

 function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	act_agt_h.act_mon_h.act_mon_aport.connect(scb_h.inp_fifo.analysis_export);
	pas_agt_h.pas_mon_h.pas_mon_aport.connect(scb_h.out_fifo.analysis_export);
 endfunction

endclass
  

	
  


