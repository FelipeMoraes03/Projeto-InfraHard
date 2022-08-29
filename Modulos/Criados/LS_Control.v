
//Funcional, 3 saídas, 1 para cada tamanho
`timescale 1ns/1ps

module LScontrol (input [31:0] value,
                  input [1:0] control,
                  input clock,
                  input reset,
                  output reg [31:0] out1,
                  output reg [15:0] out2,
                  output reg [7:0] out3);
  
  always @(posedge clock or negedge reset)
    begin
      if(~reset)
        out1 <= 32'b0;
      
      else
        if(control == 2'b01)
          out3 <= value[7:0];
        else if (control == 2'b10)
          out2 <= value[15:0];
        else if(control == 2'b11)
          out1 <= value;
    end
endmodule


//Funcional, uma única saida 

`timescale 1ns/1ps

module LScontrol (input [31:0] value,
                  input [1:0] control,
                  input clock,
                  input reset,
                  output reg [31:0] out);
  
  always @(posedge clock or negedge reset)
    begin
      if(~reset)
        out <= 32'b0;
      
      else
        if(control == 2'b01)
          out <= value[7:0];
        else if (control == 2'b10)
          out <= value[15:0];
        else if(control == 2'b11)
          out <= value;
    end
endmodule

//Funcional, provavelmente o jeito correto (Esperando resposta do monitor)

`timescale 1ns/1ps

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
