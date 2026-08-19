`include "design.sv"
`include "interface.sv"
`include "package.sv"

module top;
import uvm_pkg::*;
import alu_pkg::*;
  bit clk;
  bit reset;

  always #5 clk = ~clk;

  initial begin
    reset = 1'b1;     
    @(posedge clk);	  
    reset = 1'b0;
  end

  alu_if intf (.clk(clk), .rst(reset));

   ALU_DESIGN #(
    .DW (8),
    .CW (4)
  ) dut (
    .CLK       (intf.clk),
    .RST       (intf.rst),
    .CE        (intf.CE),
    .MODE      (intf.MODE),
    .CIN       (intf.CIN),
    .CMD       (intf.CMD),
    .OPA       (intf.OPA),
    .OPB       (intf.OPB),
    .INP_VALID (intf.INP_VALID),
    .RES       (intf.RES),
    .COUT      (intf.COUT),
    .OFLOW     (intf.OFLOW),
    .G         (intf.G),
    .E         (intf.E),
    .L         (intf.L),
    .ERR       (intf.ERR)
  );

  initial begin
    uvm_config_db#(virtual alu_if)::set(uvm_root::get(), "*", "vif", intf);
  end

  initial begin
	uvm_factory::get().print();
    run_test("test");
  end


endmodule
