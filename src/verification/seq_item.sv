class seq_item extends uvm_sequence_item;
	rand logic [`DW-1:0]opa;
	rand logic [`DW-1:0]opb;
	rand logic mode;
	rand logic ce;
	rand logic cin;
	rand logic[`CW-1:0]cmd;
	rand logic[1:0]inp_valid;

	bit[`DW*2-1:0]res;
	bit cout;
	bit oflow;
	bit g,e,l;
	bit err;
	int unsigned txn_id;

	`uvm_object_utils_begin(seq_item)
	`uvm_field_int(opa,UVM_ALL_ON)
	`uvm_field_int(opb,UVM_ALL_ON)
	`uvm_field_int(ce,UVM_ALL_ON)
	`uvm_field_int(mode,UVM_ALL_ON)
	`uvm_field_int(cin,UVM_ALL_ON)
	`uvm_field_int(cmd,UVM_ALL_ON)
	`uvm_field_int(inp_valid,UVM_ALL_ON)
	`uvm_field_int(res,UVM_ALL_ON)
	`uvm_field_int(cout,UVM_ALL_ON)
	`uvm_field_int(oflow,UVM_ALL_ON)
	`uvm_field_int(g,UVM_ALL_ON)
	`uvm_field_int(l,UVM_ALL_ON)
	`uvm_field_int(e,UVM_ALL_ON)
	`uvm_field_int(err,UVM_ALL_ON)
	`uvm_field_int(txn_id,UVM_ALL_ON)
	`uvm_field_utils_end

	function new(string name="seq_item");
		super.new(name);
	endfunction

	function void display(string msg="");
	 `uvm_info(get_type_name(),$sformatf("%s OPA=%0d OPB=%0d MODE=%0b CMD=%0h CIN=%0b INP_VALID=%0b RES=%0d",msg,opa,opb,mode,cmd,cin,inp_valid,res), UVM_LOW)
	endfunction
endclass



