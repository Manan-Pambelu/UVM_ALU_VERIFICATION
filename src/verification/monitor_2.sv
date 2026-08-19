class monitor_2 extends uvm_monitor;
        `uvm_component_utils(monitor_2)
          virtual  alu_if.MON vif;
          uvm_analysis_port #(seq_item)mon2_ap;

        function new(string name="monitor_2",uvm_component parent);
                super.new(name,parent);
                mon2_ap=new("monitor_2_ap",this);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
         if(!uvm_config_db #(virtual alu_if)::get(this,"","vif",vif))
                 `uvm_fatal(get_type_name(),"cannot get interface instance in monitor_2");
        endfunction

        task run_phase(uvm_phase phase);
                 seq_item req;
         	//	@(vif.mon);
                forever begin
                        @(vif.mon);
                        req=seq_item::type_id::create("output_txn");
                        req.opa=vif.mon.OPA;
                        req.opb=vif.mon.OPB;
                        req.ce=vif.mon.CE;
                        req.mode=vif.mon.MODE;
                        req.cmd=vif.mon.CMD;
                        req.cin=vif.mon.CIN;
                        req.inp_valid=vif.mon.INP_VALID;
                        req.res=vif.mon.RES;
                        req.cout=vif.mon.COUT;
                        req.oflow=vif.mon.OFLOW;
                        req.g=vif.mon.G;
                        req.e=vif.mon.E;
                        req.l=vif.mon.L;
                        req.err=vif.mon.ERR;
			//req.rst = vif.mon.rst;
			 `uvm_info(get_type_name(),$sformatf("opa=%0h,opb=%0h,ce=%0b,mode=%0b,cmd=%0d,inp_valid=%0b cin=%0b res=%0h cout=%0b oflow=%0b g=%0b l=%0b e=%0b err=%0b\n",req.opa,req.opb,req.ce,req.mode,req.cmd,req.inp_valid,req.cin,req.res, req.cout,req.oflow,req.g,req.l,req.e, req.err),UVM_LOW)
                        mon2_ap.write(req);
			//`uvm_info(get_type_name(),$sformatf("Output moniotr Captured\n%s",req.sprint()),UVM_MEDIUM)
                end
        endtask
endclass


