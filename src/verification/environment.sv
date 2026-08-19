class environment extends uvm_env;
        `uvm_component_utils(environment)
        agent_1 agnh1;
        agent_2 agnh2;
        scoreboard scrh;

        alu_input_coverage  input_cov;

        function new(string name="environment",uvm_component parent);
                super.new(name , parent);
        endfunction
        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uvm_config_db #(uvm_active_passive_enum)::set(this, "agnh1", "is_active", UVM_ACTIVE);
                uvm_config_db #(uvm_active_passive_enum)::set(this, "agnh2", "is_active", UVM_PASSIVE);
                agnh1=agent_1::type_id::create("agnh1",this);
                agnh2=agent_2::type_id::create("agnh2",this);
                scrh=scoreboard::type_id::create("scrh",this);
                input_cov  = alu_input_coverage::type_id::create("input_cov", this);
        endfunction
        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                agnh1.ap.connect(scrh.fifo_in.analysis_export);
                agnh2.ap.connect(scrh.fifo_op.analysis_export);
                agnh1.ap.connect(input_cov.analysis_export);
        endfunction
endclass
