class alu_driver extends uvm_driver #(trans);
	`uvm_component_utils(alu_driver)

	reg [3:0] temp_cmd;
	reg temp_mode;
	reg [3:0] count;

	alu seq_item temp_seq;

	virtual alu_if vif;

	uvm_analysis_port #(trans) driven_data;

	function new(string name="alu_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

	       	if(!uvm_config_db#(virtual alu_if)::set(this,"","alu_if",vif))
			`uvm_fatal(get_type_name(), "virtual inteface config failed")

		driven_data=new("driven_data",this);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);

		seq_item_port.get_next_item(req);

		if((req.mode==1 && (req.cmd<4 || (req.cmd>7 && req.cmd<=10))) || (req.mode==0 && (req.cmd<6 || (req.cmd>11 && req.cmd<=13))) && (req.inp_valid==1 || req.inp_valid==2) && (count!=15))

		begin
			if(count==0)
			begin
				temp_cmd <=req.cmd;
				temp_mode <=req.mode;
			end

			drive_with_count();
			count++;

		end

		else if(count>0 &&( req.inp_valid==1 || req.inp_valid==2))
		begin
			drive_with_count();
			count++
		end

		else
		begin
			if(count>0)
			begin
				drive_with_count();
			end

			else
				drive_without_count();
		end

		seq_item_port.item_done(req);
	endtask

	task drive_with_count();
		begin
		temp_seq=trans::type_id::create("temp_seq",this);
                temp_seq.copy(req);
		temp_seq.cmd<=temp_cmd;
		temp_seq.mode<=temp_mode;

		vif.cmd<= temp_cmd;
		vif.mode<=temp_mode;
		vif.res<=req.res;
		vif.ce<=req.ce;
		vif.OA<=req.OA;
		vif.OB<=req.OB;
		vif.cin<=req.cin;
		vif.inp_valid<=req.inp_valid;

		repeat(3) @(posedge vif.driver_cb)
		driven_data.write(req);
		end
	endtask


	task drive_without_count();
		begin
 		vif.cmd<= req.cmd;
		vif.mode<=req.mode;
		vif.res<=req.res;
		vif.ce<=req.ce;
		vif.OA<=req.OA;
		vif.OB<=req.OB;
		vif.cin<=req.cin;
		vif.inp_valid<=req.inp_valid;

		repeat(3) @(posedge vif.driver_cb)
		driven_data.write(req);

		end
	endtask
endclass








