class test extends uvm_test;
    `uvm_component_utils(test)
    environment envh;
    base_sequence seqh;

    function new(string name="test",uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        envh=environment::type_id::create("envh",this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        repeat(`num_transaction) begin
           seqh=all_arith_11::type_id::create("seqh");
            seqh.start(envh.agnh1.seqrh);
	   seqh= all_logic_13::type_id::create("seqh");
            seqh.start(envh.agnh1.seqrh); 
	    seqh=timeout_seq::type_id::create("seqh");
	    seqh.start(envh.agnh1.seqrh);
	   seqh= mul_cmd_9::type_id::create("seqh");
	    seqh.start(envh.agnh1.seqrh);
             #55;
	   seqh= mul_cmd_10::type_id::create("seqh");
            seqh.start(envh.agnh1.seqrh); 
	    #55;
	   seqh= all_rand_mode1_ce1::type_id::create("seqh");
	   seqh.start(envh.agnh1.seqrh);
	  seqh= all_rand_mode0_ce1::type_id::create("seqh");
	  seqh.start(envh.agnh1.seqrh);	
        end
        phase.phase_done.set_drain_time(this, 100);
        phase.drop_objection(this);
    endtask
endclass

 
