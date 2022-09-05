module LS_Control (input [31:0] b,
                  input [1:0] control,
                  input control2,
                  input [31:0] mdr,
                  input clock,
                  input reset,
                  output reg [31:0] out);

  always @(posedge clock)
    begin
      if(reset)
        out = 32'b0;
      
      else begin
        if (control2 == 1'b1) begin
          if(control == 2'b01) begin
            out =  {b[7:0], mdr[23:0]}; // Correto
          end    
          else if (control == 2'b10) begin
            out = {b[15:0] , mdr[15:0]}; // Correto
          end
          else if(control == 2'b11) begin
            out = b; // Correto
          end
        end    
        else begin
          if(control == 2'b01) begin
            out =  {24'b0, mdr[7:0]};
          end
                                
          else if (control == 2'b10) begin
            out = {16'b0, mdr[15:0]};
          end

          else if(control == 2'b11) begin
            out = mdr;
          end
        end
      end
    end
  
endmodule
