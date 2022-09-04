module LS_Control (input [31:0] value,
                  input [1:0] control,
                  input [31:0] instruction,
                  input clock,
                  input reset,
                  output reg [31:0] out);
  
  always @(posedge clock)
    begin
      if(reset)
        out = 32'b0;
      
      else
        if(control == 2'b01)
          out =  {value[7:0], instruction[23:0]};
                                
        else if (control == 2'b10)
      	  out = {value[14:0] , instruction[17:0]};

        else if(control == 2'b11)
          out = value;
      
    end
endmodule
