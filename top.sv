       `include "package.svh"
	`include "interface.sv"
	`include "DUT.sv"

 module top();       
	import uvm_pkg::*;
	import test_pkg::*;

	bit clk;

	alu_if vif(clk);

   
 //instatiate DUV
        ALU_DESIGN DUV(.OPA(vif.OA),.OPB(vif.OB),.CLK(clk),.RST(vif.rst),.CE(vif.ce),.MODE(vif.mode),
		.CIN(vif.cin),.CMD(vif.cmd),.INP_VALID(vif.inp_valid),.RES(vif.res),.COUT(vif.cout),
		.OFLOW(vif.oflow),.G(vif.G),.E(vif.E),.L(vif.L),.ERR(vif.err));


 	initial
	begin
		uvm_config_db#(virtual alu_if)::set(null,"*","alu_if",vif);
		$dumpfile("waves.fsdb");
		  $dumpvars;

	        run_test("test1");
		
	end


	
	initial
	begin
		clk=1'b0;
		forever 
		   #5 clk=~clk;
	end

endmodule

