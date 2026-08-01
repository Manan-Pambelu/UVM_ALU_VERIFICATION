class seq extends uvm_sequence #(trans);
	`uvm_object_utils(seq) 

 function new(string name="seq");
	super.new(name);
 endfunction

 task body();
	 
        req=trans::type_id::create("req");
	begin
		   start_item(req);
		    	assert(req.randomize());
		   finish_item(req);
	end
	
 endtask
endclass
//-------------------------------------------------------------------------------------

class seq_with_res extends uvm_sequence #(trans);
        `uvm_object_utils(seq)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
                        assert(req.randomize() with req.res==1;);
                   finish_item(req);
        end

 endtask
endclass
//------------------------------------------------------------------------------------

class seq_without_ce extends uvm_sequence #(trans);
        `uvm_object_utils(seq)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
                        assert(req.randomize() with req.res==0; req.ce=0;);
                   finish_item(req);
        end

 endtask
endclass

//------------------------------------------------------------------------------------------
class seq_with_arithmatic extends uvm_sequence #(trans);
        `uvm_object_utils(seq)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
                        assert(req.randomize() with req.res==0; req.ce==1; req.mode==1; req.cmd inside {[0:10]};);
                   finish_item(req);
        end

 endtask
endclass

//---------------------------------------------------------------------------------------------

class seq_with_logical extends uvm_sequence #(trans);
        `uvm_object_utils(seq)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
                        assert(req.randomize() with req.res==0; req.ce==1; req.mode==0; req.cmd inside {[0:13]};);
                   finish_item(req);
        end

 endtask
endclass
