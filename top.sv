       `include "test_pkg.sv"
	`include "alu_if.sv"
	`include "alu_rtl.sv"

 module top();       
	import uvm_pkg::*;

	bit clk;

	alu_if DUV_IF(clk);

   
 //instatiate DUV
        ALU_DESIGN DUV(.OPA(DUV_IF.OA),.OPB(DUV_IF.OB),.CLK(clk),.RST(DUV_IF.rst),.CE(DUV_IF.ce),.MODE(DUV_IF.mode),
		.CIN(DUV_IF.cin),.CMD(DUV_IF.cmd),.INP_VALID(DUV_IF.inp_valid),.RES(DUV_IF.res),.COUT(DUV_IF.cout),
		.OFLOW(DUV_IF.oflow),.G(DUV_IF.G),.E(DUV_IF.E),.L(DUV_IF.L),.ERR(DUV_IF.err));


 	initial
	begin
		uvm_config_db#(virtual alu_if)::set(null,"*","alu_if",DUV_IF);
		$dumpfile("waves.fsdb");
		  $dumpvars;

	        run_test();
		
	end


	
	initial
	begin
		clk=1'b0;
		forever 
		   #5 clk=~clk;
	end

endmodule

