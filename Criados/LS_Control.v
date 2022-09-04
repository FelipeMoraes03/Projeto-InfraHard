module LS_Control (input [31:0] value,
                  input [1:0] control,
                  input control2,
                  input [31:0] instruction,
                  input clock,
                  input reset,
                  output reg [31:0] out);
  
  always @(posedge clock)
    begin
      if(reset)
        out = 32'b0;
      
      else
        if (control2 == 1'b1)
          if(control == 2'b01)
            out =  {value[7:0], instruction[23:0]}; // Correto
                          
          else if (control == 2'b10)
            out = {value[14:0] , instruction[16:0]}; // Correto

          else if(control == 2'b11)
            out = value; // Correto
    
        else
          if(control == 2'b01)
            out =  {{23{1'b0}}, value[7:0]};
                                
          else if (control == 2'b10)
            out = {{16{1'b0}}, value[14:0]};

          else if(control == 2'b11)
            out = value;
    end
  
endmodule