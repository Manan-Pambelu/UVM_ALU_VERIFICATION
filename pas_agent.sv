class alu_pas_agent extends uvm_agent;

        `uvm_component_utils(alu_pas_agent)

	alu_pas_monitor pas_mon_h;

        function new(string name="alu_pas_agent", uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                pas_mon_h=alu_pas_monitor::type_id::create("pas_mon_h",this);

        endfunction

endclass
