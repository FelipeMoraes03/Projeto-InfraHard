module mult(input signed [31:0] M, Q,
            input clk,
            input reset,
            output reg signed [31:0] mflo,
            output reg signed [31:0] mfhi
            );
  
reg signed [63:0] Out;
integer i;
reg [31:0] Q1;
reg Qres;
reg mult_end;
  
initial
begin
    Qres = 1'd0;
	  Out = 64'd0;
  	Q1 = 32'd0;
    i = 0;
  	mult_end = 0;
end
  
  
always@(posedge clk or negedge reset) 
    begin
      if (~reset)
        begin
              Out <= 64'd0;
              Q1 <= 32'd0;
              Qres <= 0;
              i <= 0;
              mult_end <= 0;
        end
      
      if (!mult_end) 
        begin
            case({M[i], Qres})
                2'b01: Out[63:32] = Out[63:32] + Q;
                2'b10:
                  begin
                    Q1 = - Q;
                  	Out[63:32] = Out[63:32] + Q1;
                  end
            endcase
          Out = Out >>> 1;
          Qres = M[i];
          i = i + 1;
            
          if (i == 32)
            begin
              if (Q == 32'h8000_0000)								
                begin
                  Out = - Out;
                end
                
              mfhi = Out[63:32];
              mflo = Out[31:0];
              mult_end = 1;
                
           	end
        end   
    end
endmodule
