module LScontrol (input [31:0] value,
                  input [1:0] control,
                  input [31:0] instruction,
                  input clock,
                  input reset,
                  output reg [31:0] out);
  
  always @(posedge clock or negedge reset)
    begin
      if(~reset)
        out <= 32'b0;
      
      else
        if(control == 2'b01)
          
          out <=  {value[31:23], instruction[22:0]};
                                
        else if (control == 2'b10)
          out <= {value[31:15] , instruction[14:0]};
      	
          
        else if(control == 2'b11)
          out <= value;
      
    end
endmodule
