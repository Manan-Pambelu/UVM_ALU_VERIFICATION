class alu_driver extends uvm_driver #(trans);
    `uvm_component_utils(alu_driver)

    virtual alu_if vif;
    uvm_analysis_port #(trans) driven_data;

    function new(string name="alu_driver", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual alu_if)::get(this,"","alu_if",vif))
            `uvm_fatal(get_type_name(), "virtual interface config failed")
        driven_data = new("driven_data",this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            seq_item_port.get_next_item(req);

            vif.cmd       <= req.cmd;
            vif.mode      <= req.mode;
            vif.res       <= req.res;
            vif.ce        <= req.ce;
            vif.OA        <= req.OA;
            vif.OB        <= req.OB;
            vif.cin       <= req.cin;
            vif.inp_valid <= req.inp_valid;

            @(posedge vif.CLK);

			driven_data.write(req);  //if driven data values need to be captured 

            seq_item_port.item_done();
        end
    endtask
endclass
