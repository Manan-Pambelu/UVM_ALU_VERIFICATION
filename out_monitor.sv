class output_monitor extends uvm_monitor;
	`uvm_component_utils(output_monitor)
	uvm_analysis_port#(trans) out_monitor_port;

	virtual alu_if.OUT_MON vif;
	alu_config m_cfg;
	trans rd_data;

 function new(string name="output_monitor",uvm_component parent);
	super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
	super.build_phase(phase);
   if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
	`uvm_fatal(get_type_name(),"Output_Monitor Getting Failed")
	//new
	out_monitor_port=new("out_monitor_port",this);
 endfunction

 function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
 	vif=m_cfg.vif;
 endfunction

 task run_phase(uvm_phase phase);
	rd_data=trans::type_id::create("rd_data");
	forever 
		begin	 
	    	collect_data();
	   	`uvm_info("OUTPUT_MONITOR",$sformatf("OUTPUT MONITOR\n%s",rd_data.sprint()),UVM_NONE)
		end

 endtask

	  
virtual task collect_data();
     begin
	repeat(6)
	@(vif.out_mon_cb);
          begin
	  rd_data.res=vif.out_mon_cb.res;
	  rd_data.err=vif.out_mon_cb.err;
	  rd_data.cout=vif.out_mon_cb.cout;
	  rd_data.oflow=vif.out_mon_cb.oflow;
	  rd_data.G = vif.out_mon_cb.G;
	  rd_data.L = vif.out_mon_cb.L;
	  rd_data.E = vif.out_mon_cb.E;

	  rd_data.ce        =   vif.out_mon_cb.ce; 
	  rd_data.inp_valid =   vif.out_mon_cb.inp_valid;
	  rd_data.OA        =   vif.out_mon_cb.OA;
	  rd_data.OB        =   vif.out_mon_cb.OB;
          rd_data.mode      =   vif.out_mon_cb.mode;
	  rd_data.cmd       =   vif.out_mon_cb.cmd;
          
	if((rd_data.mode==1) && ((rd_data.cmd=4'b1001) || (rd_data.cmd=4'b1010)))
	  begin
	    	@(vif.out_mon_cb);
		rd_data.res=vif.out_mon_cb.res;
	  end

   	end
	out_monitor_port.write(rd_data);
    end

 endtask


 endclass


