class alu_pas_monitor extends uvm_monitor;
        `uvm_component_utils(alu_pas_monitor)
        uvm_analysis_port #(trans) pas_mon_aport;
        virtual alu_if vif;

        trans tx;

        function new(string name ="alu_pas_monitor",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                pas_mon_aport=new("pas_mon_aport", this);
                if(!uvm_config_db#(virtual alu_if)::get(this,"","alu_if",vif))
                        `uvm_fatal(get_type_name(),"accesing virtual interface in monitor failed")
        endfunction

        task run_phase(uvm_phase phase);
                super.run_phase(phase);

                forever
                begin
			@(vif.pas_mon_cb);

			if(!vif.pas_mon_cb.rst)
			begin
			tx=trans::type_id::create("tx");

                        tx.res=vif.res;
                        tx.err=vif.err;
                        tx.oflow=vif.oflow;
                        tx.cout=vif.cout;
                        tx.G=vif.G;
                        tx.L=vif.L;
                        tx.E=vif.E;
 			
				`uvm_info(get_type_name(), $sformatf("pas_mon -> rst: %b | ce: %b | mode: %b | cmd: %0d | valid: %b | OA: %0d | OB: %0d | cin: %b | res: %0d",vif.rst, vif.ce, vif.mode, vif.cmd, vif.inp_valid, vif.OA, vif.OB, vif.cin, vif.res), UVM_LOW)
                        pas_mon_aport.write(tx);
			end
                end
        endtask
endclass
