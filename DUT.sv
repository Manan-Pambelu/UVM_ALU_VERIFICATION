module ALU_DESIGN #(parameter DW = 8, CW = 4)(INP_VALID,OPA,OPB,CIN,CLK,RST,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);
 
  input [DW-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [CW-1:0] CMD;
  input [1:0] INP_VALID;
  output reg [DW+1:0] RES = 9'b000000000;
  output reg COUT = 1'b0;
  output reg OFLOW = 1'b0;
  output reg G = 1'b0;
  output reg E = 1'b0;
  output reg L = 1'b0;
  output reg ERR = 1'b0;

 
  reg [DW-1:0] OPA_1, OPB_1;
  reg [DW-1:0] oprd1, oprd2;
  reg [3:0] CMD_tmp;
  reg [DW-1:0] AU_out_tmp1,AU_out_tmp2 ;
  // Added timer and state tracking
  reg [4:0] wait_counter;
  reg oprd1_valid, oprd2_valid;
  
  always @ (posedge CLK) begin
      if(RST) begin
        oprd1<=0;
        oprd2<=0;
        CMD_tmp<=0;
        wait_counter<=0;
        oprd1_valid<=0;
        oprd2_valid<=0;
      end
      else if (INP_VALID==2'b01)  begin    
        oprd1<=OPA;
        CMD_tmp<=CMD;
        oprd1_valid<=1;
        wait_counter<=0;
        // Set error if second operand comes after 16 cycles
        if(oprd2_valid && wait_counter >= 16) begin
          ERR <= 1'b1;
        end
      end
      else if (INP_VALID==2'b10)  begin    
        oprd2<=OPB;
        CMD_tmp<=CMD;
        oprd2_valid<=1;
        wait_counter<=0;
        // Set error if second operand comes after 16 cycles
        if(oprd1_valid && wait_counter >= 16) begin
          ERR <= 1'b1;
        end
      end
      else if (INP_VALID==2'b11)  begin    
        oprd1<=OPA;
        oprd2<=OPB;
        CMD_tmp<=CMD;
        oprd1_valid<=1;
        oprd2_valid<=1;
        wait_counter<=0;
      end
      else begin    
        // Increment wait counter if only one operand is valid
        if((oprd1_valid && !oprd2_valid) || (!oprd1_valid && oprd2_valid)) begin
          if(wait_counter < 16) begin
            wait_counter <= wait_counter + 1;
          end else begin
            // Keep operands but stop incrementing counter after 16 cycles
            wait_counter <= 16;
          end
        end
      end
    end
 
 
    always@(posedge CLK)
      begin
       if(CE)                   
        begin
         if(RST)                
          begin
            RES=9'b000000000;
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
            AU_out_tmp1=0;
            AU_out_tmp2=0;
          end
         else if(MODE && oprd1_valid && oprd2_valid)          
         begin
           RES=9'b000000000;
           COUT=1'b0;
           OFLOW=1'b0;
           G=1'b0;
           E=1'b0;
           L=1'b0;
           ERR=1'b0;
          case(CMD_tmp)             
    4'b0000:                   begin             
              RES=oprd1+oprd2;
              COUT=RES[8]?1:0;
            end
      4'b0001 :                begin
             OFLOW=(oprd1<oprd2)?1:0;
             RES=oprd1-oprd2;
            end
           4'h2:            
            begin
             RES=oprd1+oprd2+CIN;
             COUT=RES[8]?1:0;
            end
           4'b0011:             
           begin
            OFLOW=(oprd1<oprd2)?1:0;
            RES=oprd1-oprd2-CIN;
           end
           4'b0100:RES=oprd1;    
           4'b0101:RES=oprd1-1;    
           4'b0110:RES=oprd2-1;    
           4'b0111:RES=oprd2+1;    
           4'b1000:              
           begin
            RES=9'b000000000;
            if(oprd1==oprd2)
             begin
               E=1'b1;
               G=1'bz;
               L=1'bz;
             end
            else if(oprd1>oprd2)
             begin
               E=1'bz;
               G=1'b1;
               L=1'bz;
             end
            else 
             begin
               E=1'bz;
               G=1'bz;
               L=1'b1;
             end
           end
	   4'b1001: begin   
                    AU_out_tmp1 <= oprd1 + 1;
                    AU_out_tmp2 <= oprd2 + 1;
                    RES <=AU_out_tmp1 * AU_out_tmp2;
                  end
           4'b1010: begin   
                    AU_out_tmp1 <= oprd1 << 1;
                    AU_out_tmp2 <= oprd2;
                    RES <=AU_out_tmp1 - AU_out_tmp2; 
                  end
 
           default:   
            begin
            RES=9'b000000000;
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
           end
          endcase
         end
        else if(!MODE && oprd1_valid && oprd2_valid)          
        begin 
           RES=9'b000000000;
           COUT=1'b0;
           OFLOW=1'b0;
           G=1'b0;
           E=1'b0;
           L=1'b0;
           ERR=1'b0;
           case(CMD_tmp)    
             4'b0000:RES={1'b0,oprd1&oprd2};     
             4'b0001:RES={1'b0,~(oprd1&oprd2)};  
             4'b0010:RES={1'b0,oprd1&&oprd2};     
             4'b0011:RES={1'b0,~(oprd1|oprd2)};  
             4'b0100:RES={1'b0,oprd1^oprd2};     
             4'b0101:RES={1'b0,~(oprd1^oprd2)};  
             4'b0110:RES={1'b0,~oprd1};        
             4'b0111:RES={1'b0,~oprd2};        
             4'b1000:RES={1'b0,oprd1};      
             4'b1001:RES={1'b0,oprd1<<1};      
             4'b1010:RES={1'b0,oprd2<<1};      
             4'b1011:RES={1'b0,oprd2<<1};     
             4'b1100:                        
             begin
               if(oprd2[0])
                 OPA_1 = {oprd1[6:0], oprd1[7]};
               else
                 OPA_1 = oprd1;
               if(oprd2[1])
                 OPB_1 =  {OPA_1[5:0], OPA_1[7:6]}; 
               else
                 OPB_1= OPA_1;
               if(oprd2[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;
               if(oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
                 ERR=1'b1;
             end
             4'b1101:                        
             begin
               if(oprd2[0])
                 OPA_1 = {oprd1[0], oprd1[7:1]};
               else
                 OPA_1 = oprd1;
               if(oprd2[1])
                 OPB_1 =  {OPA_1[1:0], OPA_1[7:2]}; 
               else
                 OPB_1= OPA_1;
               if(oprd2[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;
               if(oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
                 ERR=1'b0;
             end
             default:   
               begin
               RES=9'b000000000;
               COUT=1'b0;
               OFLOW=1'b0;
               G=1'b0;
               E=1'b0;
               L=1'b0;
               ERR=1'b0;
               end
          endcase
     end
    end
   end
endmodule
