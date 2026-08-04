class seq extends uvm_sequence #(trans);
	`uvm_object_utils(seq) 

 function new(string name="seq");
	super.new(name);
 endfunction

 task body();
	 
        req=trans::type_id::create("req");
	begin
		   start_item(req);
		    	assert(req.randomize() with
			{
			  rst==0;
			  ce==0;
			  inp_valid==2'b11;
			  if(mode==0)
				  cmd inside {[0:10]};
			  else
				  cmd inside {[0:13]};}
					);
		   finish_item(req);
	end
	
 endtask
endclass
//-------------------------------------------------------------------------------------

class seq_with_rst extends uvm_sequence #(trans);
        `uvm_object_utils(seq_with_rst)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
			assert(req.randomize() with {rst==1;});
                   finish_item(req);
        end

 endtask
endclass
//------------------------------------------------------------------------------------

class seq_without_ce extends uvm_sequence #(trans);
        `uvm_object_utils(seq_without_ce)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

        req=trans::type_id::create("req");
        begin
                   start_item(req);
			assert(req.randomize() with {rst==0; ce==0;});
                   finish_item(req);
        end

 endtask
endclass

//------------------------------------------------------------------------------------------
class seq_with_arithmatic extends uvm_sequence #(trans);
        `uvm_object_utils(seq_with_arithmatic)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();

	 repeat(10) begin
         req =trans::type_id::create("req");
        begin
                   start_item(req);
		assert(req.randomize() with {rst==0; ce==1; mode==1; cmd inside {10}; inp_valid==2'b11;});
                   finish_item(req);
        end
	 end

 endtask
endclass

//---------------------------------------------------------------------------------------------

class seq_with_logical extends uvm_sequence #(trans);
        `uvm_object_utils(seq_with_logical)

 function new(string name="seq");
        super.new(name);
 endfunction

 task body();
	 repeat(10) begin

        req=trans::type_id::create("req");
        begin
                   start_item(req);
		assert(req.randomize() with {rst==0; ce==1; mode==0; cmd inside {13}; inp_valid==2'b11;});
                   finish_item(req);
        end
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
	    repeat(10) begin
        req = trans::type_id::create("req");
		
        start_item(req);
	    assert(req.randomize() with { inp_valid == 2'b01; ce == 1; rst==0;  });
        finish_item(req);

        for(int i = 0; i < 17; i++) begin
            start_item(req);
		assert(req.randomize() with { inp_valid == 2'b01; ce == 1; rst==0; });
            finish_item(req);
        end

        start_item(req);
	    assert(req.randomize() with { inp_valid == 2'b10; ce == 1; rst==0; });
        finish_item(req);
	    end
    endtask
endclass

//------------------------------------------------------------------------------------------------------

class seq_delayed_valid extends uvm_sequence #(trans);
    `uvm_object_utils(seq_delayed_valid)

	function new(string name="seq_delayed_valid");
        super.new(name);
    endfunction

    task body();
	    repeat(10) begin
        req = trans::type_id::create("req");

        start_item(req);
		    assert(req.randomize() with { inp_valid == 2'b01; ce == 1; rst==0; mode==1; cmd==0;
	   				 		/*if(mode==0)
	                                     		cmd inside {0};
	                             			else
	                                     		cmd inside {0}; */});
        finish_item(req);

		for(int i = 0; i < $urandom_range(0,15); i++) 
		begin
            start_item(req);
			assert(req.randomize() with { inp_valid == 2'b01; ce == 1; rst==0; mode==1; cmd==0;
		       						 /*if(mode==0)
		                                  		cmd inside {0};
		                                    	 else
		                                  		cmd inside {0};*/	});
            finish_item(req);
        end

        start_item(req);
			    assert(req.randomize() with { inp_valid == 2'b10; ce == 1; rst==0; mode==1; cmd==0;
	   							/* if(mode==0)
	                                			     cmd inside {0};
	                             				else
	                                    			     cmd inside {0};*/ });
        finish_item(req);

	    end
    endtask
endclass

//-------------------------------------------------------------------------------------------------------------

class seq_regression extends uvm_sequence #(trans);
	seq seq_h;
	seq_with_rst swr;
	seq_without_ce swc;
	seq_with_arithmatic swa;
	seq_with_logical swl;
	seq_timeout_test stt;
	seq_delayed_valid sdv;

	function new(string name="seq_regression");
		super.new(name);
	endfunction

	task body();
		seq_h=seq::type_id::create("seq_h");
			seq_h.start(m_sequencer);

		swr=seq_with_rst::type_id::create("swr");
			swr.start(m_sequencer);

		swc=seq_without_ce::type_id::create("swc");
			swc.start(m_sequencer);

		swa=seq_with_arithmatic::type_id::create("swa");
			swa.start(m_sequencer);

		swl=seq_with_logical::type_id::create("swl");
			swl.start(m_sequencer);

		stt=seq_timeout_test::type_id::create("stt");
			stt.start(m_sequencer);

		sdv=seq_delayed_valid::type_id::create("sdv");
			sdv.start(m_sequencer);
	endtask
endclass


