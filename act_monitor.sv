class alu_act_monitor extends uvm_monitor;
        `uvm_component_utils(alu_act_monitor)
        uvm_analysis_port #(trans) act_mon_aport;
        virtual alu_if vif;

        trans tx;

        function new(string name ="alu_act_monitor",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                act_mon_aport=new("act_mon_aport", this);
                if(!uvm_config_db#(virtual alu_if)::get(this,"","alu_if",vif))
                        `uvm_fatal(get_type_name(),"accesing virtual interface in monitor failed")
        endfunction

        task run_phase(uvm_phase phase);
                super.run_phase(phase);

                forever
                begin
                        repeat(3) @(vif.act_mon_cb)

                        tx.mode=vif.mode;
                        tx.cmd=vif.cmd;
                        tx.res=vif.res;
                        tx.ce=vif.ce;
                        tx.OA=vif.OA;
                        tx.OB=vif.OB;
                        tx.inp_valid=vif.inp_valid;
                        tx.cin=vif.cin;

                        act_mon_aport.write(tx);
                end
        endtask
endclass
