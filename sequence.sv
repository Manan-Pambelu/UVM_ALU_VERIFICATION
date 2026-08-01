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

class seq_with_rst extends uvm_sequence #(trans);
        `uvm_object_utils(seq)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
					assert(req.randomize() with {req.rst==1});
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
						assert(req.randomize() with {req.res==0; req.ce=0});
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
			           assert(req.randomize() with {req.res==0; req.ce==1; req.mode==1; req.cmd inside {[0:10]};});
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
						assert(req.randomize() with {req.res==0; req.ce==1; req.mode==0; req.cmd inside {[0:13]};});
                   finish_item(req);
        end

 endtask
endclass

//------------------------------------------------------------------------------------------------------------

class seq_timeout_test extends uvm_sequence #(trans);
    `uvm_object_utils(seq_timeout_test)

    function new(string name="seq_timeout_test");
        super.new(name);
    endfunction

    task body();
        req = trans::type_id::create("req");
		
        start_item(req);
        assert(req.randomize() with { inp_valid == 2'b01; ce == 1; });
        finish_item(req);

        for(int i = 0; i < 17; i++) begin
            start_item(req);
            assert(req.randomize() with { inp_valid == 2'b00; ce == 1; });
            finish_item(req);
        end

        start_item(req);
        assert(req.randomize() with { inp_valid == 2'b10; ce == 1; });
        finish_item(req);
    endtask
endclass

//------------------------------------------------------------------------------------------------------

class seq_delayed_valid extends uvm_sequence #(trans);
    `uvm_object_utils(seq_timeout_test)

	function new(string name="seq_delayed_valid");
        super.new(name);
    endfunction

    task body();
        req = trans::type_id::create("req");

        start_item(req);
        assert(req.randomize() with { inp_valid == 2'b01; ce == 1; });
        finish_item(req);

		for(int i = 0; i < $urandom_range(0,15); i++) begin
            start_item(req);
            assert(req.randomize() with { inp_valid == 2'b00; ce == 1; });
            finish_item(req);
        end

        start_item(req);
        assert(req.randomize() with { inp_valid == 2'b10; ce == 1; });
        finish_item(req);
    endtask
endclass
