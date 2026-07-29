class seq extends uvm_sequence #(trans);
	`uvm_object_utils(seq) 

 function new(string name="seq");
	super.new(name);
 endfunction

 task body();
       req=trans::type_id::create("req");
	begin
		   start_item(req);
		   assert(req.randomize() with {mode==1'b1;cmd==4'b0000;OA=='d3;OB=='d3;});
		   finish_item(req);
	end
 endtask

 endclass

class seq_1 extends uvm_sequence #(trans);
	`uvm_object_utils(seq_1) 

 function new(string name="seq_1");
	super.new(name);
 endfunction

 task body();
       req=trans::type_id::create("req");
	begin
		   start_item(req);
		   assert(req.randomize() with {mode==1'b1;cmd==4'b0001;OA=='d10;OB=='d5;});
		   finish_item(req);
	end
 endtask

 endclass

class cycle_seq extends uvm_sequence #(trans);
	`uvm_object_utils(cycle_seq) 

 function new(string name="cycle_seq");
	super.new(name);
 endfunction

 task body();
       req=trans::type_id::create("req");
	begin
		   start_item(req);
		   assert(req.randomize() with {mode==1'b1;cmd==4'b1001;OA=='d10;OB=='d5;});
		   finish_item(req);
	end
 endtask

 endclass


class err_seq extends uvm_sequence #(trans);
	`uvm_object_utils(err_seq) 

 function new(string name="err_seq");
	super.new(name);
 endfunction

 task body();
       req=trans::type_id::create("req");
	begin
		   start_item(req);
		   assert(req.randomize() with {mode==1'b0;cmd==4'b1100;OA=='d100;OB=='b10000001;});
		   finish_item(req);
	end
 endtask

 endclass










