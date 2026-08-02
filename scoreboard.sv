`include "defines.sv"
`uvm_analysis_imp_decl(_from_act_mon)
`uvm_analysis_imp_decl(_from_pas_mon)

class alu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(alu_scoreboard)

    logic [2:0] SHIFT_BY;

    //Internal State Variables 
    bit [7:0] oprd1;          // Internal register for OPA
    bit [7:0] oprd2;          // Internal register for OPB
    int wait_cycles;          // Counter for the 16-cycle timeout
    bit waiting_for_opA;      // State flag
    bit waiting_for_opB;      // State flag
    bit execute_op;           // Flag to trigger execution

    uvm_analysis_imp_from_act_mon #(trans, alu_scoreboard) inp_analysis_export;
    uvm_analysis_imp_from_pas_mon #(trans, alu_scoreboard) out_analysis_export;

    trans driver_packet[$];
    trans monitor_packet[$];
    trans ref_output, prev_output, condition_packet;

    function new(string name = "alu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        inp_analysis_export = new("inp_analysis_export", this);
        out_analysis_export = new("out_analysis_export", this);
        ref_output = new();
        prev_output = new();
        condition_packet = new();
        
        // Initialize internal state
        oprd1 = 0;
        oprd2 = 0;
        wait_cycles = 0;
        waiting_for_opA = 0;
        waiting_for_opB = 0;
    endfunction
    
    virtual function void write_from_pas__mon(trans t);
        monitor_packet.push_back(t);
    endfunction

    virtual function void write_from_act_mon(trans u);
        condition_packet = u;
        driver_packet.push_back(u);
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans packet2; // From act monitor
        trans packet1; // From pas monitor

        super.run_phase(phase);

        forever begin
            wait(driver_packet.size() > 0);
            wait(monitor_packet.size() > 0);
            
            packet2 = driver_packet.pop_front();
            packet1 = monitor_packet.pop_front();

            //driving to the ref model
            ref_output.rst = packet2.rst;
            ref_output.ce = packet2.ce;
            ref_output.mode = packet2.mode;
            ref_output.cmd = packet2.cmd;
            ref_output.inp_valid = packet2.inp_valid;
            ref_output.cin = packet2.cin;
            execute_op = 0; 
            ref_output.err = 1'b0; // default let the error to be 0

            if(packet2.rst) begin
                ref_output.res = 16'b0; 
                ref_output.oflow = 1'b0;
                ref_output.cout = 1'b0;
                ref_output.G = 1'b0;
                ref_output.L = 1'b0;
                ref_output.E = 1'b0;
                ref_output.err = 1'b0;
                
                oprd1 = 0;
                oprd2 = 0;
                wait_cycles = 0;
                waiting_for_opA = 0;
                waiting_for_opB = 0;
                
                prev_output.copy(ref_output); // Update previous state
            end
            
            else if(packet2.ce) begin
                
                case (packet2.inp_valid)
                    2'b01: begin
                        oprd1 = packet2.OA; 
                        if (waiting_for_opA) begin
                            execute_op = 1; 
                            waiting_for_opA = 0;
                        end else begin
                            waiting_for_opB = 1; 
                        end
                        wait_cycles = 0; // Reset timeout
                    end
                    
                    2'b10: begin
                        oprd2 = packet2.OB; // Capture latest OPB
                        if (waiting_for_opB) begin
                            execute_op = 1; 
                            waiting_for_opB = 0;
                        end else begin
                            waiting_for_opA = 1; 
                        end
                        wait_cycles = 0; // Reset timeout
                    end
                    
                    2'b11: begin
                        oprd1 = packet2.OA; 
                        oprd2 = packet2.OB;
                        waiting_for_opA = 0;
                        waiting_for_opB = 0;
                        wait_cycles = 0;
                        execute_op = 1; // Both ready, execute
                    end
                    
                    default: begin // 2'b00 or Others
                        if (waiting_for_opA || waiting_for_opB) begin
                            wait_cycles++;
                            if (wait_cycles > 16) begin
                                ref_output.err = 1'b1; // Timeout Asserted
                                waiting_for_opA = 0;
                                waiting_for_opB = 0;
                                wait_cycles = 0;
                            end
                        end else begin
                            // Clears internal registers if not waiting
                            oprd1 = 0;
                            oprd2 = 0;
                        end
                    end
                endcase

                // --- B. Execution Logic (Only runs when operands are ready) ---
                if (execute_op) begin
                    // Clear flags before execution
                    ref_output.oflow = 1'b0;
                    ref_output.cout = 1'b0;
                    ref_output.G = 1'b0;
                    ref_output.L = 1'b0;
                    ref_output.E = 1'b0;
                    ref_output.err = 1'b0;

                    if(packet2.mode == 1'b1) begin // --- ARITHMETIC ---
                        case(packet2.cmd)
                            4'b0000: begin      // ADD
                                ref_output.res = oprd1 + oprd2;
                                ref_output.cout = (ref_output.res[8]) ? 1'b1 : 1'b0;
                            end
                            4'b0001: begin      // SUB
                                ref_output.res = oprd1 - oprd2;
                                ref_output.oflow = (oprd1 < oprd2) ? 1'b1 : 1'b0;
                            end
                            4'h2: begin         // ADD_CIN
                                ref_output.res = oprd1 + oprd2 + packet2.cin;
                                ref_output.cout = (ref_output.res[8]) ? 1'b1 : 1'b0;
                            end
                            4'b0011: begin      // SUB_CIN
                                ref_output.res = (oprd1 - oprd2) - packet2.cin;
                                ref_output.oflow = (oprd1 < (oprd2 + packet2.cin)) ? 1'b1 : 1'b0;
                            end
                            4'b0100: ref_output.res = oprd1 + 1; // INC_A
                            4'b0101: ref_output.res = oprd1 - 1; // DEC_A
                            4'b0110: ref_output.res = oprd2 + 1; // INC_B
                            4'b0111: ref_output.res = oprd2 - 1; // DEC_B
                            4'b1000: begin      // CMP
                                if(oprd1 == oprd2)
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b010;
                                else if(oprd1 > oprd2)
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b100;
                                else
                                    {ref_output.G, ref_output.E, ref_output.L} = 3'b001;
                            end
                            4'b1001: ref_output.res = (oprd1 + 1) * (oprd2 + 1); // MUL_INC
                            4'b1010: ref_output.res = (oprd1 << 1) * oprd2;      // MUL_SHL
                            default: ref_output.res = 16'b0;
                        endcase
                    end
                    else begin // --- LOGICAL ---
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
                            4'b1100: begin // ROL_A_B
                                SHIFT_BY = oprd2[2:0];
                                ref_output.res = {8'b0, (oprd1 << SHIFT_BY) | (oprd1 >> (8 - SHIFT_BY))};
                                ref_output.err = (oprd2[7:4] != 4'b0000) ? 1'b1 : 1'b0;
                            end
                            4'b1101: begin // ROR_A_B
                                SHIFT_BY = oprd2[2:0];
                                ref_output.res = {8'b0, (oprd1 >> SHIFT_BY) | (oprd1 << (8 - SHIFT_BY))};
                                ref_output.err = (oprd2[7:4] != 4'b0000) ? 1'b1 : 1'b0;
                            end
                            default: ref_output.res = 16'b0;
                        endcase
                    end
                    
                    // Save this as the previous output for hold cycles
                    prev_output.copy(ref_output); 
                end 
                else begin 
                    // Hold previous output while waiting or idle
                    ref_output.res = prev_output.res;
                    ref_output.oflow = prev_output.oflow;
                    ref_output.cout = prev_output.cout;
                    ref_output.G = prev_output.G;
                    ref_output.L = prev_output.L;
                    ref_output.E = prev_output.E;
                    // Note: 'err' flag is handled dynamically in the wait block above
                end
            end // end of if(ce)
            else begin
                // If CE is low, output should hold
                ref_output.res = prev_output.res;
                ref_output.oflow = prev_output.oflow;
                ref_output.cout = prev_output.cout;
		ref_output.G = prev_output.G;
                ref_output.L = prev_output.L;
                ref_output.E = prev_output.E;
                ref_output.err = prev_output.err;
            end

            // --- 4. COMPARISON DISPLAY ---
            if (waiting_for_opA || waiting_for_opB) begin
                `uvm_info(get_type_name(), "\n------------------------------------------------------------------------------", UVM_NONE);
                $display("       SCOREBOARD WAITING FOR OPERAND (WAIT CYCLE: %0d)", wait_cycles);
                $display("------------------------------------------------------------------------------");
            end
            else begin
                $display("Field\t\t|\tReference Output\t|\tActual Response");
                $display("--------------|-------------------------------|----------------------------");
                $display("rst\t\t|\t\t%b\t\t|\t\t%b", ref_output.rst, packet2.rst);
                $display("ce\t\t|\t\t%b\t\t|\t\t%b", ref_output.ce, packet2.ce);
                $display("mode\t\t|\t\t%b\t\t|\t\t%b", ref_output.mode, packet2.mode);
                $display("cmd\t\t|\t\t%0d\t\t|\t\t%0d", ref_output.cmd, packet2.cmd);
                $display("inp_valid\t|\t\t%b\t\t|\t\t%b", ref_output.inp_valid, packet2.inp_valid);
                $display("res\t\t|\t\t%0d\t\t|\t\t%0d", ref_output.res, packet1.res);
                $display("err\t\t|\t\t%b\t\t|\t\t%b", ref_output.err, packet1.err);
                $display("oflow\t\t|\t\t%b\t\t|\t\t%b", ref_output.oflow, packet1.oflow);
                $display("cout\t\t|\t\t%b\t\t|\t\t%b", ref_output.cout, packet1.cout);
                $display("g\t\t|\t\t%b\t\t|\t\t%b", ref_output.G, packet1.G);
                $display("e\t\t|\t\t%b\t\t|\t\t%b", ref_output.E, packet1.E);
                $display("l\t\t|\t\t%b\t\t|\t\t%b", ref_output.L, packet1.L);
                
                if((packet1.res === ref_output.res) && (packet1.err === ref_output.err) && 
                   (packet1.oflow === ref_output.oflow) && (packet1.cout === ref_output.cout) && 
                   (packet1.G === ref_output.G) && (packet1.L === ref_output.L) && (packet1.E === ref_output.E))
                begin
                    `uvm_info(get_type_name(), "\n----------------------------------------------------------------------------", UVM_NONE);
                    $display("                  TEST PASS                                                                    ");
                    $display("----------------------------------------------------------------------------");
                end
                else
                begin
                    `uvm_error(get_type_name(), "\n----------------------------------------------------------------------------");
                    $display("                  TEST FAILED                                                                  ");
                    $display("----------------------------------------------------------------------------");
                end
            end
        end
    endtask
endclass
