
class alu_input_coverage extends uvm_subscriber #(seq_item);
    `uvm_component_utils(alu_input_coverage)

    seq_item txn;
    //virtual alu_if vif;   

    covergroup input_cg;
        option.per_instance = 1;

      //  rst_cp : coverpoint vif.rst {
        //    bins rst_low  = {1'b0};
          //  bins rst_high = {1'b1};
        //}

        ce_cp : coverpoint txn.ce {
            bins ce_low  = {1'b0};
            bins ce_high = {1'b1};
        }

        mode_cp : coverpoint txn.mode {
            bins logical    = {1'b0};
            bins arithmetic = {1'b1};
        }

        inp_valid_cp : coverpoint txn.inp_valid {
            bins clr    = {2'b00};
            bins a_only = {2'b01};
            bins b_only = {2'b10};
            bins both   = {2'b11};
        }

        cmd_cp : coverpoint txn.cmd {
            bins cmd_val[16] = {[0:15]};
        }

        cin_cp : coverpoint txn.cin {
            bins cin_low  = {1'b0};
            bins cin_high = {1'b1};
        }

        opa_cp : coverpoint txn.opa {
            bins low  = {[0:84]};
            bins mid  = {[85:170]};
            bins high = {[171:255]};
        }

        opb_cp : coverpoint txn.opb {
            bins low  = {[0:84]};
            bins mid  = {[85:170]};
            bins high = {[171:255]};
        }

        MODExCMD : cross mode_cp, cmd_cp;

        INP_VALIDxCE : cross inp_valid_cp, ce_cp;

        //RSTxCE : cross rst_cp, ce_cp;
            endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        input_cg = new();
    endfunction

//    function void build_phase(uvm_phase phase);
  //      super.build_phase(phase);
    //    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      //      `uvm_fatal(get_type_name(), "virtual interface 'vif' not found in config_db")
    //endfunction

    function void write(seq_item t);
        txn = t;
        input_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("Input coverage: %0.2f%%", input_cg.get_coverage()),
            UVM_LOW)
    endfunction
endclass
