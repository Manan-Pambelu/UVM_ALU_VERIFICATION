class trans extends uvm_sequence_item;
	`uvm_object_utils(trans)

	rand bit[7:0]OA;
 	rand bit[7:0]OB;
 	rand bit[1:0]inp_valid;
 	rand bit[3:0]cmd;
 	rand bit mode,cin,ce;
 	logic [8:0]res;
 	logic rst,err,oflow,cout,G,E,L;
 

 constraint c0{ce dist{1:=90};}
 constraint c1{OA inside {[1:500]};}
 constraint c2{OB inside {[1:500]};}
 constraint c3{inp_valid dist {2'b00 :=5, 2'b01 :=5, 2'b10 :=5, 2'b11 :=500};}
 constraint c4{mode dist{1'b1:=5,1'b0:=5};}
 constraint c5{if(mode==1)
		cmd<11;
		else
		cmd<13;}
// constraint c5{cmd dist{4'b1001:=10};}
 constraint c6{cin dist{1:=5,0:=5};}


 function new(string name="trans");
	super.new(name);
 endfunction


 virtual function void do_copy(uvm_object rhs);
	trans rhs_;
	if(!$cast(rhs_,rhs))
		begin
		`uvm_fatal("do_copy","cast of the rhs object failed")
		end
	super.do_copy(rhs);
	
	this.OA=rhs_.OA;
	this.OB=rhs_.OB;
	this.inp_valid=rhs_.inp_valid;
	this.cmd=rhs_.cmd;
	this.mode=rhs_.mode;
	this.cin=rhs_.cin;
	this.ce=rhs_.ce;
	this.res=rhs_.res;
	this.err=rhs_.err;
	this.oflow=rhs_.oflow;
	this.cout=rhs_.cout;
	this.G=rhs_.G;
	this.E=rhs_.E;
	this.L=rhs_.L;
endfunction


	
 virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
	trans rhs_;
	if(!$cast(rhs_,rhs))
		begin
		  `uvm_fatal("do_compare","cast of the rhs object failed")
		   return 0;
		end 
	return
		super.do_compare(rhs,comparer)&&
		res==rhs_.res &&
		err==rhs_.err &&
		oflow==rhs_.oflow &&
		cout==rhs_.cout &&
		G==rhs_.G &&
		L==rhs_.L &&
		E==rhs_.E;
	 endfunction

virtual function void do_print(uvm_printer printer);
	super.do_print(printer);
	printer.print_field("Clock Enable",this.ce,1,UVM_DEC);
	printer.print_field("INPUT_A",this.OA,8,UVM_DEC);
	printer.print_field("INPUT_B",this.OB,8,UVM_DEC);
	printer.print_field("INPUT_VALID",this.inp_valid,2,UVM_DEC);
	printer.print_field("COMMAND",this.cmd,4,UVM_DEC);
	printer.print_field("MODE",this.mode,1,UVM_DEC);
	printer.print_field("CIN",this.cin,1,UVM_DEC);

	printer.print_field("RESULT",this.res,9,UVM_DEC);
	printer.print_field("ERROR",this.err,1,UVM_DEC);
	printer.print_field("OFLOW",this.oflow,1,UVM_DEC);
	printer.print_field("COUT",this.cout,1,UVM_DEC);
	printer.print_field("GREATER",this.G,1,UVM_DEC);
	printer.print_field("EQUALITY",this.E,1,UVM_DEC);
	printer.print_field("LESSER",this.L,1,UVM_DEC);
endfunction

 endclass 

