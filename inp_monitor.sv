class input_monitor extends uvm_monitor;
	`uvm_component_utils(input_monitor)
	
	uvm_analysis_port#(trans) inp_monitor_port;

	virtual alu_if.INP_MON vif;
	alu_config m_cfg;
	trans drv2mon;
	//analysis_port

 function new(string name="input_monitor",uvm_component parent);
	super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
	super.build_phase(phase);
   if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
	`uvm_fatal(get_type_name(),"Input_Monitor Getting Failed")
	inp_monitor_port=new("inp_monitor_port",this);
	//new
 endfunction

 function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
 	vif=m_cfg.vif;
 endfunction

 task run_phase(uvm_phase phase);
	drv2mon=trans::type_id::create("drv2mon");
	forever begin
	    collect_input_monitor();
		`uvm_info("INPUT_MONITOR",$sformatf("Input MONITOR\n%s",drv2mon.sprint()),UVM_NONE)
	end
		    
 endtask

 virtual task collect_input_monitor();
	begin
		repeat(7)
        	@(vif.inp_mon_cb);

	    drv2mon.ce        =   vif.inp_mon_cb.ce; 
	    drv2mon.inp_valid =   vif.inp_mon_cb.inp_valid;
	    drv2mon.OA        =   vif.inp_mon_cb.OA;
	    drv2mon.OB        =   vif.inp_mon_cb.OB;
            drv2mon.mode      =   vif.inp_mon_cb.mode;
	    drv2mon.cmd       =   vif.inp_mon_cb.cmd;
       	    

	   if((drv2mon.mode==1) && ((drv2mon.cmd==4'b0010) || (drv2mon.cmd==4'b0011)))
	    begin
		drv2mon.cin       =   vif.inp_mon_cb.cin;
	     end
		inp_monitor_port.write(drv2mon);
	    end
 endtask

endclass


