class output_agent extends uvm_agent;
	`uvm_component_utils(output_agent)

    output_monitor mon_h;
    alu_config m_cfg;

   function new(string name="output_agent",uvm_component parent);
	super.new(name,parent);
   endfunction

  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    
  if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
	`uvm_fatal(get_type_name(),"Output_agt Getting Failed")
    if(m_cfg.output_agent_is_active==UVM_PASSIVE)
    begin
    mon_h=output_monitor::type_id::create("mon_h",this); 
    end

  endfunction


 endclass

