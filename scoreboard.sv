class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)


    uvm_tlm_analysis_fifo #(trans) inp_fifo;
    uvm_tlm_analysis_fifo #(trans) out_fifo;


    trans ref_output;
    trans prev_output;
    trans current_expected;
    trans expected_q[$];
    trans input_queue[$];


    bit [7:0] oprd1;
    bit [7:0] oprd2;
    int wait_cycles;
    bit waiting_for_opA;
    bit waiting_for_opB;
    bit [2:0] SHIFT_BY;

    function new(string name = "alu_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        inp_fifo = new("inp_fifo", this);
        out_fifo = new("out_fifo", this);

        ref_output = new("ref_output");
        prev_output = new("prev_output");
        current_expected = new("current_expected");

        current_expected.res = 16'b0;
        current_expected.err = 1'b0;
        current_expected.oflow = 1'b0;
        current_expected.cout = 1'b0;
        current_expected.G = 1'b0;
        current_expected.L = 1'b0;
        current_expected.E = 1'b0;
        expected_q.push_back(current_expected);

        oprd1 = 0;
        oprd2 = 0;
        wait_cycles = 0;
        waiting_for_opA = 0;
        waiting_for_opB = 0;
    endfunction


    virtual task run_phase(uvm_phase phase);
     fork
        trans packet2;
        trans packet1;
        trans future_expected;
        trans hold1;
        trans hold2;
        trans hold_state;

        super.run_phase(phase);

        forever begin

            inp_fifo.get(packet2); //inp monitor
            out_fifo.get(packet1); //out monitor


            ref_output.rst = packet2.rst;
            ref_output.ce = packet2.ce;
            ref_output.mode = packet2.mode;
            ref_output.cmd = packet2.cmd;
            ref_output.inp_valid = packet2.inp_valid;
            ref_output.cin = packet2.cin;
            ref_output.err = 1'b0;


            if(packet2.rst) begin
                ref_output.res = 16'b0; ref_output.oflow = 1'b0; ref_output.cout = 1'b0;
                ref_output.G = 1'b0; ref_output.L = 1'b0; ref_output.E = 1'b0; ref_output.err = 1'b0;
                oprd1 = 0; oprd2 = 0; wait_cycles = 0;
                waiting_for_opA = 0; waiting_for_opB = 0;

                expected_q.delete();
                current_expected = new("current_expected");
                current_expected.res = 16'b0; current_expected.err = 1'b0;
                expected_q.push_back(current_expected);
            end
            else if(packet2.ce) begin


                case (packet2.inp_valid)
                    2'b01: begin oprd1 = packet2.OA;
                            if (!waiting_for_opA)
                                    waiting_for_opB = 1;

                                else waiting_for_opA = 0;
                                        wait_cycles = 0;
                                end

                    2'b10: begin oprd2 = packet2.OB; if (!waiting_for_opB) waiting_for_opA = 1; else waiting_for_opB = 0; wait_cycles = 0; end
                    2'b11: begin oprd1 = packet2.OA; oprd2 = packet2.OB; waiting_for_opA = 0; waiting_for_opB = 0; wait_cycles = 0; end
                    default: begin
                        if (waiting_for_opA || waiting_for_opB) begin
                            wait_cycles++;
                            if (wait_cycles > 16) begin ref_output.err = 1'b1; waiting_for_opA = 0; waiting_for_opB = 0; wait_cycles = 0; end
                        end else begin oprd1 = 0; oprd2 = 0; end
                    end
                endcase


                ref_output.oflow = 1'b0; ref_output.cout = 1'b0; ref_output.G = 1'b0; ref_output.L = 1'b0; ref_output.E = 1'b0;

                if(packet2.mode == 1'b1) begin
                    case(packet2.cmd)
                        4'b0000: begin ref_output.res = oprd1 + oprd2; ref_output.cout = (ref_output.res[8]) ? 1'b1 : 1'b0; end
                        4'b0001: begin ref_output.res = oprd1 - oprd2; ref_output.oflow = (oprd1 < oprd2) ? 1'b1 : 1'b0; end
                        4'h2:    begin ref_output.res = oprd1 + oprd2 + packet2.cin; ref_output.cout = (ref_output.res[8]) ? 1'b1 : 1'b0; end
                        4'b0011: begin ref_output.res = (oprd1 - oprd2) - packet2.cin; ref_output.oflow = (oprd1 < (oprd2 + packet2.cin)) ? 1'b1 : 1'b0; end
                        4'b0100: ref_output.res = oprd1 + 1;
                        4'b0101: ref_output.res = oprd1 - 1;
                        4'b0110: ref_output.res = oprd2 + 1;
                        4'b0111: ref_output.res = oprd2 - 1;
                        4'b1000: begin
                            if(oprd1 == oprd2)
                            begin
                                     ref_output.res=0;
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b010;
                            end
                            else if(oprd1 > oprd2)
                            begin
                                     ref_output.res=0;
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b100;
                            end
                            else
                            begin
                                     ref_output.res=0;
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b001;
                            end
                        end
                        4'b1001: ref_output.res = (oprd1 + 1) * (oprd2 + 1);
                        4'b1010: ref_output.res = (oprd1 << 1) * oprd2;
                        default: ref_output.res = 16'b0;
                    endcase


                `uvm_info(get_type_name(), $sformatf("scb arithmatic -> rst: %b | ce: %b | mode: %b | cmd: %0d | valid: %b | OA: %0d | OB: %0d | cin: %b | res: %0d | dut_out=%0d",ref_output.rst, ref_output.ce, ref_output.mode, ref_output.cmd, ref_output.inp_valid, ref_output.OA, ref_output.OB, ref_output.cin, ref_output.res,packet1.res), UVM_LOW)


                end
                else begin
                    case(packet2.cmd)
                        4'b0000: ref_output.res = {8'b0, oprd1 & oprd2};
                        4'b0001: ref_output.res = {8'b0, ~(oprd1 & oprd2)};
                        4'b0010: ref_output.res = {8'b0, oprd1 | oprd2};
                        4'b0011: ref_output.res = {8'b0, ~(oprd1 | oprd2)};
                        4'b0100: ref_output.res = {8'b0, oprd1 ^ oprd2};
                        4'b0101: ref_output.res = {8'b0, ~(oprd1 ^ oprd2)};
                        4'b0110: ref_output.res = {8'b0, ~oprd1};
                        4'b0111: ref_output.res = {8'b0, ~oprd2};
                        4'b1000: ref_output.res = {8'b0, oprd1 >> 1};
                        4'b1001: ref_output.res = {8'b0, oprd1 << 1};
                        4'b1010: ref_output.res = {8'b0, oprd2 >> 1};
                        4'b1011: ref_output.res = {8'b0, oprd2 << 1};
                        4'b1100: begin SHIFT_BY = oprd2[2:0];
                                ref_output.res = {8'b0, (oprd1 << SHIFT_BY) | (oprd1 >> (8 - SHIFT_BY))};
                                        if (oprd2[7:4] != 4'b0) ref_output.err = 1'b1;
                                                end
                        4'b1101: begin SHIFT_BY = oprd2[2:0]; ref_output.res = {8'b0, (oprd1 >> SHIFT_BY) | (oprd1 << (8 - SHIFT_BY))};
                                        if (oprd2[7:4] != 4'b0) ref_output.err = 1'b1;
                                                end
                        default: ref_output.res = 16'b0;
                    endcase

                `uvm_info(get_type_name(),$sformatf("scb logical -> rst: %b | ce: %b | mode: %b | cmd: %0d | valid: %b | OA: %0d | OB: %0d | cin: %b | res: %0d",ref_output.rst, ref_output.ce, ref_output.mode, ref_output.cmd, ref_output.inp_valid, ref_output.OA, ref_output.OB, ref_output.cin, ref_output.res), UVM_LOW)
                end

                // values are poped out and pushed to the queue

                if (expected_q.size() > 0)
                begin
                    current_expected = expected_q.pop_front();
                    prev_output.copy(current_expected);
                end

                future_expected = new("future");
                future_expected.copy(ref_output);

                if (packet2.mode == 1'b1 && (packet2.cmd == 4'b1001 || packet2.cmd == 4'b1010)) begin
                    hold1 = new("h1");
                    hold1.copy(prev_output);

                    hold2 = new("h2");
                    hold2.copy(prev_output);

                    expected_q.push_back(hold1);
                    expected_q.push_back(hold2);
                end

                expected_q.push_back(future_expected);
            end
            else begin
                if (expected_q.size() > 0) begin
                    current_expected = expected_q.pop_front();
                end
                hold_state = new("hold");
                    hold_state.copy(prev_output);
                expected_q.push_back(hold_state);
            end



            if (waiting_for_opA || waiting_for_opB) begin
                `uvm_info(get_type_name(), "\n------------------------------------------------------------------------------", UVM_NONE);
                $display("       SCOREBOARD WAITING FOR OPERAND (WAIT CYCLE: %0d)", wait_cycles);
                $display("------------------------------------------------------------------------------");
            end
            else begin
                $display("--------------|-------------------------------|----------------------------");
                $display("OA \t\t|\t\t%0d\t\t|\t\t-", packet2.OA);
                $display("OB \t\t|\t\t%0d\t\t|\t\t-", packet2.OB);
                $display("cin\t\t|\t\t%b\t\t|\t\t-", packet2.cin);
                $display("Stored OPRD1\t|\t\t%0d\t\t|\t\t-", oprd1);
                $display("Stored OPRD2\t|\t\t%0d\t\t|\t\t-", oprd2);
                $display("--------------|-------------------------------|----------------------------");
                $display("Field\t\t|\tReference Output\t|\tActual Response");
                $display("--------------|-------------------------------|----------------------------");
                $display("rst\t\t|\t\t%b\t\t|\t\t%b", packet2.rst, packet2.rst);
                $display("ce\t\t|\t\t%b\t\t|\t\t%b", packet2.ce, packet2.ce);
                $display("mode\t\t|\t\t%b\t\t|\t\t%b", packet2.mode, packet2.mode);
                $display("cmd\t\t|\t\t%0d\t\t|\t\t%0d", packet2.cmd, packet2.cmd);
                $display("inp_valid\t|\t\t%b\t\t|\t\t%b", packet2.inp_valid, packet2.inp_valid);
                $display("res\t\t|\t\t%0d\t\t|\t\t%0d", current_expected.res, packet1.res);
                $display("err\t\t|\t\t%b\t\t|\t\t%b", current_expected.err, packet1.err);
                $display("oflow\t\t|\t\t%b\t\t|\t\t%b", current_expected.oflow, packet1.oflow);
                $display("cout\t\t|\t\t%b\t\t|\t\t%b", current_expected.cout, packet1.cout);
                $display("g\t\t|\t\t%b\t\t|\t\t%b", current_expected.G, packet1.G);
                $display("e\t\t|\t\t%b\t\t|\t\t%b", current_expected.E, packet1.E);
                $display("l\t\t|\t\t%b\t\t|\t\t%b", current_expected.L, packet1.L);

                if((packet1.res === current_expected.res) && (packet1.err === current_expected.err) &&
                   (packet1.oflow === current_expected.oflow) && (packet1.cout === current_expected.cout) &&
                   (packet1.G === current_expected.G) && (packet1.L === current_expected.L) && (packet1.E === current_expected.E))
                begin
                    `uvm_info(get_type_name(), "\n----------------------------------------------------------------------------\n                  TEST PASS\n----------------------------------------------------------------------------", UVM_NONE);
                end
                else begin
                    `uvm_error(get_type_name(), "\n----------------------------------------------------------------------------\n                  TEST FAILED\n----------------------------------------------------------------------------");
                end
            end
        end
     join
    endtask
endclass
