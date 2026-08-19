class scoreboard extends uvm_scoreboard;
        `uvm_component_utils(scoreboard)
        uvm_tlm_analysis_fifo #(seq_item)fifo_in;
        uvm_tlm_analysis_fifo #(seq_item)fifo_op;

        bit[`DW-1:0]opa;
        bit[`DW-1:0]opb;
        bit ce;
        bit mode;
        bit cin;
        bit [`CW-1:0]cmd;
        bit[1:0]inp_valid;

        bit opa_valid ;
        bit opb_valid;

        bit[`DW*2-1:0]res;
        bit cout;
        bit oflow;
        bit g,l,e,err;

        bit[`DW*2-1:0]resc,opa_temp,opb_temp;
        bit coutc;
        bit oflowc;
        bit gc,lc,ec,errc;

        int op_count;
        int count;

        int opa_temp3,opa_temp2,opa_temp1;
        int opb_temp3,opb_temp2,opb_temp1;
        int cmd_temp3,cmd_temp2,cmd_temp1;
        int mode_temp3,mode_temp2,mode_temp1;
        seq_item inp_txn,out_txn;
        int fail_count,pass_count,total_txn;
        bit start,start1;
        function new(string name="scoreboard",uvm_component parent);
                super.new(name,parent);
                fifo_in=new("fifo_in",this);
                fifo_op=new("fifo_op",this);
                endfunction

        task run_phase(uvm_phase phase);
                forever begin
                        fifo_in.get(inp_txn);
                        `uvm_info("SCB",$sformatf("\topa=%0h,opb=%0h,cmd=%0d,mode=%0b",opa_temp2,opb_temp2,cmd_temp2,mode_temp2),UVM_LOW)
                        //opa_temp3=opa_temp2;
                         opa_temp2=opa_temp1;
                         opa_temp1=inp_txn.opa;
                        //opb_temp3=opb_temp2;
                         opb_temp2=opb_temp1;
                         opb_temp1=inp_txn.opb;
                        //cmd_temp3=cmd_temp2;
                         cmd_temp2=cmd_temp1;
                        cmd_temp1=inp_txn.cmd;
                        //mode_temp3=mode_temp2;
                        mode_temp2=mode_temp1;
                        mode_temp1=inp_txn.mode;
                         fifo_op.get(out_txn);
                        total_txn++;
                        reference_model();
                        compare();
                end
        endtask

        task reference_model();
                bit cmd_mode_change;
                resc=res;
                coutc=cout;
                oflowc=oflow;
                gc=g;
                lc=l;
                ec=e;
                errc=err;



                if(!inp_txn.ce)
                        return;

                 cmd_mode_change = (inp_txn.cmd != cmd)||(inp_txn.mode != mode);
                if(opa_valid && !opb_valid) begin

              if(inp_txn.inp_valid[1]) begin
                  count = 0;
              end
             else begin

            count++;

            if(count >= 16) begin
                err = 1;
                opa_valid = 0;
                opb_valid = 0;
                count = 0;
            end
        end

    end
    else if(!opa_valid && opb_valid) begin

        if(inp_txn.inp_valid[0]) begin
            // OPA arrived
            count = 0;
        end
        else begin
            // OPA did not arrive
            count++;

            if(count >= 16) begin
                err = 1;
                opa_valid = 0;
                opb_valid = 0;
                count = 0;
            end
        end

    end
    else begin
        count = 0;
    end


                //g=0;l=0;e=0;err=0;oflow=0;cout=0;

                if(mode)begin
                        case(cmd)
                                0:begin
                                        if(opa_valid && opb_valid)begin
                                                res=opa+opb;
                                                cout=res[`DW];
                                                opa_valid=0;opb_valid=0;
                                        end
                                end
                                1:begin
                                        if(opa_valid && opb_valid)begin
                                                res=opa-opb;
                                                cout=(opa[`DW-1]!=opb[`DW-1])&&(res[`DW-1]!=opa[`DW-1]);
                                                opa_valid=0;opb_valid=0;
                                        end
                                 end
                                 4'd2: begin
                                           if(opa_valid && opb_valid) begin
                                                res  = opa + opb + cin;
                                                cout = res[`DW];
                                                opa_valid=0; opb_valid=0;
                                            end
                                 end
                              4'd3: begin
                                    if(opa_valid && opb_valid) begin
                                        res   = opa - opb - cin;
                                        oflow = (opa[`DW-1]!=opb[`DW-1]) && (res[`DW-1]!=opa[`DW-1]);
                                        opa_valid=0; opb_valid=0;
                                   end
                                 end
                            4'd4: begin
                                if(opa_valid) begin
                                        res=opa+1; opa_valid=0;
                                end
                                end
                4'd5: begin
                    if(opa_valid) begin res=opa-1; opa_valid=0; end
                end
                4'd6: begin
                    if(opb_valid) begin
                            res=opb+1;
                            opb_valid=0; end
                end
                4'd7: begin
                    if(opb_valid) begin res=opb-1; opb_valid=0; end
                end
                4'd8: begin
                    if(opa_valid && opb_valid) begin
                        g = (opa>opb);
                        l = (opa<opb);
                        e = (opa==opb);
                        opa_valid=0; opb_valid=0;
                    end
                end
                4'd9: begin
                    if(start) begin
                        res = opa_temp * opb_temp;
                        opa_valid=0; opb_valid=0; op_count=1;
                           start=0;
                      end
                    if(opa_valid && opb_valid) begin
                        opa_temp = opa+1;
                        opb_temp = opb+1;
			 start=1;
                      end
                end
                4'd10: begin
                    if(start) begin
                        res = opa_temp * opb_temp;
                        opa_valid=0; opb_valid=0; op_count=1;
                            start=0;
                    end
		if(opa_valid && opb_valid) begin
                        opa_temp = opa<<1;
                        opb_temp = opb;
                        start=1;
                    end
                end
                default: begin
                    res=0; cout=0; oflow=0; g=0; e=0; l=0; err=1;
                end
            endcase
        end
        else begin
            case(cmd)
                4'd0: begin
                    if(opa_valid && opb_valid) begin res={1'b0,opa&opb}; opa_valid=0; opb_valid=0; end
                end
                4'd1: begin
                    if(opa_valid && opb_valid) begin res={1'b0,~(opa&opb)}; opa_valid=0; opb_valid=0; end
                end
                4'd2: begin
                    if(opa_valid && opb_valid) begin res={1'b0,opa|opb}; opa_valid=0; opb_valid=0; end
                end
                4'd3: begin
                    if(opa_valid && opb_valid) begin res={1'b0,~(opa|opb)}; opa_valid=0; opb_valid=0; end
                end
                4'd4: begin
                    if(opa_valid && opb_valid) begin res={1'b0,opa^opb}; opa_valid=0; opb_valid=0; end
                end
                4'd5: begin
                    if(opa_valid && opb_valid) begin res={1'b0,~(opa^opb)}; opa_valid=0; opb_valid=0; end
                end
                4'd6: begin
                    if(opa_valid) begin res={1'b0,~opa}; opa_valid=0; end
                end
                4'd7: begin
                    if(opb_valid) begin res={1'b0,~opb}; opb_valid=0; end
                end
                4'd8: begin
                    if(opa_valid) begin res={1'b0,opa>>1}; opa_valid=0; end
                end
                4'd9: begin
                    if(opa_valid) begin res={1'b0,opa<<1}; opa_valid=0; end
                end
                4'd10: begin
                    if(opb_valid) begin res={1'b0,opb>>1}; opb_valid=0; end
                end
                4'd11: begin
                    if(opb_valid) begin res={1'b0,opb<<1}; opb_valid=0; end
                    if(inp_txn.inp_valid[1]) begin opb=inp_txn.opb; opb_valid=1; end
                end
                4'd12: begin
                    if(opb[`DW-1:4] != 0) begin
                        err=1;
                    end
                    else if(opa_valid && opb_valid) begin
                        res = {8'b0,(opa<<opb[2:0]) | (opa>>(`DW-opb[2:0]))};
                        opa_valid=0; opb_valid=0;
                    end
                end
                4'd13: begin
                    if(opb[`DW-1:4] != 0) begin
                        err=1;
                    end
                    else if(opa_valid && opb_valid) begin
                        res = {8'b0,(opa>>opb[2:0]) | (opa<<(`DW-opb[2:0]))};
                        opa_valid=0; opb_valid=0;
                    end
                end
                default: begin
                    res=0; cout=0; oflow=0; g=0; e=0; l=0; err=1;
                end
            endcase
        end

                if(cmd_mode_change) begin
                count = 0;
               g=0;
               l=0;
                e=0;
                err=0;
                cout=0;
                oflow=0;
                opa_valid=0;
                opb_valid=0;

                //mode=inp_txn.mode;
                //cmd=inp_txn.cmd;
                end
                if(inp_txn.inp_valid[0]) begin opa=inp_txn.opa; opa_valid=1;mode=inp_txn.mode;cmd=inp_txn.cmd; end
                if(inp_txn.inp_valid[1]) begin opb=inp_txn.opb; opb_valid=1; cmd=inp_txn.cmd;mode=inp_txn.mode;end

        //if(inp_txn.mode && (inp_txn.cmd == 10 || inp_txn.cmd == 9)) begin
           //     op_count++;
        //end
       //if(count >= 16) begin
         //        err = 1;
         //     count = 0;
         //end

        endtask

    function void compare();
        `uvm_info("SCB",$sformatf("EXP: RES=%0h COUT=%0b OFLOW=%0b G=%0b E=%0b L=%0b ERR=%0b",
            resc,coutc,oflowc,gc,ec,lc,errc),UVM_LOW)
            //`uvm_info("SCB",$sformatf("input sync: opa=%0h opb=%0h cmd=%0d",out_txn.opa,out_txn.opb,out_txn.cmd),UVM_LOW)
        `uvm_info("SCB",$sformatf("ACT: RES=%0h COUT=%0b OFLOW=%0b G=%0b E=%0b L=%0b ERR=%0b",
            out_txn.res,out_txn.cout,out_txn.oflow,out_txn.g,out_txn.e,out_txn.l,out_txn.err),UVM_LOW)

        if(out_txn.res===resc && out_txn.cout===coutc && out_txn.oflow===oflowc &&
           out_txn.g===gc && out_txn.e===ec && out_txn.l===lc && out_txn.err===errc) begin
            `uvm_info("SCB",$sformatf("PASS\n"),UVM_LOW)
            pass_count++;
        end
        else begin
            `uvm_info("SCB",$sformatf("FAIL\n"),UVM_LOW)
            fail_count++;
        end
	    if(errc)
		    errc=0;
    endfunction

    virtual function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        `uvm_info("RESULTS",$sformatf("TOTAL=%0d PASS_COUNT=%0d FAIL_COUNT=%0d",
            total_txn,pass_count,fail_count),UVM_LOW)
    endfunction
endclass
