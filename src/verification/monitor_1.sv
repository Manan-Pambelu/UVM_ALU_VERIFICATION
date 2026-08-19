class monitor_1 extends uvm_monitor;
	`uvm_component_utils(monitor_1)
	  virtual  alu_if.MON vif;
       		uvm_analysis_port #(seq_item)mon1_ap;
		int txn_count;
	function new(string name="monitor_1",uvm_component parent);
		super.new(name,parent);
		mon1_ap=new("monitor_1_ap",this);
		txn_count=0;
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	 if(!uvm_config_db #(virtual alu_if)::get(this,"","vif",vif))
		 `uvm_fatal(get_type_name(),"cannot get interface instance in monitor_1");
	endfunction

	task run_phase(uvm_phase phase);
		 seq_item req;
		  //@(vif.mon);
		forever begin
			@(vif.mon);

			req=seq_item::type_id::create("input_txn");
			txn_count++;
			req.txn_id=txn_count;
			req.opa=vif.mon.OPA;
			req.opb=vif.mon.OPB;
			req.ce=vif.mon.CE;
			req.mode=vif.mon.MODE;
			req.cmd=vif.mon.CMD;
			req.cin=vif.mon.CIN;
			req.inp_valid=vif.mon.INP_VALID;
			 //`uvm_info(get_type_name(),$sformatf("Input Transaction Captured\n%s",req.sprint()),UVM_MEDIUM)
		          `uvm_info(get_type_name() ,$sformatf("opa=%0h,opb=%0h,ce=%0b,mode=%0b,cmd=%0d,inp_valid=%0b cin=%0b\n",req.opa,req.opb,req.ce,req.mode,req.cmd,req.inp_valid,req.cin),UVM_LOW)
			mon1_ap.write(req);
		end
	endtask
endclass



