
class base_sequence extends uvm_sequence#(seq_item);
        `uvm_object_utils(base_sequence)
        function new(string name="base_sequence");
                super.new(name);
        endfunction

        task body();
                `uvm_info(get_type_name(),"Base sequence",UVM_LOW)
        endtask

endclass

                      
class all_arith_11 extends base_sequence;
`uvm_object_utils(all_arith_11)
seq_item req;
function new(string name="all_arith_11");
super.new(name);
endfunction
task body();

	for(int i=0;i<=8;i++)begin
        req = seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.mode       == 1'b1;
            req.cmd        == i;
            req.inp_valid  == 2'b11;
            req.ce         == 1'b1;
	    req.cin ==1'b0;
        });
        finish_item(req);
	
	end

endtask
endclass
class all_logic_13 extends base_sequence;
`uvm_object_utils(all_logic_13)
seq_item req;
function new(string name="all_logic_13");
super.new(name);
endfunction
task body();

        for(int i=0;i<=13;i++)begin
        req = seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.mode       == 1'b0;
            req.cmd        == i;
            req.inp_valid  == 2'b11;
            req.ce         == 1'b1;
            req.cin ==1'b0;
        });
        finish_item(req);

        end

endtask
endclass
	
class mul_cmd_9 extends base_sequence;
	`uvm_object_utils(mul_cmd_9)
	seq_item req;
	function new(string name="mul_cmd_9");
		super.new(name);
	endfunction
task body();

        req = seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.mode       == 1'b1;
            req.cmd        == 9;
            req.inp_valid  == 2'b11;
            req.ce         == 1'b1;
            req.cin ==1'b0;
        });
        finish_item(req);


endtask
endclass
class mul_cmd_10 extends base_sequence;
        `uvm_object_utils (mul_cmd_10)
        seq_item req;
	function new(string name="mul_cmd_10");
                super.new(name);
        endfunction
task body();
        req = seq_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.mode       == 1'b1;
            req.cmd        == 10;
            req.inp_valid  == 2'b11;
            req.ce         == 1'b1;
            req.cin ==1'b0;
        });
        finish_item(req);

       
endtask
endclass

class timeout_seq extends base_sequence;
  `uvm_object_utils(timeout_seq)

  seq_item req;

  int wait_cycles;  

  bit mode;
  bit [`CW-1:0] cmd;

  function new(string name="timeout_seq");
    super.new(name);
  endfunction

  task body();
    wait_cycles = 16;
   
    req = seq_item::type_id::create("req");
    start_item(req);
	   `uvm_info(get_type_name(),
		         $sformatf("VALID item sent: mode=%0b cmd=%0h -- now sending %0d 01 items",
				                  mode, cmd, wait_cycles), UVM_LOW)
    assert(req.randomize() with {
      req.ce        == 1;
	    req.cmd      ==0;
	    req.mode      ==1;//inside {0,1};
            req.inp_valid == 2'b01;
    });
    finish_item(req);

    mode = req.mode;
    cmd  = req.cmd;

    `uvm_info(get_type_name(),
      $sformatf("VALID item sent: mode=%0b cmd=%0h -- now sending %0d idle(00) items",
                 mode, cmd, wait_cycles), UVM_LOW)

    repeat (wait_cycles) begin
      req = seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {
        req.ce        == 1;
        req.mode      == local::mode;
        req.cmd       == local::cmd;
        req.inp_valid == 2'b00;
      });
      finish_item(req);

      `uvm_info(get_type_name(),
        $sformatf("IDLE item sent: mode=%0b cmd=%0h inp_valid=00", req.mode, req.cmd),
        UVM_LOW)
    end

  endtask
endclass

class all_rand_mode1_ce1 extends base_sequence;
`uvm_object_utils(all_rand_mode1_ce1)
seq_item req;
function new(string name="all_rand_mode1_ce1");
    super.new(name);
  endfunction
task body();
	for(int i=0;i<11;i++)begin
        req = seq_item::type_id::create("req");
        start_item(req);
		assert(req.randomize()with {req.ce==1;req.mode==1;req.cmd==i;});    
        finish_item(req);
end

endtask
endclass
class all_rand_mode0_ce1 extends base_sequence;
`uvm_object_utils(all_rand_mode0_ce1)
seq_item req;
function new(string name="all_rand_mode0_ce1");
    super.new(name);
  endfunction
task body();
        for(int i=0;i<14;i++)begin
        req = seq_item::type_id::create("req");
        start_item(req);
                assert(req.randomize()with {req.ce==1;req.mode==0;req.cmd==i;});
        finish_item(req);
end

endtask
endclass
