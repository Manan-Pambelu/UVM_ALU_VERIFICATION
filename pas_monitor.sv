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
                        repeat(3) @(vif.pas_mon_cb)

                        tx.res=vif.res;
                        tx.err=vif.err;
                        tx.oflow=vif.oflow;
                        tx.cout=vif.cout;
                        tx.g=vif.g;
                        tx.l=vif.l;
                        tx.e=vif.e;

                        pas_mon_aport.write(tx);
                end
        endtask
endclass
