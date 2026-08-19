class driver extends uvm_driver#(seq_item);
	`uvm_component_utils(driver)
	virtual  alu_if.DRV vif;

	function new(string name="driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual alu_if)::get(this,"","vif",vif))
			`uvm_fatal(get_type_name(),"no interface is found in driver")
	endfunction

	task run_phase(uvm_phase phase);
	        wait(vif.rst==0);
		forever begin
			seq_item_port.get_next_item(req);
      			 //`uvm_info(get_type_name(),$sformatf("Driving Transaction\n%s", req.sprint()), UVM_MEDIUM)
			drive(req);
			 `uvm_info(get_type_name(),$sformatf("opa=%0h,opb=%0h,ce=%0b,mode=%0b,cmd=%0d,inp_valid=%0b cin=%0b\n",req.opa,req.opb,req.ce,req.mode,req.cmd,req.inp_valid,req.cin),UVM_LOW)
			seq_item_port.item_done();


		end
	endtask

	task drive(seq_item req);
		@(vif.drv);
		vif.drv.OPA<=req.opa;
		vif.drv.OPB<=req.opb;
		vif.drv.CE<=req.ce;
		vif.drv.MODE<=req.mode;
		vif.drv.CMD<=req.cmd;
		vif.drv.INP_VALID<=req.inp_valid;
		vif.drv.CIN<=req.cin;
		 //`uvm_info(get_type_name(), "Transaction Driven Successfully", UVM_LOW)
	endtask
endclass

		
		



			 


	 

