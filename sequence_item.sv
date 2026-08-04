class trans extends uvm_sequence_item;

	rand bit[7:0]OA;
 	rand bit[7:0]OB;
 	rand bit[1:0]inp_valid;
 	rand bit[3:0]cmd;
 	rand bit mode,cin,ce;
	rand bit rst;
	logic [15:0]res;
 	logic err,oflow,cout,G,E,L;

 function new(string name="trans");
	super.new(name);
 endfunction

`uvm_object_utils_begin(trans)
                `uvm_field_int(rst,UVM_ALL_ON);
                `uvm_field_int(ce,UVM_ALL_ON);
                `uvm_field_int(mode,UVM_ALL_ON);
                `uvm_field_int(cmd,UVM_DEC | UVM_ALL_ON);
                `uvm_field_int(inp_valid,UVM_BIN | UVM_ALL_ON);
	        `uvm_field_int(OA,UVM_DEC | UVM_ALL_ON);
		`uvm_field_int(OB,UVM_DEC | UVM_ALL_ON);
                `uvm_field_int(cin,UVM_ALL_ON);

                `uvm_field_int(res,UVM_DEC | UVM_ALL_ON);
                `uvm_field_int(err,UVM_ALL_ON);
                `uvm_field_int(oflow,UVM_ALL_ON);
                `uvm_field_int(cout,UVM_ALL_ON);
	 	`uvm_field_int(G,UVM_ALL_ON);
		`uvm_field_int(L,UVM_ALL_ON);
		`uvm_field_int(E,UVM_ALL_ON);
`uvm_object_utils_end


 endclass 

